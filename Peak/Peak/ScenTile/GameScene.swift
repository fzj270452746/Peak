//
//  GameScene.swift
//  Peak
//
//  Created by Zhao on 2025/12/29.
//

import SpriteKit

/// 危险预警等级
enum DangerLevel: Equatable {
    case none
    case warning
    case critical
}

protocol GameSceneDelegate: AnyObject {
    func gameDidEnd(score: Int)
    func scoreDidUpdate(_ score: Int)
    func gameTimeDidUpdate(_ elapsedTime: TimeInterval)
    func showPowerUpMessage(_ message: String)
    func dangerLevelDidChange(_ level: DangerLevel)
}

/// 主游戏 SpriteKit 场景
class GameScene: SKScene {
    
    weak var gameDelegate: GameSceneDelegate?
    
    /// 本局难度
    var difficulty: GameDifficulty = GameSettings.selectedDifficulty
    
    /// 本局游戏模式
    var gameMode: GameMode = GameSettings.selectedGameMode
    
    private var containerRect: CGRect = .zero
    private var tiles: [PeakTile] = []
    private var powerUpBalls: [PowerUpBall] = []
    
    private var score: Int = 0 {
        didSet { gameDelegate?.scoreDidUpdate(score) }
    }
    
    private var spawnTimer: Timer?
    private var powerUpSpawnTimer: Timer?
    private var gravityModifier: CGFloat = 1.0
    private var gravityEffectTimer: Timer?
    private var freezeTimer: Timer?
    
    private var spawnInterval: TimeInterval = 2.0
    private var minSpawnInterval: TimeInterval = 0.8
    private var spawnIntervalStep: TimeInterval = 0.05
    
    private var isGameRunning: Bool = false
    private var isGameOver: Bool = false
    private var isSpawnFrozen: Bool = false
    
    private var gameTimer: Timer?
    private var gameStartTime: Date?
    private var elapsedTime: TimeInterval = 0
    
    private var currentDangerLevel: DangerLevel = .none
    private var dangerLineNode: SKShapeNode?
    private var dangerGlowNode: SKShapeNode?
    private var poolBorderNode: SKNode?
    private var poolBoundaryNodes: [SKNode] = []
    
    /// 麻将池相对屏幕的边距（尽量贴近四边）
    private enum PoolLayout {
        static let horizontalMargin: CGFloat = 12
        static let bottomMargin: CGFloat = 12
        static let topMargin: CGFloat = 12
    }
    
    /// 麻将池顶部“已满”判定线（堆叠顶超过此线即结束）
    private var poolFillTopY: CGFloat {
        containerRect.maxY
    }
    
    private var tileSize: CGSize {
        let width = containerRect.width * 0.15
        let height = width * 1.40
        return CGSize(width: width, height: height)
    }
    
    /// 匹配模式：面值与显示数字一致的概率
    private let matchChallengeMatchingChance: Double = 0.52
    
    private let powerUpPool: [PowerUpType] = [
        .speedUp, .speedDown, .freeze, .clearLayer, .luckyWheel
    ]
    
    // MARK: - Scene Setup
    
    override func didMove(to view: SKView) {
        applyDifficultySettings()
        setupScene()
        setupContainer()
        setupDangerLine()
        startGame()
    }
    
    override func update(_ currentTime: TimeInterval) {
        if isGameRunning && !isGameOver {
            constrainTilesToPool()
            checkGameOver()
            updateDangerWarning()
        }
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, size.height > 0 else { return }
        updateContainerRect()
        rebuildPoolPhysicsBoundaries()
        setupGrassPoolBorder()
        updateDangerLineGeometry()
    }
    
    /// 应用难度参数
    private func applyDifficultySettings() {
        spawnInterval = difficulty.initialSpawnInterval
        minSpawnInterval = difficulty.minSpawnInterval
        spawnIntervalStep = difficulty.spawnIntervalStep
        gravityModifier = difficulty.gravityScale
    }
    
