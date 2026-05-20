//
//  PeakTile.swift
//  Peak
//
//  Created by Zhao on 2025/12/29.
//

import SpriteKit

/// 麻将牌移除原因
enum PeakTileRemovalReason {
    /// 正常消除并计分
    case scored
    /// 匹配模式中通过删除按钮移出，不计分
    case dismissed
}

protocol PeakTileDelegate: AnyObject {
    func tileWasRemoved(_ tile: PeakTile, reason: PeakTileRemovalReason)
    /// 炸弹牌消除时通知场景清除周围牌
    func bombTileDidExplode(_ tile: PeakTile)
}

/// 麻将牌类型
enum PeakTileKind {
    case normal
    case multiplier
    case bomb
    case obstacle
}

/// 场景中的单张麻将牌
class PeakTile: SKSpriteNode {
    
    // MARK: - Properties
    
    /// 所属游戏模式
    var gameMode: GameMode = .classic
    
    /// 牌面点数（1-9），用于计分与匹配判断
    var value: Int
    
    /// 匹配模式：牌面中央显示的数字（1-9）
    var displayNumber: Int = 1
    
    /// 匹配模式：面值与显示数字是否一致
    var isValueMatching: Bool = true
    
    /// 当前点击次数
    var clickCount: Int = 0
    
    /// 牌面模型
    var model: PeakModel
    
    /// 牌类型
    var tileKind: PeakTileKind = .normal
    
    /// 是否为分数翻倍牌
    var isMultiplierTile: Bool { tileKind == .multiplier }
    
    /// 是否为炸弹牌
    var isBombTile: Bool { tileKind == .bomb }
    
    /// 是否为障碍牌
    var isObstacleTile: Bool { tileKind == .obstacle }
    
    /// 消除所需点击次数
    var requiredClicks: Int {
        switch tileKind {
        case .obstacle:
            return value + 2
        default:
            return value
        }
    }
    
    /// Background glow node for multiplier tiles
    private var glowNode: SKShapeNode?
    
    /// Delegate to notify when tile is removed
    weak var tileDelegate: PeakTileDelegate?
    
    /// Label showing remaining clicks needed
    private var clickLabel: SKLabelNode?
    
    /// Stroke label for outline effect
    private var strokeLabel: SKLabelNode?
    
    /// Border node for rounded corners
    private var borderNode: SKShapeNode?
    
    /// Whether the tile is being removed
    private var isRemoving: Bool = false
    
    /// 匹配模式右上角删除按钮
    private var deleteButtonNode: SKNode?
    
    /// 匹配状态指示描边
    private var matchIndicatorNode: SKShapeNode?
    
    // MARK: - Initialization
    
    init(
        model: PeakModel,
        size: CGSize,
        kind: PeakTileKind = .normal,
        gameMode: GameMode = .classic,
        displayNumber: Int? = nil,
        faceValue: Int? = nil
    ) {
        self.model = model
        self.gameMode = gameMode
        self.value = faceValue ?? model.peakValue ?? 1
        self.displayNumber = displayNumber ?? model.peakValue ?? 1
        self.isValueMatching = self.value == self.displayNumber
        self.tileKind = kind
        
        // Create texture from image
        // Check if image exists, if not create a placeholder
        let imageToUse: UIImage
        if let peakImage = model.peakImage {
            // Apply rounded corners to the image (corner radius: 6)
            imageToUse = PeakTile.addRoundedCorners(to: peakImage, cornerRadius: 6, size: size)
        } else {
            // Create a placeholder image with a solid color
            imageToUse = PeakTile.createPlaceholderImage(size: size, value: model.peakValue ?? 1)
        }
        
        let texture = SKTexture(image: imageToUse)
        super.init(texture: texture, color: .clear, size: size)
        
        setupTile()
        
        switch kind {
        case .multiplier:
            setupMultiplierBackground(size: size)
        case .bomb:
            setupBombBackground(size: size)
        case .obstacle:
            setupObstacleBackground(size: size)
        case .normal:
            break
        }
        
        if gameMode == .matchChallenge {
            setupMatchChallengeUI(size: size)
        }
    }
    
