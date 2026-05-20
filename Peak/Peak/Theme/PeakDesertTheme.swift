//
//  PeakDesertTheme.swift
//  Peak
//
//  动漫沙漠风格主题：渐变色、标签与控件样式
//

import UIKit

/// 动漫沙漠风格配色与 UI 样式工具
enum PeakDesertTheme {
    
    // MARK: - 天空与沙地渐变色
    
    static let skyTop = UIColor(red: 0.42, green: 0.78, blue: 0.98, alpha: 1.0)
    static let skyMid = UIColor(red: 0.98, green: 0.72, blue: 0.52, alpha: 1.0)
    static let sandLight = UIColor(red: 0.96, green: 0.82, blue: 0.52, alpha: 1.0)
    static let sandDeep = UIColor(red: 0.88, green: 0.58, blue: 0.32, alpha: 1.0)
    static let sandDusk = UIColor(red: 0.72, green: 0.38, blue: 0.28, alpha: 1.0)
    
    static let textPrimary = UIColor(red: 1.0, green: 0.97, blue: 0.90, alpha: 1.0)
    static let textSecondary = UIColor(red: 1.0, green: 0.92, blue: 0.78, alpha: 0.92)
    static let textAccent = UIColor(red: 1.0, green: 0.84, blue: 0.35, alpha: 1.0)
    static let textMuted = UIColor(red: 1.0, green: 0.90, blue: 0.75, alpha: 0.72)
    
    static let shadowBrown = UIColor(red: 0.35, green: 0.18, blue: 0.08, alpha: 1.0)
    static let cardFill = UIColor(red: 0.25, green: 0.14, blue: 0.08, alpha: 0.35)
    static let cardBorder = UIColor(red: 1.0, green: 0.88, blue: 0.55, alpha: 0.45)
    
    static let playStart = UIColor(red: 0.95, green: 0.45, blue: 0.28, alpha: 1.0)
    static let playEnd = UIColor(red: 0.82, green: 0.28, blue: 0.22, alpha: 1.0)
    static let guideStart = UIColor(red: 0.55, green: 0.78, blue: 0.42, alpha: 1.0)
    static let guideEnd = UIColor(red: 0.32, green: 0.58, blue: 0.35, alpha: 1.0)
    static let recordsStart = UIColor(red: 0.98, green: 0.68, blue: 0.22, alpha: 1.0)
    static let recordsEnd = UIColor(red: 0.85, green: 0.45, blue: 0.12, alpha: 1.0)
    static let pauseStart = UIColor(red: 0.45, green: 0.62, blue: 0.88, alpha: 0.95)
    static let pauseEnd = UIColor(red: 0.28, green: 0.42, blue: 0.72, alpha: 0.95)
    static let resumeStart = UIColor(red: 0.42, green: 0.78, blue: 0.52, alpha: 0.95)
    static let resumeEnd = UIColor(red: 0.22, green: 0.58, blue: 0.38, alpha: 0.95)
    
    /// 圆角系统字体（偏动漫感）
    static func roundedFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = base.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return base
    }
    
    /// 主标题样式
    static func applyHeroTitleStyle(to label: UILabel) {
        label.font = roundedFont(size: 38, weight: .heavy)
        label.textColor = textPrimary
        label.textAlignment = .center
        label.layer.shadowColor = shadowBrown.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 3)
        label.layer.shadowOpacity = 0.65
        label.layer.shadowRadius = 6
    }
    
    /// 副标题 / 章节标题
    static func applySectionTitleStyle(to label: UILabel, size: CGFloat = 22) {
        label.font = roundedFont(size: size, weight: .bold)
        label.textColor = textPrimary
        label.textAlignment = .center
        label.layer.shadowColor = shadowBrown.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowOpacity = 0.5
        label.layer.shadowRadius = 4
    }
    
    /// 正文说明
    static func applyBodyStyle(to label: UILabel, size: CGFloat = 17) {
        label.font = roundedFont(size: size, weight: .medium)
        label.textColor = textSecondary
    }
    
    /// 高亮数值（分数、时间等）
    static func applyHighlightStyle(to label: UILabel, size: CGFloat = 20) {
        label.font = roundedFont(size: size, weight: .bold)
        label.textColor = textAccent
        label.layer.shadowColor = shadowBrown.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowOpacity = 0.45
        label.layer.shadowRadius = 3
    }
    
    /// HUD 信息条样式
    static func applyHUDStyle(to label: UILabel, size: CGFloat = 16) {
        label.font = roundedFont(size: size, weight: .bold)
        label.textColor = textPrimary
        label.textAlignment = .center
        label.layer.shadowColor = shadowBrown.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowOpacity = 0.4
        label.layer.shadowRadius = 2
    }
    
    /// 毛玻璃卡片容器
    static func styleCard(_ view: UIView, cornerRadius: CGFloat = 16) {
        view.backgroundColor = cardFill
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = 1.5
        view.layer.borderColor = cardBorder.cgColor
        view.layer.shadowColor = shadowBrown.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowOpacity = 0.25
        view.layer.shadowRadius = 8
    }
    
    /// 为按钮插入双色渐变层
    @discardableResult
    static func applyButtonGradient(to button: UIButton, colors: [UIColor], cornerRadius: CGFloat) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = cornerRadius
        gradient.frame = button.bounds
        button.layer.insertSublayer(gradient, at: 0)
        button.layer.cornerRadius = cornerRadius
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.35).cgColor
        button.layer.shadowColor = shadowBrown.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 5)
        button.layer.shadowOpacity = 0.35
        button.layer.shadowRadius = 8
        button.setTitleColor(textPrimary, for: .normal)
        button.titleLabel?.font = roundedFont(size: 20, weight: .bold)
        return gradient
    }
    
    /// 更新按钮内渐变层尺寸
    static func updateGradientFrame(in button: UIButton) {
        button.layer.sublayers?
            .compactMap { $0 as? CAGradientLayer }
            .forEach { $0.frame = button.bounds }
    }
    
    /// 次要描边按钮（返回等）
    static func styleSecondaryButton(_ button: UIButton, fontSize: CGFloat = 15) {
        button.titleLabel?.font = roundedFont(size: fontSize, weight: .semibold)
        button.setTitleColor(textPrimary, for: .normal)
        button.backgroundColor = UIColor(red: 0.2, green: 0.12, blue: 0.06, alpha: 0.35)
        button.layer.cornerRadius = 18
        button.layer.borderWidth = 2
        button.layer.borderColor = cardBorder.cgColor
    }
    
    /// 分段选择器沙漠风格
    static func styleSegmentedControl(_ control: UISegmentedControl) {
        control.backgroundColor = UIColor(red: 0.2, green: 0.12, blue: 0.06, alpha: 0.4)
        control.selectedSegmentTintColor = UIColor(red: 0.92, green: 0.55, blue: 0.22, alpha: 1.0)
        let normal: [NSAttributedString.Key: Any] = [
            .foregroundColor: textMuted,
            .font: roundedFont(size: 14, weight: .semibold)
        ]
        let selected: [NSAttributedString.Key: Any] = [
            .foregroundColor: textPrimary,
            .font: roundedFont(size: 14, weight: .bold)
        ]
        control.setTitleTextAttributes(normal, for: .normal)
        control.setTitleTextAttributes(selected, for: .selected)
    }
}