    private func setupScene() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        updateGravity()
        physicsWorld.contactDelegate = self
    }
    
    private func updateGravity() {
        let baseGravity: CGFloat = -3.0
        physicsWorld.gravity = CGVector(dx: 0, dy: baseGravity * gravityModifier)
    }
    
    /// 根据屏幕尺寸更新麻将池区域（贴近四边，小草边框仅作装饰）
    private func updateContainerRect() {
        let h = PoolLayout.horizontalMargin
        let b = PoolLayout.bottomMargin
        let t = PoolLayout.topMargin
        containerRect = CGRect(
            x: h,
            y: b,
            width: max(0, size.width - h * 2),
            height: max(0, size.height - b - t)
        )
    }
    
    private func setupContainer() {
        updateContainerRect()
        rebuildPoolPhysicsBoundaries()
        setupGrassPoolBorder()
    }
    
    /// 麻将牌中心 X、底边 Y 的可活动范围（不超出小草边框）
    private func tileMovementLimits() -> (minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat) {
        let halfW = tileSize.width / 2
        let inset: CGFloat = 3
        return (
            containerRect.minX + halfW + inset,
            containerRect.maxX - halfW - inset,
            containerRect.minY + inset,
            containerRect.maxY - tileSize.height - inset
        )
    }
    
    /// 重建麻将池四边物理挡板（与小草边框一致）
    private func rebuildPoolPhysicsBoundaries() {
        poolBoundaryNodes.forEach { $0.removeFromParent() }
        poolBoundaryNodes.removeAll()
        guard containerRect.width > 0, containerRect.height > 0 else { return }
        
        let r = containerRect
        let edges: [(CGPoint, CGPoint)] = [
            (CGPoint(x: r.minX, y: r.minY), CGPoint(x: r.maxX, y: r.minY)),
            (CGPoint(x: r.minX, y: r.minY), CGPoint(x: r.minX, y: r.maxY)),
            (CGPoint(x: r.maxX, y: r.minY), CGPoint(x: r.maxX, y: r.maxY)),
            (CGPoint(x: r.minX, y: r.maxY), CGPoint(x: r.maxX, y: r.maxY))
        ]
        for (start, end) in edges {
            poolBoundaryNodes.append(addBoundary(from: start, to: end))
        }
    }
    
    /// 将越界麻将约束回池内
    private func constrainTilesToPool() {
        guard !tiles.isEmpty, containerRect.width > 0 else { return }
        let limits = tileMovementLimits()
        let poolTop = containerRect.maxY - 3
        
        for tile in tiles {
            var pos = tile.position
            var adjusted = false
            
            if pos.x < limits.minX {
                pos.x = limits.minX
                tile.physicsBody?.velocity = CGVector(dx: 0, dy: tile.physicsBody?.velocity.dy ?? 0)
                adjusted = true
            } else if pos.x > limits.maxX {
                pos.x = limits.maxX
                tile.physicsBody?.velocity = CGVector(dx: 0, dy: tile.physicsBody?.velocity.dy ?? 0)
                adjusted = true
            }
            
            if pos.y < limits.minY {
                pos.y = limits.minY
                if let vy = tile.physicsBody?.velocity.dy, vy < 0 {
                    tile.physicsBody?.velocity = CGVector(dx: tile.physicsBody?.velocity.dx ?? 0, dy: 0)
                }
                adjusted = true
            }
            
            let tileTop = tile.calculateAccumulatedFrame().maxY
            if tileTop > poolTop {
                pos.y = limits.maxY
                if let vy = tile.physicsBody?.velocity.dy, vy > 0 {
                    tile.physicsBody?.velocity = CGVector(dx: tile.physicsBody?.velocity.dx ?? 0, dy: 0)
                }
                adjusted = true
            }
            
            if adjusted {
                tile.position = pos
            }
        }
    }
    
    /// 为麻将池绘制小草风格装饰边框
    private func setupGrassPoolBorder() {
        poolBorderNode?.removeFromParent()
        
        let rect = containerRect
        let borderRoot = SKNode()
        borderRoot.zPosition = 3
        
        let floorPath = UIBezierPath(roundedRect: rect, cornerRadius: 18)
        let floor = SKShapeNode(path: floorPath.cgPath)
        floor.fillColor = UIColor(red: 0.92, green: 0.78, blue: 0.48, alpha: 0.22)
        floor.strokeColor = UIColor(red: 0.55, green: 0.38, blue: 0.18, alpha: 0.35)
        floor.lineWidth = 2
        borderRoot.addChild(floor)
        
        let grassColors: [UIColor] = [
            UIColor(red: 0.32, green: 0.62, blue: 0.28, alpha: 1),
            UIColor(red: 0.42, green: 0.72, blue: 0.32, alpha: 1),
            UIColor(red: 0.55, green: 0.78, blue: 0.25, alpha: 1)
        ]
        
        addGrassTufts(along: rect, colors: grassColors, to: borderRoot)
        
        let outline = SKShapeNode(path: makeWavyGrassOutline(in: rect, cornerRadius: 18).cgPath)
        outline.fillColor = .clear
        outline.strokeColor = UIColor(red: 0.28, green: 0.52, blue: 0.22, alpha: 0.85)
        outline.lineWidth = 3
        outline.glowWidth = 1
        borderRoot.addChild(outline)
        
        addChild(borderRoot)
        poolBorderNode = borderRoot
    }
    
    /// 沿池边生成小草簇
    private func addGrassTufts(along rect: CGRect, colors: [UIColor], to parent: SKNode) {
        let tuftSpacing: CGFloat = 14
        let tuftHeight: CGFloat = 10
        
        var x = rect.minX + 8
        while x < rect.maxX - 8 {
            let phase = sin(x * 0.08) * 2
            addGrassTuft(at: CGPoint(x: x, y: rect.maxY + 2 + phase), height: tuftHeight, colors: colors, to: parent)
            x += tuftSpacing
        }
        
        var y = rect.minY + 12
        while y < rect.maxY - 20 {
            addGrassTuft(at: CGPoint(x: rect.minX - 2, y: y), height: tuftHeight * 0.7, colors: colors, to: parent, angle: .pi / 2)
            addGrassTuft(at: CGPoint(x: rect.maxX + 2, y: y), height: tuftHeight * 0.7, colors: colors, to: parent, angle: -.pi / 2)
            y += tuftSpacing * 1.4
        }
        
        let bottomCount = Int(rect.width / 18)
        for i in 0..<bottomCount {
            let t = CGFloat(i) / CGFloat(max(bottomCount - 1, 1))
            let bx = rect.minX + 10 + t * (rect.width - 20)
            addGrassTuft(at: CGPoint(x: bx, y: rect.minY - 1), height: tuftHeight * 0.85, colors: colors, to: parent, angle: .pi)
        }
    }
    
    /// 绘制单簇小草
    private func addGrassTuft(at point: CGPoint, height: CGFloat, colors: [UIColor], to parent: SKNode, angle: CGFloat = 0) {
        let tuft = SKNode()
        tuft.position = point
        tuft.zRotation = angle
        
        let bladeOffsets: [CGFloat] = [-3, 0, 3]
        for (index, offset) in bladeOffsets.enumerated() {
            let blade = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: offset, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: offset + (index == 1 ? 0 : (offset > 0 ? 2 : -2)), y: height),
                control: CGPoint(x: offset * 1.6, y: height * 0.55)
            )
            blade.path = path
            blade.strokeColor = colors[index % colors.count]
            blade.lineWidth = 2.2
            blade.lineCap = .round
            tuft.addChild(blade)
        }
        parent.addChild(tuft)
    }
    
    /// 生成带波浪草边的圆角矩形路径
    private func makeWavyGrassOutline(in rect: CGRect, cornerRadius: CGFloat) -> UIBezierPath {
        let waveAmp: CGFloat = 4
        let waveStep: CGFloat = 10
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius),
            controlPoint: CGPoint(x: rect.maxX, y: rect.minY)
        )
        
        var y = rect.minY + cornerRadius
        while y < rect.maxY - cornerRadius {
            let wobble = sin(y / waveStep) * waveAmp * 0.3
            path.addLine(to: CGPoint(x: rect.maxX + wobble, y: y))
            y += waveStep
        }
        
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY),
            controlPoint: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        
        var x = rect.maxX - cornerRadius
        while x > rect.minX + cornerRadius {
            let wobble = sin(x / waveStep) * waveAmp
            path.addLine(to: CGPoint(x: x, y: rect.maxY + wobble))
            x -= waveStep
        }
        
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius),
            controlPoint: CGPoint(x: rect.minX, y: rect.maxY)
        )
        
        y = rect.maxY - cornerRadius
        while y > rect.minY + cornerRadius {
            let wobble = sin(y / waveStep) * waveAmp * 0.3
            path.addLine(to: CGPoint(x: rect.minX - wobble, y: y))
            y -= waveStep
        }
        
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY),
            controlPoint: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.close()
        return path
    }
    
    @discardableResult
    private func addBoundary(from start: CGPoint, to end: CGPoint) -> SKNode {
        let node = SKNode()
        node.physicsBody = SKPhysicsBody(edgeFrom: start, to: end)
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.container
        node.physicsBody?.contactTestBitMask = PhysicsCategory.tile
        node.physicsBody?.collisionBitMask = PhysicsCategory.tile
        node.physicsBody?.restitution = 0.05
        addChild(node)
        return node
    }
    
    /// 绘制危险预警线（相对于麻将池高度）
    private func setupDangerLine() {
        dangerLineNode = SKShapeNode()
        dangerLineNode?.strokeColor = UIColor.systemRed.withAlphaComponent(0.35)
        dangerLineNode?.lineWidth = 2
        dangerLineNode?.zPosition = 200
        dangerLineNode?.isHidden = true
        if let line = dangerLineNode { addChild(line) }
        
        dangerGlowNode = SKShapeNode()
        dangerGlowNode?.fillColor = UIColor.systemRed.withAlphaComponent(0)
        dangerGlowNode?.strokeColor = .clear
        dangerGlowNode?.zPosition = 1
        if let glow = dangerGlowNode { addChild(glow) }
        
        updateDangerLineGeometry()
    }
    
    /// 按当前麻将池区域刷新危险线位置
    private func updateDangerLineGeometry() {
        guard containerRect.height > 0 else { return }
        let warningY = containerRect.minY + containerRect.height * difficulty.dangerLineRatio
        let linePath = CGMutablePath()
        linePath.move(to: CGPoint(x: containerRect.minX + 4, y: warningY))
        linePath.addLine(to: CGPoint(x: containerRect.maxX - 4, y: warningY))
        dangerLineNode?.path = linePath
        
        let glowRect = CGRect(
            x: containerRect.minX,
            y: warningY,
            width: containerRect.width,
            height: containerRect.maxY - warningY
        )
        dangerGlowNode?.path = UIBezierPath(rect: glowRect).cgPath
    }
    
    /// 麻将池是否已被麻将堆满
    private func isPoolFull() -> Bool {
        guard !tiles.isEmpty else { return false }
        return highestTileTopY() >= poolFillTopY
    }
    
    // MARK: - Game Control
    
    func startGame() {
        guard !isGameRunning else { return }
        
        isGameRunning = true
        isGameOver = false
        isSpawnFrozen = false
        score = 0
        elapsedTime = 0
        gameStartTime = Date()
        currentDangerLevel = .none
        gameDelegate?.dangerLevelDidChange(.none)
        
        startGameTimer()
        startSpawning()
        if gameMode == .classic {
            startPowerUpSpawning()
        }
    }
    
    private func startPowerUpSpawning() {
        guard gameMode == .classic else { return }
        powerUpSpawnTimer?.invalidate()
        let firstDelay = TimeInterval.random(in: 3...5)
        DispatchQueue.main.asyncAfter(deadline: .now() + firstDelay) { [weak self] in
            guard let self = self, self.isGameRunning, !self.isGameOver else { return }
            self.spawnPowerUpBall()
            self.scheduleNextPowerUp()
        }
    }
    
    private func scheduleNextPowerUp() {
        guard isGameRunning, !isGameOver else { return }
        let nextInterval = TimeInterval.random(in: 7...12)
        powerUpSpawnTimer = Timer.scheduledTimer(withTimeInterval: nextInterval, repeats: false) { [weak self] _ in
            guard let self = self, self.isGameRunning, !self.isGameOver else { return }
            self.spawnPowerUpBall()
            self.scheduleNextPowerUp()
        }
    }
    
    private func spawnPowerUpBall() {
        guard isGameRunning, !isGameOver else { return }
        
        let type = powerUpPool.randomElement() ?? .speedUp
        let ballSize: CGFloat = 30
        let minX = containerRect.minX + ballSize / 2 + 10
        let maxX = containerRect.maxX - ballSize / 2 - 10
        let randomX = CGFloat.random(in: minX...maxX)
        
        let ball = PowerUpBall(type: type, size: ballSize)
        ball.powerUpDelegate = self
        // 限制在麻将池物理边界内生成，防止被顶部边界挡住
        ball.position = CGPoint(x: randomX, y: containerRect.maxY - ballSize / 2 - 2)
        addChild(ball)
        powerUpBalls.append(ball)
        
        
        ball.run(SKAction.sequence([
            SKAction.wait(forDuration: 15),
            SKAction.run { [weak self] in
                self?.removePowerUpBall(ball)
            }
        ]))
    }
    
    private func removePowerUpBall(_ ball: PowerUpBall) {
        if let index = powerUpBalls.firstIndex(where: { $0 === ball }) {
            powerUpBalls.remove(at: index)
        }
        ball.removeFromParent()
    }
    
    private func startGameTimer() {
        gameTimer?.invalidate()
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let start = self.gameStartTime else { return }
            if self.isGameRunning && !self.isGameOver {
                self.elapsedTime = Date().timeIntervalSince(start)
                self.gameDelegate?.gameTimeDidUpdate(self.elapsedTime)
            }
        }
    }
    
    func getElapsedTime() -> TimeInterval {
        return elapsedTime
    }
    
    func pauseGame() {
        isGameRunning = false
        spawnTimer?.invalidate()
        spawnTimer = nil
        gameTimer?.invalidate()
        gameTimer = nil
        powerUpSpawnTimer?.invalidate()
        powerUpSpawnTimer = nil
        gravityEffectTimer?.invalidate()
        gravityEffectTimer = nil
        freezeTimer?.invalidate()
        freezeTimer = nil
    }
    
    func resumeGame() {
        guard !isGameOver else { return }
        isGameRunning = true
        gameStartTime = Date().addingTimeInterval(-elapsedTime)
        startGameTimer()
        startSpawning()
        if gameMode == .classic {
            startPowerUpSpawning()
        }
    }
    
    private func startSpawning() {
        spawnTimer?.invalidate()
        guard !isSpawnFrozen else { return }
        spawnTimer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { [weak self] _ in
            self?.spawnNewTile()
            self?.increaseDifficulty()
        }
    }
    
    private func increaseDifficulty() {
        if spawnInterval > minSpawnInterval {
            spawnInterval -= spawnIntervalStep
            if !isSpawnFrozen {
                spawnTimer?.invalidate()
                startSpawning()
            }
        }
    }
    
    // MARK: - Danger Warning
    
    private func highestTileTopY() -> CGFloat {
        guard !tiles.isEmpty else { return 0 }
        return tiles.map { $0.calculateAccumulatedFrame().maxY }.max() ?? 0
    }
    
    private func updateDangerWarning() {
        let topY = highestTileTopY()
        let warningY = containerRect.minY + containerRect.height * difficulty.dangerLineRatio
        let criticalY = poolFillTopY - tileSize.height * 0.35
        
        let newLevel: DangerLevel
        if isPoolFull() {
            newLevel = .critical
        } else if topY >= criticalY {
            newLevel = .critical
        } else if topY >= warningY {
            newLevel = .warning
        } else {
            newLevel = .none
        }
        
        if newLevel != currentDangerLevel {
            currentDangerLevel = newLevel
            gameDelegate?.dangerLevelDidChange(newLevel)
        }
        
        switch newLevel {
        case .none:
            dangerLineNode?.isHidden = true
            dangerGlowNode?.fillColor = UIColor.systemRed.withAlphaComponent(0)
        case .warning:
            dangerLineNode?.isHidden = false
            dangerLineNode?.strokeColor = UIColor.systemOrange.withAlphaComponent(0.7)
            dangerGlowNode?.fillColor = UIColor.systemOrange.withAlphaComponent(0.08)
            pulseDangerLine()
        case .critical:
            dangerLineNode?.isHidden = false
            dangerLineNode?.strokeColor = UIColor.systemRed.withAlphaComponent(0.95)
            dangerGlowNode?.fillColor = UIColor.systemRed.withAlphaComponent(0.15)
            pulseDangerLine()
        }
    }
    
    private func pulseDangerLine() {
        guard let line = dangerLineNode, line.action(forKey: "pulse") == nil else { return }
        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.4, duration: 0.35),
            SKAction.fadeAlpha(to: 1.0, duration: 0.35)
        ]))
        line.run(pulse, withKey: "pulse")
    }
    
    // MARK: - Tile Management
    
    private func pickTileKind() -> PeakTileKind {
        let roll = Double.random(in: 0...1)
        if roll < difficulty.bombChance { return .bomb }
        if roll < difficulty.bombChance + difficulty.obstacleChance { return .obstacle }
        if roll < difficulty.bombChance + difficulty.obstacleChance + difficulty.multiplierChance { return .multiplier }
        return .normal
    }
    
    /// 创建经典模式随机牌
    private func createClassicTile() -> PeakTile {
        let model = allPeakModels.randomElement() ?? peakA0
        let kind = pickTileKind()
        return PeakTile(model: model, size: tileSize, kind: kind, gameMode: .classic)
    }
    
    /// 创建匹配挑战模式牌（部分面值与显示数字一致）
    private func createMatchChallengeTile() -> PeakTile {
        let shouldMatch = Double.random(in: 0...1) < matchChallengeMatchingChance
        let displayNumber = Int.random(in: 1...9)
        let faceValue: Int
        let model: PeakModel
        
        if shouldMatch {
            faceValue = displayNumber
            model = peakModels(withValue: displayNumber).randomElement()
                ?? allPeakModels.randomElement()
                ?? peakA0
        } else {
            var mismatchedValue = Int.random(in: 1...9)
            while mismatchedValue == displayNumber {
                mismatchedValue = Int.random(in: 1...9)
            }
            faceValue = mismatchedValue
            let wrongImageModels = allPeakModels.filter { ($0.peakValue ?? 1) != displayNumber }
            model = wrongImageModels.randomElement() ?? allPeakModels.randomElement() ?? peakA0
        }
        
        return PeakTile(
            model: model,
            size: tileSize,
            kind: .normal,
            gameMode: .matchChallenge,
            displayNumber: displayNumber,
            faceValue: faceValue
        )
    }
    
    /// 按当前模式创建麻将牌
    private func createRandomTile() -> PeakTile {
        switch gameMode {
        case .classic:
            return createClassicTile()
        case .matchChallenge:
            return createMatchChallengeTile()
        }
    }
    
    private func spawnNewTile() {
        guard isGameRunning, !isGameOver, !isSpawnFrozen else { return }
        
        let limits = tileMovementLimits()
        var spawnY = limits.minY
        if !tiles.isEmpty {
            spawnY = max(limits.minY, highestTileTopY())
        }
        
        if isPoolFull() {
            endGame()
            return
        }
        
        let newTile = createRandomTile()
        newTile.tileDelegate = self
        
        let randomX = CGFloat.random(in: limits.minX...limits.maxX)
        newTile.position = CGPoint(x: randomX, y: spawnY)
        newTile.physicsBody?.affectedByGravity = false
        
        newTile.setScale(0)
        newTile.alpha = 0
        addChild(newTile)
        tiles.append(newTile)
        
        let spawnSequence = SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 1.0, duration: 0.4),
                SKAction.fadeIn(withDuration: 0.4)
            ]),
            SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ]),
            SKAction.run { newTile.physicsBody?.affectedByGravity = true }
        ])
        newTile.run(spawnSequence)
    }
    
    /// 从场景中移除麻将并可选计分
    func removeTile(_ tile: PeakTile, awardScore: Bool) {
        guard let index = tiles.firstIndex(where: { $0 === tile }) else { return }
        tiles.remove(at: index)
        guard awardScore else {
            return
        }
        var baseScore = tile.value * 10
        if tile.isMultiplierTile {
            baseScore *= 2
        }
        score += baseScore
    }
    
    /// 炸弹波及范围内消除相邻牌
    private func explodeBomb(at tile: PeakTile) {
        let radius = tileSize.width * 1.8
        let targets = tiles.filter { other in
            other !== tile && hypot(other.position.x - tile.position.x, other.position.y - tile.position.y) < radius
        }
        for target in targets {
            target.removeTile()
        }
        if !targets.isEmpty {
        }
    }
    
    /// 清除堆叠最高的一层（最多 3 张）
    private func clearTopLayer() {
        guard !tiles.isEmpty else { return }
        let topY = highestTileTopY()
        let threshold = topY - tileSize.height * 0.6
        let topTiles = tiles.filter { $0.calculateAccumulatedFrame().maxY >= threshold }
            .sorted { $0.calculateAccumulatedFrame().maxY > $1.calculateAccumulatedFrame().maxY }
            .prefix(3)
        
        for tile in topTiles {
            tile.removeTile()
        }
    }
    
    private func checkGameOver() {
        if isPoolFull() {
            endGame()
        }
    }
    
    private func endGame() {
        guard !isGameOver else { return }
        
        isGameOver = true
        isGameRunning = false
        spawnTimer?.invalidate()
        spawnTimer = nil
        gameTimer?.invalidate()
        gameTimer = nil
        powerUpSpawnTimer?.invalidate()
        powerUpSpawnTimer = nil
        gravityEffectTimer?.invalidate()
        gravityEffectTimer = nil
        freezeTimer?.invalidate()
        freezeTimer = nil
        
        gravityModifier = difficulty.gravityScale
        updateGravity()
        gameDelegate?.dangerLevelDidChange(.none)
        gameDelegate?.gameDidEnd(score: score)
    }
    
    // MARK: - Power-Up Effects
    
    private func activateFreeze(duration: TimeInterval = 3.0) {
        isSpawnFrozen = true
        spawnTimer?.invalidate()
        spawnTimer = nil
        freezeTimer?.invalidate()
        freezeTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.isSpawnFrozen = false
            if self.isGameRunning && !self.isGameOver {
                self.startSpawning()
            }
            self.gameDelegate?.showPowerUpMessage("")
        }
        print("冻结生成 \(duration) 秒")
    }
    
    private func activateLuckyWheel() {
        let effects: [PowerUpType] = [.speedUp, .speedDown, .freeze, .clearLayer]
        let picked = effects.randomElement() ?? .speedUp
        applyPowerUp(type: picked, fromLuckyWheel: true)
    }
    
    private func applyPowerUp(type: PowerUpType, fromLuckyWheel: Bool = false) {
        let prefix = fromLuckyWheel ? "🎡 Lucky! " : ""
        
        switch type {
        case .speedUp:
            gravityModifier = difficulty.gravityScale * 1.5
            gameDelegate?.showPowerUpMessage(prefix + "⚡ Speed Up!")
            scheduleGravityReset(after: 5)
        case .speedDown:
            gravityModifier = difficulty.gravityScale * 0.5
            gameDelegate?.showPowerUpMessage(prefix + "🐌 Speed Down!")
            scheduleGravityReset(after: 5)
        case .freeze:
            gameDelegate?.showPowerUpMessage(prefix + "❄️ Freeze!")
            activateFreeze()
        case .clearLayer:
            clearTopLayer()
            gameDelegate?.showPowerUpMessage(prefix + "🧹 Clear Top!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.gameDelegate?.showPowerUpMessage("")
            }
            return
        case .luckyWheel:
            activateLuckyWheel()
            return
        }
        updateGravity()
    }
    
    private func scheduleGravityReset(after duration: TimeInterval) {
        gravityEffectTimer?.invalidate()
        gravityEffectTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.gravityModifier = self.difficulty.gravityScale
            self.updateGravity()
            self.gameDelegate?.showPowerUpMessage("")
        }
    }
    
    override func willMove(from view: SKView) {
        spawnTimer?.invalidate()
        gameTimer?.invalidate()
        powerUpSpawnTimer?.invalidate()
        gravityEffectTimer?.invalidate()
        freezeTimer?.invalidate()
    }
}

// MARK: - SKPhysicsContactDelegate

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {}
}

// MARK: - PeakTileDelegate

extension GameScene: PeakTileDelegate {
    func tileWasRemoved(_ tile: PeakTile, reason: PeakTileRemovalReason) {
        let awardScore = reason == .scored
        removeTile(tile, awardScore: awardScore)
    }
    
    func bombTileDidExplode(_ tile: PeakTile) {
        explodeBomb(at: tile)
    }
}

// MARK: - PowerUpBallDelegate

extension GameScene: PowerUpBallDelegate {
    func powerUpWasActivated(type: PowerUpType) {
        applyPowerUp(type: type)
    }
}
