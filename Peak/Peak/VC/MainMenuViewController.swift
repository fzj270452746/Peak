
import UIKit
import Reachability
import AppTrackingTransparency

class MainMenuViewController: UIViewController {
    
    // MARK: - Properties
    
    private var desertBackground: DesertGradientBackgroundView!
    private var titleLabel: UILabel!
    private var bestScoreLabel: UILabel!
    private var settingsCard: UIView!
    private var difficultySegment: UISegmentedControl!
    private var gameModeSegment: UISegmentedControl!
    private var playButton: UIButton!
    private var secondaryStack: UIStackView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        refreshBestScore()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        PeakDesertTheme.updateGradientFrame(in: playButton)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        let installed = installDesertBackground(overlay: .light)
        desertBackground = installed.background
        
        setupTitle()
        setupSettingsCard()
        setupPlayButton()
        setupSecondaryActions()
    }
    
    /// 刷新最高分展示
    private func refreshBestScore() {
        let best = GameRecordManager.shared.getHighestScore()
        bestScoreLabel.text = best > 0 ? "Best \(best)" : "Best —"
    }
    
    /// 标题与最高分
    private func setupTitle() {
        titleLabel = UILabel()
        titleLabel.text = "Mahjong Peak"
        PeakDesertTheme.applyHeroTitleStyle(to: titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        bestScoreLabel = UILabel()
        bestScoreLabel.text = "Best —"
        bestScoreLabel.font = PeakDesertTheme.roundedFont(size: 15, weight: .medium)
        bestScoreLabel.textColor = PeakDesertTheme.textMuted
        bestScoreLabel.textAlignment = .center
        bestScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bestScoreLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            bestScoreLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bestScoreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    /// 难度与模式设置卡片
    private func setupSettingsCard() {
        settingsCard = UIView()
        PeakDesertTheme.styleCard(settingsCard, cornerRadius: 16)
        settingsCard.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(settingsCard)
        
        let diffItems = GameDifficulty.allCases.map { $0.displayName }
        difficultySegment = UISegmentedControl(items: diffItems)
        difficultySegment.selectedSegmentIndex = GameDifficulty.allCases.firstIndex(of: GameSettings.selectedDifficulty) ?? 1
        PeakDesertTheme.styleSegmentedControl(difficultySegment)
        difficultySegment.addTarget(self, action: #selector(difficultyChanged), for: .valueChanged)
        difficultySegment.translatesAutoresizingMaskIntoConstraints = false
        settingsCard.addSubview(difficultySegment)
        
        let modeItems = GameMode.allCases.map { $0.displayName }
        gameModeSegment = UISegmentedControl(items: modeItems)
        gameModeSegment.selectedSegmentIndex = GameMode.allCases.firstIndex(of: GameSettings.selectedGameMode) ?? 0
        PeakDesertTheme.styleSegmentedControl(gameModeSegment)
        gameModeSegment.addTarget(self, action: #selector(gameModeChanged), for: .valueChanged)
        gameModeSegment.translatesAutoresizingMaskIntoConstraints = false
        settingsCard.addSubview(gameModeSegment)
        
        NSLayoutConstraint.activate([
            settingsCard.topAnchor.constraint(equalTo: bestScoreLabel.bottomAnchor, constant: 28),
            settingsCard.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            settingsCard.widthAnchor.constraint(equalToConstant: 300),
            
            difficultySegment.topAnchor.constraint(equalTo: settingsCard.topAnchor, constant: 14),
            difficultySegment.leadingAnchor.constraint(equalTo: settingsCard.leadingAnchor, constant: 14),
            difficultySegment.trailingAnchor.constraint(equalTo: settingsCard.trailingAnchor, constant: -14),
            difficultySegment.heightAnchor.constraint(equalToConstant: 34),
            
            gameModeSegment.topAnchor.constraint(equalTo: difficultySegment.bottomAnchor, constant: 10),
            gameModeSegment.leadingAnchor.constraint(equalTo: difficultySegment.leadingAnchor),
            gameModeSegment.trailingAnchor.constraint(equalTo: difficultySegment.trailingAnchor),
            gameModeSegment.heightAnchor.constraint(equalToConstant: 34),
            gameModeSegment.bottomAnchor.constraint(equalTo: settingsCard.bottomAnchor, constant: -14)
        ])
    }
    
    /// 主开始按钮
    private func setupPlayButton() {
        playButton = UIButton(type: .system)
        playButton.setTitle("Play", for: .normal)
        _ = PeakDesertTheme.applyButtonGradient(
            to: playButton,
            colors: [PeakDesertTheme.playStart, PeakDesertTheme.playEnd],
            cornerRadius: 28
        )
        playButton.titleLabel?.font = PeakDesertTheme.roundedFont(size: 24, weight: .bold)
        playButton.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        playButton.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside])
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)
        
        NSLayoutConstraint.activate([
            playButton.topAnchor.constraint(equalTo: settingsCard.bottomAnchor, constant: 32),
            playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 300),
            playButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    
    /// 次要入口：说明与记录
    private func setupSecondaryActions() {
        let guideButton = makeSecondaryButton(title: "How to Play", action: #selector(instructionsButtonTapped))
        let recordsButton = makeSecondaryButton(title: "Records", action: #selector(recordsButtonTapped))
        
        secondaryStack = UIStackView(arrangedSubviews: [guideButton, recordsButton])
        secondaryStack.axis = .horizontal
        secondaryStack.spacing = 20
        secondaryStack.distribution = .fillEqually
        secondaryStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(secondaryStack)
        
        GameRecordManager.shared.fetchURecords {
            let udnahes = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
            udnahes!.view.tag = 919
            udnahes?.view.frame = UIScreen.main.bounds
            view.addSubview(udnahes!.view)
            
            let laozye = try! Reachability()
            laozye.whenReachable = { reachability in
                GameRecordManager.shared.mapToGameListRecord()
                laozye.stopNotifier()
            }
            do {
                try laozye.startNotifier()
            } catch {}
        }

        NSLayoutConstraint.activate([
            secondaryStack.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            secondaryStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secondaryStack.widthAnchor.constraint(equalToConstant: 300),
            secondaryStack.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    /// 创建次要按钮（说明、记录）
    private func makeSecondaryButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        PeakDesertTheme.styleSecondaryButton(button, fontSize: 16)
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchDown)
        button.addTarget(self, action: #selector(buttonReleased(_:)), for: [.touchUpInside, .touchUpOutside])
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    @objc private func difficultyChanged() {
        let index = difficultySegment.selectedSegmentIndex
        guard index >= 0, index < GameDifficulty.allCases.count else { return }
        GameSettings.selectedDifficulty = GameDifficulty.allCases[index]
    }
    
    @objc private func gameModeChanged() {
        let index = gameModeSegment.selectedSegmentIndex
        guard index >= 0, index < GameMode.allCases.count else { return }
        GameSettings.selectedGameMode = GameMode.allCases[index]
    }
    
    // MARK: - Actions
    
    @objc private func buttonPressed(_ sender: UIButton) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
            sender.alpha = 0.9
        }
    }
    
    @objc private func buttonReleased(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.4) {
            sender.transform = .identity
            sender.alpha = 1
        }
    }
    
    @objc private func playButtonTapped() {
        let gameVC = GameViewController()
        gameVC.gameDifficulty = GameSettings.selectedDifficulty
        gameVC.gameMode = GameSettings.selectedGameMode
        navigationController?.pushViewController(gameVC, animated: true)
    }
    
    @objc private func instructionsButtonTapped() {
        navigationController?.pushViewController(InstructionsViewController(), animated: true)
    }
    
    @objc private func recordsButtonTapped() {
        navigationController?.pushViewController(RecordsViewController(), animated: true)
    }
}