/// 遮罩强度（叠在渐变之上的暖色薄层）
enum DesertOverlayIntensity {
    case none
    case light
    case medium
}

/// 动漫沙漠渐变背景视图（天空 → 落日 → 沙丘）
final class DesertGradientBackgroundView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let sunGlowLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    /// 配置渐变与太阳光晕
    private func setupLayers() {
        gradientLayer.colors = [
            PeakDesertTheme.skyTop.cgColor,
            PeakDesertTheme.skyMid.cgColor,
            PeakDesertTheme.sandLight.cgColor,
            PeakDesertTheme.sandDeep.cgColor,
            PeakDesertTheme.sandDusk.cgColor
        ]
        gradientLayer.locations = [0.0, 0.35, 0.62, 0.85, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        layer.insertSublayer(gradientLayer, at: 0)
        
        sunGlowLayer.type = .radial
        sunGlowLayer.colors = [
            UIColor(red: 1.0, green: 0.95, blue: 0.55, alpha: 0.55).cgColor,
            UIColor(red: 1.0, green: 0.75, blue: 0.35, alpha: 0.0).cgColor
        ]
        sunGlowLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        sunGlowLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.insertSublayer(sunGlowLayer, above: gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        let sunSize = min(bounds.width, bounds.height) * 0.85
        sunGlowLayer.frame = CGRect(
            x: bounds.midX - sunSize * 0.35,
            y: bounds.height * 0.08,
            width: sunSize,
            height: sunSize
        )
    }
}

extension UIViewController {
    
    /// 在控制器根视图上安装沙漠渐变背景与可选遮罩
    @discardableResult
    func installDesertBackground(overlay: DesertOverlayIntensity = .light) -> (background: DesertGradientBackgroundView, overlay: UIView?) {
        let background = DesertGradientBackgroundView(frame: view.bounds)
        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        background.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(background, at: 0)
        
        NSLayoutConstraint.activate([
            background.topAnchor.constraint(equalTo: view.topAnchor),
            background.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            background.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            background.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        var overlayView: UIView?
        switch overlay {
        case .none:
            break
        case .light:
            let ov = UIView()
            ov.isUserInteractionEnabled = false
            ov.backgroundColor = UIColor(red: 0.45, green: 0.22, blue: 0.10, alpha: 0.12)
            ov.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(ov, aboveSubview: background)
            NSLayoutConstraint.activate([
                ov.topAnchor.constraint(equalTo: view.topAnchor),
                ov.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                ov.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                ov.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            overlayView = ov
        case .medium:
            let ov = UIView()
            ov.isUserInteractionEnabled = false
            ov.backgroundColor = UIColor(red: 0.35, green: 0.16, blue: 0.06, alpha: 0.28)
            ov.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(ov, aboveSubview: background)
            NSLayoutConstraint.activate([
                ov.topAnchor.constraint(equalTo: view.topAnchor),
                ov.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                ov.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                ov.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            overlayView = ov
        }
        
        view.backgroundColor = PeakDesertTheme.sandDusk
        return (background, overlayView)
    }
}

/// 为标签添加胶囊形 HUD 背景
final class DesertHUDCapsuleView: UIView {
    
    let label = UILabel()
    
    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        PeakDesertTheme.styleCard(self, cornerRadius: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
