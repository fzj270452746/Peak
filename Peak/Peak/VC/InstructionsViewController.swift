

import UIKit

/// 游戏说明界面
class InstructionsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var backButton: UIButton!
    private var contentCard: UIView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        _ = installDesertBackground(overlay: .medium)
        
        setupBackButton()
        setupScrollView()
        setupContent()
    }
    
    private func setupBackButton() {
        backButton = UIButton(type: .system)
        backButton.setTitle("← Back", for: .normal)
        PeakDesertTheme.styleSecondaryButton(backButton, fontSize: 16)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 100),
            backButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupContent() {
        let titleLabel = UILabel()
        titleLabel.text = "How to Play"
        PeakDesertTheme.applySectionTitleStyle(to: titleLabel, size: 28)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        contentCard = UIView()
        PeakDesertTheme.styleCard(contentCard, cornerRadius: 20)
        contentCard.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(contentCard)
        
        let instructionsText = """
        🎮 CLASSIC MODE
        
        Tap tiles to eliminate them. Each tile requires taps equal to its value (shown on the tile).
        
        🎯 CLASSIC SCORING
        
        • Eliminate tiles: value × 10 points
        • Golden tiles: 2× score multiplier
        
        ⚡ POWER-UP BALLS (Classic only)
        
        • Red ball (⚡ Speed Up): Tiles fall 50% faster for 5 seconds
        • Blue ball (🐌 Speed Down): Tiles fall 50% slower for 5 seconds
        • Freeze, Clear Top, and Lucky Wheel also appear randomly
        
        🧩 MATCH & CLEAR MODE
        
        Some tiles have matching face value and displayed number (green border). Others do not (orange border).
        
        • Tap a matching tile once to score (value × 10)
        • Tap the red × button on a mismatched tile to remove it without scoring
        • Tapping a mismatched tile body does nothing useful — use delete!
        
        ⚠️ GAME OVER
        
        Game ends when tiles fill the grass-bordered pool (stack reaches the pool top edge).
        
        💡 TIP
        
        In Match & Clear, clear mismatches quickly before the pool fills up!
        """
        
        let instructionsLabel = UILabel()
        instructionsLabel.text = instructionsText
        PeakDesertTheme.applyBodyStyle(to: instructionsLabel, size: 16)
        instructionsLabel.numberOfLines = 0
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        contentCard.addSubview(instructionsLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            contentCard.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            contentCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentCard.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            instructionsLabel.topAnchor.constraint(equalTo: contentCard.topAnchor, constant: 20),
            instructionsLabel.leadingAnchor.constraint(equalTo: contentCard.leadingAnchor, constant: 20),
            instructionsLabel.trailingAnchor.constraint(equalTo: contentCard.trailingAnchor, constant: -20),
            instructionsLabel.bottomAnchor.constraint(equalTo: contentCard.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
