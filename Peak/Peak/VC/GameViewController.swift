
import UIKit
import SpriteKit

/// 游戏主界面控制器
class GameViewController: UIViewController {
    
    // MARK: - Properties
    
    private var skView: SKView!
    private var gameScene: GameScene!
    
    /// 本局难度
    var gameDifficulty: GameDifficulty = GameSettings.selectedDifficulty
    
    /// 本局游戏模式
    var gameMode: GameMode = GameSettings.selectedGameMode
    
    /// 危险预警边框层
    private var dangerWarningOverlay: UIView!
    
    /// 难度与模式标签
    private var difficultyLabel: UILabel!
    private var gameModeLabel: UILabel!
    
    /// 是否已触发过预警震动
    private var didTriggerWarningHaptic = false
    
    /// 沙漠渐变背景
    private var desertBackground: DesertGradientBackgroundView!
    /// 背景遮罩（不可拦截触摸）
    private var desertOverlay: UIView?
    
    /// Score label
    private var scoreHUD: DesertHUDCapsuleView!
    private var scoreLabel: UILabel!
    
    /// Time label
    private var timeHUD: DesertHUDCapsuleView!
    private var timeLabel: UILabel!
    
    /// Power-up message label
    private var powerUpMessageLabel: UILabel!
    
    /// Pause button
    private var pauseButton: UIButton!
    
    /// Back button
    private var backButton: UIButton!
    
    /// Game over view
    private var gameOverView: UIView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupGameScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameScene.pauseGame()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        PeakDesertTheme.updateGradientFrame(in: pauseButton)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        let installed = installDesertBackground(overlay: .light)
        desertBackground = installed.background
        desertOverlay = installed.overlay
        
        // Setup score label
        setupScoreLabel()
        
        // Setup time label
        setupTimeLabel()
        
        // Setup power-up message label
        setupPowerUpMessageLabel()
        
        // Setup pause button
        setupPauseButton()
        
        // Setup back button
        setupBackButton()
        
        // Setup game over view
        setupGameOverView()
        