    /// Add rounded corners to an image
    private static func addRoundedCorners(to image: UIImage, cornerRadius: CGFloat, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
            path.addClip()
            image.draw(in: rect)
        }
    }
    
    /// Create a placeholder image when the actual image fails to load
    private static func createPlaceholderImage(size: CGSize, value: Int) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            UIColor.systemBlue.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Add text to indicate missing image
            let text = "\(value)"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: size.height * 0.3, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let attributedString = NSAttributedString(string: text, attributes: attributes)
            let textSize = attributedString.size()
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            attributedString.draw(in: textRect)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupTile() {
        // Enable user interaction
        isUserInteractionEnabled = true
        
        // Set anchor point to bottom center for stacking
        anchorPoint = CGPoint(x: 0.5, y: 0.0)
        
        // Ensure tile is visible above background
        zPosition = 10
        
        // Border removed as requested
        // createBorder()
        
        // Create click label
        createClickLabel()
        
        // Add physics body for collision detection and gravity
        // Since anchorPoint is (0.5, 0.0), position is at bottom center
        // We need to create a physics body that aligns with the visual bounds
        // Create a path that matches the visual rectangle
        let physicsPath = UIBezierPath(rect: CGRect(
            x: -size.width / 2,
            y: 0,
            width: size.width,
            height: size.height
        ))
        physicsBody = SKPhysicsBody(polygonFrom: physicsPath.cgPath)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = true  // Enable gravity
        physicsBody?.categoryBitMask = PhysicsCategory.tile
        physicsBody?.contactTestBitMask = PhysicsCategory.container
    }
    
    /// Setup special background for multiplier tiles
    private func setupMultiplierBackground(size: CGSize) {
        // Create a glowing border that follows the image edges
        // Since anchorPoint is (0.5, 0.0), the image bounds are:
        // Left: -size.width/2, Right: size.width/2
        // Bottom: 0, Top: size.height
        
        let cornerRadius: CGFloat = 6
        let glowRect = CGRect(
            x: -size.width / 2,
            y: 0,
            width: size.width,
            height: size.height
        )
        let glowPath = UIBezierPath(roundedRect: glowRect, cornerRadius: cornerRadius)
        
        // Create border node that follows the image edge
        glowNode = SKShapeNode(path: glowPath.cgPath)
        glowNode?.fillColor = .clear
        glowNode?.strokeColor = UIColor.systemYellow
        glowNode?.lineWidth = 4.0
        glowNode?.zPosition = 15  // Above the tile image
        glowNode?.position = .zero  // Position at node's origin (which is anchor point)
        
        // Add pulsing animation
        let pulseUp = SKAction.scale(to: 1.02, duration: 0.8)
        let pulseDown = SKAction.scale(to: 0.98, duration: 0.8)
        let pulseSequence = SKAction.sequence([pulseUp, pulseDown])
        let pulseForever = SKAction.repeatForever(pulseSequence)
        glowNode?.run(pulseForever)
        
        if let glow = glowNode {
            addChild(glow)
        }
        
        let overlayNode = SKShapeNode(path: glowPath.cgPath)
        overlayNode.fillColor = UIColor.systemYellow.withAlphaComponent(0.15)
        overlayNode.strokeColor = .clear
        overlayNode.zPosition = 14
        overlayNode.position = .zero
        addChild(overlayNode)
    }
    
    /// 炸弹牌橙色描边
    private func setupBombBackground(size: CGSize) {
        let glowRect = CGRect(x: -size.width / 2, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: glowRect, cornerRadius: 6)
        glowNode = SKShapeNode(path: path.cgPath)
        glowNode?.fillColor = .clear
        glowNode?.strokeColor = UIColor.systemOrange
        glowNode?.lineWidth = 4
        glowNode?.zPosition = 15
        if let glow = glowNode { addChild(glow) }
    }
    
    /// 障碍牌红色描边
    private func setupObstacleBackground(size: CGSize) {
        let glowRect = CGRect(x: -size.width / 2, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: glowRect, cornerRadius: 6)
        glowNode = SKShapeNode(path: path.cgPath)
        glowNode?.fillColor = UIColor.systemRed.withAlphaComponent(0.12)
        glowNode?.strokeColor = UIColor.systemRed
        glowNode?.lineWidth = 3
        glowNode?.zPosition = 15
        if let glow = glowNode { addChild(glow) }
    }
    
    /// Create a border with rounded corners (corner radius: 3.5)
    private func createBorder() {
        let borderRect = CGRect(origin: .zero, size: size)
        let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: 3.5)
        
        borderNode = SKShapeNode(path: borderPath.cgPath)
        borderNode?.strokeColor = .white
        borderNode?.lineWidth = 2.0
        borderNode?.fillColor = .clear
        borderNode?.position = CGPoint(x: -size.width / 2, y: -size.height / 2)
        
        if let border = borderNode {
            addChild(border)
        }
    }
    
    /// Create label showing remaining clicks
    private func createClickLabel() {
        // Create stroke/outline label first (behind main label)
        strokeLabel = SKLabelNode(fontNamed: "Avenir-Black")
        strokeLabel?.fontSize = 36
        strokeLabel?.fontColor = .black
        strokeLabel?.zPosition = 19
        strokeLabel?.position = CGPoint(x: 0, y: size.height / 2 - 20)
        strokeLabel?.horizontalAlignmentMode = .center
        strokeLabel?.verticalAlignmentMode = .center
        
        // Create main label (white text on top)
        clickLabel = SKLabelNode(fontNamed: "Avenir-Black")
        // Make font size larger and more prominent
        clickLabel?.fontSize = 32
        clickLabel?.fontColor = .white
        clickLabel?.zPosition = 20  // Higher zPosition to ensure visibility
        clickLabel?.position = CGPoint(x: 0, y: size.height / 2 - 20)
        clickLabel?.horizontalAlignmentMode = .center
        clickLabel?.verticalAlignmentMode = .center
        
        updateClickLabel()
        
        // Add stroke label first, then main label
        if let stroke = strokeLabel {
            addChild(stroke)
        }
        if let label = clickLabel {
            addChild(label)
        }
    }
    
    /// 匹配模式：配置数字标签、删除按钮与匹配指示
    private func setupMatchChallengeUI(size: CGSize) {
        clickLabel?.fontSize = 34
        strokeLabel?.fontSize = 38
        updateClickLabel()
        setupDeleteButton(size: size)
        setupMatchIndicator(size: size)
    }
    
    /// 匹配模式：右上角删除按钮
    private func setupDeleteButton(size: CGSize) {
        let buttonSize: CGFloat = min(size.width, size.height) * 0.28
        let container = SKNode()
        container.name = "deleteButton"
        container.zPosition = 25
        container.position = CGPoint(
            x: size.width / 2 - buttonSize * 0.35,
            y: size.height - buttonSize * 0.35
        )
        
        let circle = SKShapeNode(circleOfRadius: buttonSize / 2)
        circle.fillColor = UIColor.systemRed.withAlphaComponent(0.92)
        circle.strokeColor = .white
        circle.lineWidth = 1.5
        container.addChild(circle)
        
        let cross = SKLabelNode(fontNamed: "Avenir-Black")
        cross.text = "×"
        cross.fontSize = buttonSize * 0.85
        cross.fontColor = .white
        cross.verticalAlignmentMode = .center
        cross.horizontalAlignmentMode = .center
        cross.position = CGPoint(x: 0, y: -buttonSize * 0.06)
        container.addChild(cross)
        
        addChild(container)
        deleteButtonNode = container
    }
    
    /// 匹配模式：绿/橙描边提示是否匹配
    private func setupMatchIndicator(size: CGSize) {
        let rect = CGRect(x: -size.width / 2, y: 0, width: size.width, height: size.height)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 6)
        matchIndicatorNode = SKShapeNode(path: path.cgPath)
        matchIndicatorNode?.fillColor = .clear
        matchIndicatorNode?.lineWidth = 3
        matchIndicatorNode?.zPosition = 12
        updateMatchIndicatorAppearance()
        if let node = matchIndicatorNode {
            addChild(node)
        }
    }
    
    /// 更新匹配指示描边颜色
    private func updateMatchIndicatorAppearance() {
        if isValueMatching {
            matchIndicatorNode?.strokeColor = UIColor.systemGreen.withAlphaComponent(0.85)
        } else {
            matchIndicatorNode?.strokeColor = UIColor.systemOrange.withAlphaComponent(0.9)
        }
    }
    
    /// 判断触摸是否落在删除按钮区域
    private func isTouchOnDeleteButton(_ location: CGPoint) -> Bool {
        guard let deleteButton = deleteButtonNode else { return false }
        let local = deleteButton.convert(location, from: self)
        let radius = deleteButton.calculateAccumulatedFrame().width / 2
        return hypot(local.x, local.y) <= radius + 4
    }
    
    /// Update the click label text
    func updateClickLabel() {
        if gameMode == .matchChallenge {
            let text = "\(displayNumber)"
            clickLabel?.text = text
            strokeLabel?.text = text
            if isValueMatching {
                clickLabel?.fontColor = .systemGreen
                strokeLabel?.fontColor = .black
            } else {
                clickLabel?.fontColor = .systemOrange
                strokeLabel?.fontColor = .black
            }
            updateMatchIndicatorAppearance()
            return
        }
        
        let remaining = requiredClicks - clickCount
        let text = "\(max(0, remaining))"
        clickLabel?.text = text
        strokeLabel?.text = text
        if isObstacleTile {
            clickLabel?.fontColor = remaining > 0 ? .systemRed : .green
        } else if isBombTile {
            clickLabel?.fontColor = remaining > 0 ? .systemOrange : .green
        } else {
            clickLabel?.fontColor = remaining > 0 ? .white : .green
        }
        strokeLabel?.fontColor = remaining > 0 ? .black : .darkGray
    }
    
    // MARK: - Interaction
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first, !isRemoving else { return }
        let location = touch.location(in: self)
        
        if gameMode == .matchChallenge {
            handleMatchChallengeTouch(at: location)
            return
        }
        
        clickCount += 1
        addClickAnimation()
        updateClickLabel()
        
        if clickCount >= requiredClicks && !isRemoving {
            removeTile(reason: .scored)
        }
    }
    
    /// 匹配模式触摸：删除按钮移出；匹配牌点击得分
    private func handleMatchChallengeTouch(at location: CGPoint) {
        if isTouchOnDeleteButton(location) {
            addClickAnimation()
            removeTile(reason: .dismissed)
            return
        }
        
        guard isValueMatching else {
            shakeMismatchFeedback()
            return
        }
        
        addClickAnimation()
        removeTile(reason: .scored)
    }
    
    /// 不匹配时点击牌面的晃动反馈
    private func shakeMismatchFeedback() {
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -6, y: 0, duration: 0.04),
            SKAction.moveBy(x: 12, y: 0, duration: 0.08),
            SKAction.moveBy(x: -6, y: 0, duration: 0.04)
        ])
        run(shake)
    }
    
    /// Add animation when tile is clicked
    private func addClickAnimation() {
        // Scale animation
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        
        // Color pulse animation
        let colorize = SKAction.colorize(with: .yellow, colorBlendFactor: 0.3, duration: 0.1)
        let decolorize = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        let colorSequence = SKAction.sequence([colorize, decolorize])
        
        // Run animations together
        run(scaleSequence)
        run(colorSequence)
    }
    
    /// Remove tile with explosion animation
    func removeTile(reason: PeakTileRemovalReason = .scored) {
        guard !isRemoving else { return }
        isRemoving = true
        
        // Disable physics during explosion
        physicsBody?.isDynamic = false
        
        // Create explosion effect
        createExplosionEffect()
        
        // Explosion animation sequence with more dramatic effects
        let explodeScaleUp = SKAction.scale(to: 1.3, duration: 0.1)
        let explodeScaleDown = SKAction.scale(to: 0.0, duration: 0.2)
        let explodeRotate = SKAction.rotate(byAngle: .pi * 1.5, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([
            explodeScaleUp,
            SKAction.group([explodeScaleDown, explodeRotate, fadeOut]),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                if self.isBombTile {
                    self.tileDelegate?.bombTileDidExplode(self)
                }
                self.tileDelegate?.tileWasRemoved(self, reason: reason)
            },
            remove
        ])
        
        run(sequence)
    }
    
    /// Create explosion particle effect
    private func createExplosionEffect() {
        guard let parent = parent else { return }
        
        let particleCount = 16
        let colors: [UIColor] = [
            .systemYellow,
            .systemOrange,
            .systemRed,
            .white,
            UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)  // Gold
        ]
        
        // Create multiple particles for explosion (radial pattern)
        for i in 0..<particleCount {
            let angle = (CGFloat(i) / CGFloat(particleCount)) * .pi * 2
            let baseDistance = size.width * 1.2
            let randomVariation = CGFloat.random(in: 0.7...1.3)
            let distance = baseDistance * randomVariation
            let endX = cos(angle) * distance
            let endY = sin(angle) * distance
            
            // Create particle with varying sizes
            let particleSize = CGFloat.random(in: 3...6)
            let particle = SKShapeNode(circleOfRadius: particleSize)
            particle.fillColor = colors.randomElement() ?? .systemYellow
            particle.strokeColor = .clear
            particle.position = position  // Start at tile position
            particle.zPosition = 50  // Above everything
            particle.alpha = 1.0
            
            parent.addChild(particle)
            
            // Animate particle with easing
            let moveAction = SKAction.moveBy(x: endX, y: endY, duration: 0.5)
            moveAction.timingMode = .easeOut
            let fadeAction = SKAction.fadeOut(withDuration: 0.5)
            let scaleAction = SKAction.scale(to: 0.0, duration: 0.5)
            let removeAction = SKAction.removeFromParent()
            
            let particleSequence = SKAction.sequence([
                SKAction.group([moveAction, fadeAction, scaleAction]),
                removeAction
            ])
            
            particle.run(particleSequence)
        }
        
        // Create sparkle effect (smaller, faster particles)
        for _ in 0..<8 {
            let sparkle = SKShapeNode(circleOfRadius: 2)
            sparkle.fillColor = .white
            sparkle.strokeColor = .clear
            sparkle.position = position
            sparkle.zPosition = 51
            sparkle.alpha = 1.0
            
            parent.addChild(sparkle)
            
            let randomAngle = CGFloat.random(in: 0...(2 * .pi))
            let randomDistance = CGFloat.random(in: size.width * 0.4...size.width * 0.8)
            let sparkleX = cos(randomAngle) * randomDistance
            let sparkleY = sin(randomAngle) * randomDistance
            
            let sparkleMove = SKAction.moveBy(x: sparkleX, y: sparkleY, duration: 0.25)
            sparkleMove.timingMode = .easeOut
            let sparkleFade = SKAction.fadeOut(withDuration: 0.25)
            let sparkleScale = SKAction.scale(to: 0.0, duration: 0.25)
            let sparkleRemove = SKAction.removeFromParent()
            
            let sparkleSequence = SKAction.sequence([
                SKAction.group([sparkleMove, sparkleFade, sparkleScale]),
                sparkleRemove
            ])
            
            sparkle.run(sparkleSequence)
        }
        
        // Add a bright flash effect (white burst)
        let flash = SKShapeNode(rect: CGRect(
            x: -size.width / 2,
            y: 0,
            width: size.width,
            height: size.height
        ))
        flash.fillColor = .white
        flash.strokeColor = .clear
        flash.position = position
        flash.zPosition = 49
        flash.alpha = 0.8
        
        parent.addChild(flash)
        
        let flashScale = SKAction.scale(to: 1.5, duration: 0.1)
        let flashFade = SKAction.fadeOut(withDuration: 0.2)
        let flashRemove = SKAction.removeFromParent()
        flash.run(SKAction.sequence([
            flashScale,
            SKAction.group([flashFade, SKAction.scale(to: 0.0, duration: 0.2)]),
            flashRemove
        ]))
    }
    
    /// Get the bottom position of the tile
    func getBottomPosition() -> CGFloat {
        return position.y
    }
    
    /// Get the top position of the tile
    func getTopPosition() -> CGFloat {
        return position.y + size.height
    }
}

// MARK: - Physics Categories

struct PhysicsCategory {
    static let none: UInt32 = 0
    static let tile: UInt32 = 0b1
    static let container: UInt32 = 0b10
    static let powerUp: UInt32 = 0b100
}

