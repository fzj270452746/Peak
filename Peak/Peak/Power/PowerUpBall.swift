//
//  PowerUpBall.swift
//  Peak
//
//  Created by Zhao on 2025/12/29.
//

import SpriteKit

/// 道具球类型
enum PowerUpType {
    case speedUp
    case speedDown
    case freeze
    case clearLayer
    case luckyWheel
}

protocol PowerUpBallDelegate: AnyObject {
    func powerUpWasActivated(type: PowerUpType)
}

/// 可点击掉落的道具球
class PowerUpBall: SKShapeNode {
    
    var powerUpType: PowerUpType
    weak var powerUpDelegate: PowerUpBallDelegate?
    
    private var isActivated: Bool = false
    private var ballSize: CGFloat
    
    init(type: PowerUpType, size: CGFloat) {
        self.powerUpType = type
        self.ballSize = size
        
        let circlePath = UIBezierPath(arcCenter: .zero, radius: size / 2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
        super.init()
        
        self.path = circlePath.cgPath
        applyAppearance(for: type)
        
        lineWidth = 2.0
        zPosition = 100
        
        setupPowerUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 根据类型设置颜色
    private func applyAppearance(for type: PowerUpType) {
        switch type {
        case .speedUp:
            fillColor = UIColor.systemRed
            strokeColor = UIColor.white
        case .speedDown:
            fillColor = UIColor.systemBlue
            strokeColor = UIColor.white
        case .freeze:
            fillColor = UIColor.systemTeal
            strokeColor = UIColor.white
        case .clearLayer:
            fillColor = UIColor.systemGreen
            strokeColor = UIColor.white
        case .luckyWheel:
            fillColor = UIColor.systemPurple
            strokeColor = UIColor.systemYellow
        }
    }
    
    /// 初始化物理与动画
    private func setupPowerUp() {
        isUserInteractionEnabled = true
        
        let pulseUp = SKAction.scale(to: 1.2, duration: 0.8)
        let pulseDown = SKAction.scale(to: 1.0, duration: 0.8)
        run(SKAction.repeatForever(SKAction.sequence([pulseUp, pulseDown])))
        
        let rotate = SKAction.rotate(byAngle: .pi * 2, duration: 2.0)
        run(SKAction.repeatForever(rotate))
        
        physicsBody = SKPhysicsBody(circleOfRadius: ballSize / 2)
        physicsBody?.isDynamic = true
        physicsBody?.affectedByGravity = true
        physicsBody?.categoryBitMask = PhysicsCategory.powerUp
        physicsBody?.contactTestBitMask = PhysicsCategory.none
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard !isActivated else { return }
        isActivated = true
        activatePowerUp()
    }
    
    /// 触发道具效果
    private func activatePowerUp() {
        powerUpDelegate?.powerUpWasActivated(type: powerUpType)
        createActivationEffect()
        
        let sequence = SKAction.sequence([
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.2),
                SKAction.scale(to: 2.0, duration: 0.2)
            ]),
            SKAction.removeFromParent()
        ])
        run(sequence)
    }
    
    /// 点击爆炸粒子
    private func createActivationEffect() {
        guard let parent = parent else { return }
        
        let colors: [UIColor]
        switch powerUpType {
        case .speedUp:
            colors = [.systemRed, .systemOrange, .systemYellow]
        case .speedDown:
            colors = [.systemBlue, UIColor(red: 0, green: 1, blue: 1, alpha: 1), .white]
        case .freeze:
            colors = [.systemTeal, .white, UIColor(red: 0, green: 1, blue: 1, alpha: 1)]
        case .clearLayer:
            colors = [.systemGreen, .systemYellow, .white]
        case .luckyWheel:
            colors = [.systemPurple, .systemPink, .systemYellow]
        }
        
        for i in 0..<8 {
            let angle = (CGFloat(i) / 8.0) * .pi * 2
            let endX = cos(angle) * 30
            let endY = sin(angle) * 30
            
            let particle = SKShapeNode(circleOfRadius: 3)
            particle.fillColor = colors.randomElement() ?? .white
            particle.strokeColor = .clear
            particle.position = position
            particle.zPosition = 50
            
            parent.addChild(particle)
            particle.run(SKAction.sequence([
                SKAction.group([
                    SKAction.moveBy(x: endX, y: endY, duration: 0.3),
                    SKAction.fadeOut(withDuration: 0.3),
                    SKAction.scale(to: 0, duration: 0.3)
                ]),
                SKAction.removeFromParent()
            ]))
        }
    }
}