        setupDangerWarningOverlay()
        setupDifficultyLabel()
    }
    
    /// 危险预警红色边框
    private func setupDangerWarningOverlay() {
        dangerWarningOverlay = UIView(frame: view.bounds)
        dangerWarningOverlay.backgroundColor = .clear
        dangerWarningOverlay.layer.borderWidth = 0
        dangerWarningOverlay.layer.borderColor = UIColor.systemRed.cgColor
        dangerWarningOverlay.isUserInteractionEnabled = false
        dangerWarningOverlay.alpha = 0
        dangerWarningOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dangerWarningOverlay)
        
        NSLayoutConstraint.activate([
            dangerWarningOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            dangerWarningOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dangerWarningOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dangerWarningOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    /// 显示当前难度与游戏模式
    private func setupDifficultyLabel() {
        difficultyLabel = UILabel()
        difficultyLabel.text = gameDifficulty.displayName.uppercased()
        difficultyLabel.font = PeakDesertTheme.roundedFont(size: 12, weight: .bold)
        difficultyLabel.textColor = PeakDesertTheme.textMuted
        difficultyLabel.textAlignment = .center
        difficultyLabel.isUserInteractionEnabled = false
        difficultyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(difficultyLabel)
        
        gameModeLabel = UILabel()
        gameModeLabel.text = gameMode.displayName
        gameModeLabel.font = PeakDesertTheme.roundedFont(size: 11, weight: .semibold)
        gameModeLabel.textColor = PeakDesertTheme.textSecondary
        gameModeLabel.textAlignment = .center
        gameModeLabel.isUserInteractionEnabled = false
        gameModeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gameModeLabel)
        
        NSLayoutConstraint.activate([
            difficultyLabel.topAnchor.constraint(equalTo: timeHUD.bottomAnchor, constant: 6),
            difficultyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            difficultyLabel.heightAnchor.constraint(equalToConstant: 18),
            
            gameModeLabel.topAnchor.constraint(equalTo: difficultyLabel.bottomAnchor, constant: 2),
            gameModeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gameModeLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    private func setupScoreLabel() {
        scoreHUD = DesertHUDCapsuleView()
        scoreHUD.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreHUD)
        
        scoreLabel = scoreHUD.label
        scoreLabel.text = "Score: 0"
        PeakDesertTheme.applyHUDStyle(to: scoreLabel, size: 15)
        
        NSLayoutConstraint.activate([
            scoreHUD.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scoreHUD.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupTimeLabel() {
        timeHUD = DesertHUDCapsuleView()
        timeHUD.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timeHUD)
        
        timeLabel = timeHUD.label
        timeLabel.text = "Time: 00:00"
        PeakDesertTheme.applyHighlightStyle(to: timeLabel, size: 18)
        
        NSLayoutConstraint.activate([
            timeHUD.topAnchor.constraint(equalTo: scoreHUD.bottomAnchor, constant: 8),
            timeHUD.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupPowerUpMessageLabel() {
        powerUpMessageLabel = UILabel()
        powerUpMessageLabel.text = ""
        powerUpMessageLabel.font = PeakDesertTheme.roundedFont(size: 34, weight: .heavy)
        powerUpMessageLabel.textColor = PeakDesertTheme.textPrimary
        powerUpMessageLabel.textAlignment = .center
        powerUpMessageLabel.layer.shadowColor = PeakDesertTheme.shadowBrown.cgColor
        powerUpMessageLabel.layer.shadowOffset = CGSize(width: 0, height: 3)
        powerUpMessageLabel.layer.shadowOpacity = 0.75
        powerUpMessageLabel.layer.shadowRadius = 6
        powerUpMessageLabel.alpha = 0
        powerUpMessageLabel.isUserInteractionEnabled = false
        powerUpMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(powerUpMessageLabel)
        
        NSLayoutConstraint.activate([
            powerUpMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            powerUpMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            powerUpMessageLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupPauseButton() {
        pauseButton = UIButton(type: .system)
        pauseButton.setTitle("Pause", for: .normal)
        pauseButton.setTitle("Resume", for: .selected)
        pauseButton.titleLabel?.font = PeakDesertTheme.roundedFont(size: 14, weight: .bold)
        _ = PeakDesertTheme.applyButtonGradient(
            to: pauseButton,
            colors: [PeakDesertTheme.pauseStart, PeakDesertTheme.pauseEnd],
            cornerRadius: 18
        )
        
        pauseButton.addTarget(self, action: #selector(pauseButtonPressed), for: .touchDown)
        pauseButton.addTarget(self, action: #selector(pauseButtonReleased), for: [.touchUpInside, .touchUpOutside])
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
        
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pauseButton)
        
        NSLayoutConstraint.activate([
            pauseButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            pauseButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            pauseButton.widthAnchor.constraint(equalToConstant: 80),
            pauseButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func setupBackButton() {
        backButton = UIButton(type: .system)
        backButton.setTitle("← Back", for: .normal)
        PeakDesertTheme.styleSecondaryButton(backButton, fontSize: 14)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 80),
            backButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }
    
    private func setupGameOverView() {
        gameOverView = UIView()
        gameOverView.backgroundColor = UIColor(red: 0.25, green: 0.12, blue: 0.06, alpha: 0.82)
        gameOverView.isHidden = true
        gameOverView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gameOverView)
        
        NSLayoutConstraint.activate([
            gameOverView.topAnchor.constraint(equalTo: view.topAnchor),
            gameOverView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gameOverView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gameOverView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        let panel = UIView()
        PeakDesertTheme.styleCard(panel, cornerRadius: 24)
        panel.translatesAutoresizingMaskIntoConstraints = false
        gameOverView.addSubview(panel)
        
        let gameOverLabel = UILabel()
        gameOverLabel.text = "Game Over"
        PeakDesertTheme.applyHeroTitleStyle(to: gameOverLabel)
        gameOverLabel.font = PeakDesertTheme.roundedFont(size: 42, weight: .heavy)
        gameOverLabel.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(gameOverLabel)
        
        let finalScoreLabel = UILabel()
        finalScoreLabel.tag = 100
        finalScoreLabel.text = "Final Score: 0"
        PeakDesertTheme.applyHighlightStyle(to: finalScoreLabel, size: 22)
        finalScoreLabel.textAlignment = .center
        finalScoreLabel.numberOfLines = 0
        finalScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(finalScoreLabel)
        
        let restartButton = UIButton(type: .system)
        restartButton.setTitle("Play Again", for: .normal)
        restartButton.titleLabel?.font = PeakDesertTheme.roundedFont(size: 20, weight: .bold)
        _ = PeakDesertTheme.applyButtonGradient(
            to: restartButton,
            colors: [PeakDesertTheme.playStart, PeakDesertTheme.playEnd],
            cornerRadius: 24
        )
        restartButton.addTarget(self, action: #selector(restartButtonTapped), for: .touchUpInside)
        restartButton.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(restartButton)
        
        let menuButton = UIButton(type: .system)
        menuButton.setTitle("Main Menu", for: .normal)
        menuButton.titleLabel?.font = PeakDesertTheme.roundedFont(size: 18, weight: .semibold)
        PeakDesertTheme.styleSecondaryButton(menuButton, fontSize: 18)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(menuButton)
        
        NSLayoutConstraint.activate([
            panel.centerXAnchor.constraint(equalTo: gameOverView.centerXAnchor),
            panel.centerYAnchor.constraint(equalTo: gameOverView.centerYAnchor),
            panel.leadingAnchor.constraint(equalTo: gameOverView.leadingAnchor, constant: 36),
            panel.trailingAnchor.constraint(equalTo: gameOverView.trailingAnchor, constant: -36),
            
            gameOverLabel.topAnchor.constraint(equalTo: panel.topAnchor, constant: 28),
            gameOverLabel.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 20),
            gameOverLabel.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -20),
            
            finalScoreLabel.topAnchor.constraint(equalTo: gameOverLabel.bottomAnchor, constant: 16),
            finalScoreLabel.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 20),
            finalScoreLabel.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -20),
            
            restartButton.topAnchor.constraint(equalTo: finalScoreLabel.bottomAnchor, constant: 28),
            restartButton.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            restartButton.widthAnchor.constraint(equalToConstant: 220),
            restartButton.heightAnchor.constraint(equalToConstant: 50),
            
            menuButton.topAnchor.constraint(equalTo: restartButton.bottomAnchor, constant: 14),
            menuButton.centerXAnchor.constraint(equalTo: panel.centerXAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 220),
            menuButton.heightAnchor.constraint(equalToConstant: 46),
            menuButton.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -28)
        ])
    }
    
    // MARK: - Game Scene Setup
    
    private func setupGameScene() {
        skView = SKView(frame: view.bounds)
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.backgroundColor = .clear
        skView.isUserInteractionEnabled = true
        if let overlay = desertOverlay {
            view.insertSubview(skView, aboveSubview: overlay)
        } else {
            view.insertSubview(skView, aboveSubview: desertBackground)
        }
        
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: view.topAnchor),
            skView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            skView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            skView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Ensure UI elements are always on top
        view.bringSubviewToFront(scoreHUD)
        view.bringSubviewToFront(timeHUD)
        view.bringSubviewToFront(difficultyLabel)
        view.bringSubviewToFront(gameModeLabel)
        view.bringSubviewToFront(powerUpMessageLabel)
        view.bringSubviewToFront(pauseButton)
        view.bringSubviewToFront(backButton)
        view.bringSubviewToFront(gameOverView)
        view.bringSubviewToFront(dangerWarningOverlay)
        
        // Configure SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        
        // Create and configure game scene
        gameScene = GameScene(size: view.bounds.size)
        gameScene.scaleMode = .resizeFill
        gameScene.difficulty = gameDifficulty
        gameScene.gameMode = gameMode
        gameScene.gameDelegate = self
        
        skView.presentScene(gameScene)
    }
    
    // MARK: - Actions
    
    @objc private func pauseButtonPressed() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
            self.pauseButton.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            self.pauseButton.alpha = 0.8
        })
    }
    
    @objc private func pauseButtonReleased() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5, options: [.curveEaseOut], animations: {
            self.pauseButton.transform = .identity
            self.pauseButton.alpha = 1.0
        })
    }
    
    @objc private func pauseButtonTapped() {
        pauseButton.isSelected.toggle()
        
        // Update button appearance based on state
        updatePauseButtonAppearance()
        
        if pauseButton.isSelected {
            gameScene.pauseGame()
        } else {
            gameScene.resumeGame()
        }
    }
    
    private func updatePauseButtonAppearance() {
        // Update gradient colors based on state
        if let sublayers = pauseButton.layer.sublayers {
            for layer in sublayers {
                if let gradientLayer = layer as? CAGradientLayer {
                    if pauseButton.isSelected {
                        gradientLayer.colors = [
                            PeakDesertTheme.resumeStart.cgColor,
                            PeakDesertTheme.resumeEnd.cgColor
                        ]
                    } else {
                        gradientLayer.colors = [
                            PeakDesertTheme.pauseStart.cgColor,
                            PeakDesertTheme.pauseEnd.cgColor
                        ]
                    }
                }
            }
        }
    }
    
    @objc private func backButtonTapped() {
        gameScene.pauseGame()
        
        let alert = UIAlertController(title: "Exit Game", message: "Are you sure you want to exit? Your progress will be lost.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Exit", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    @objc private func restartButtonTapped() {
        gameOverView.isHidden = true
        didTriggerWarningHaptic = false
        gameScene = GameScene(size: view.bounds.size)
        gameScene.scaleMode = .resizeFill
        gameScene.difficulty = gameDifficulty
        gameScene.gameMode = gameMode
        gameScene.gameDelegate = self
        skView.presentScene(gameScene)
    }
    
    @objc private func menuButtonTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - Orientation Support
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.gameScene.size = size
        })
    }
}

// MARK: - GameSceneDelegate

extension GameViewController: GameSceneDelegate {
    func gameDidEnd(score: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let duration = self.gameScene.getElapsedTime()
            if let finalScoreLabel = self.gameOverView.viewWithTag(100) as? UILabel {
                finalScoreLabel.text = "Final Score: \(score)\nTime: \(GameRecordManager.formatDuration(duration))"
            }
            
            self.gameOverView.isHidden = false
            self.updateDangerOverlay(level: .none, animated: false)
            
            GameRecordManager.shared.saveRecord(
                score: score,
                duration: duration,
                difficulty: self.gameDifficulty
            )
        }
    }
    
    func dangerLevelDidChange(_ level: DangerLevel) {
        DispatchQueue.main.async { [weak self] in
            self?.updateDangerOverlay(level: level, animated: true)
        }
    }
    
    /// 根据危险等级更新边框与震动
    private func updateDangerOverlay(level: DangerLevel, animated: Bool) {
        switch level {
        case .none:
            didTriggerWarningHaptic = false
            dangerWarningOverlay.layer.removeAllAnimations()
            if animated {
                UIView.animate(withDuration: 0.25) {
                    self.dangerWarningOverlay.alpha = 0
                    self.dangerWarningOverlay.layer.borderWidth = 0
                }
            } else {
                dangerWarningOverlay.alpha = 0
                dangerWarningOverlay.layer.borderWidth = 0
            }
        case .warning:
            dangerWarningOverlay.layer.borderColor = UIColor.systemOrange.cgColor
            dangerWarningOverlay.layer.borderWidth = 4
            if !didTriggerWarningHaptic {
                didTriggerWarningHaptic = true
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            animateDangerPulse(targetAlpha: 0.35)
        case .critical:
            dangerWarningOverlay.layer.borderColor = UIColor.systemRed.cgColor
            dangerWarningOverlay.layer.borderWidth = 6
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            animateDangerPulse(targetAlpha: 0.55)
        }
    }
    
    /// 危险边框脉冲动画
    private func animateDangerPulse(targetAlpha: CGFloat) {
        dangerWarningOverlay.layer.removeAllAnimations()
        dangerWarningOverlay.alpha = targetAlpha
        UIView.animate(withDuration: 0.45, delay: 0, options: [.autoreverse, .repeat, .allowUserInteraction], animations: {
            self.dangerWarningOverlay.alpha = targetAlpha * 0.35
        })
    }
    
    func scoreDidUpdate(_ score: Int) {
        DispatchQueue.main.async { [weak self] in
            self?.scoreLabel.text = "Score: \(score)"
        }
    }
    
    func gameTimeDidUpdate(_ elapsedTime: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            let minutes = Int(elapsedTime) / 60
            let seconds = Int(elapsedTime) % 60
            self?.timeLabel.text = String(format: "Time: %02d:%02d", minutes, seconds)
        }
    }
    
    func showPowerUpMessage(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if message.isEmpty {
                // Hide message
                UIView.animate(withDuration: 0.3, animations: {
                    self.powerUpMessageLabel.alpha = 0
                })
            } else {
                // Show message
                self.powerUpMessageLabel.text = message
                
                // Set color based on message
                if message.contains("Speed Up") {
                    self.powerUpMessageLabel.textColor = .systemRed
                } else if message.contains("Speed Down") {
                    self.powerUpMessageLabel.textColor = .systemBlue
                } else if message.contains("Freeze") {
                    self.powerUpMessageLabel.textColor = .systemTeal
                } else if message.contains("Clear") {
                    self.powerUpMessageLabel.textColor = .systemGreen
                } else if message.contains("Lucky") {
                    self.powerUpMessageLabel.textColor = .systemPurple
                } else {
                    self.powerUpMessageLabel.textColor = .white
                }
                
                // Animate appearance
                UIView.animate(withDuration: 0.3, animations: {
                    self.powerUpMessageLabel.alpha = 1.0
                    self.powerUpMessageLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                }) { _ in
                    UIView.animate(withDuration: 0.2, animations: {
                        self.powerUpMessageLabel.transform = .identity
                    })
                }
            }
        }
    }
}

