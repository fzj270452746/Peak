//
//  RecordsViewController.swift
//  Peak
//
//  Created by Zhao on 2025/12/29.
//

import UIKit

/// 游戏记录与个人统计界面
class RecordsViewController: UIViewController {
    
    // MARK: - Properties
    
    private var backButton: UIButton!
    private var pageTitleLabel: UILabel!
    private var statsCardView: UIView!
    private var statsLabel: UILabel!
    private var tableView: UITableView!
    private var emptyStateLabel: UILabel!
    private var deleteAllButton: UIButton!
    
    private var records: [GameRecord] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadRecords()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        loadRecords()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        _ = installDesertBackground(overlay: .medium)
        
        setupBackButton()
        setupTitle()
        setupDeleteAllButton()
        setupStatsCard()
        setupTableView()
        setupEmptyState()
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
    
    private func setupTitle() {
        pageTitleLabel = UILabel()
        pageTitleLabel.text = "Game Records"
        PeakDesertTheme.applySectionTitleStyle(to: pageTitleLabel, size: 26)
        pageTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageTitleLabel)
        
        NSLayoutConstraint.activate([
            pageTitleLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 18),
            pageTitleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            pageTitleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        ])
    }
    
    private func setupDeleteAllButton() {
        deleteAllButton = UIButton(type: .system)
        deleteAllButton.setTitle("Delete All", for: .normal)
        deleteAllButton.titleLabel?.font = PeakDesertTheme.roundedFont(size: 14, weight: .bold)
        _ = PeakDesertTheme.applyButtonGradient(
            to: deleteAllButton,
            colors: [
                UIColor(red: 0.92, green: 0.32, blue: 0.22, alpha: 1),
                UIColor(red: 0.72, green: 0.18, blue: 0.15, alpha: 1)
            ],
            cornerRadius: 18
        )
        deleteAllButton.addTarget(self, action: #selector(deleteAllButtonTapped), for: .touchUpInside)
        deleteAllButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteAllButton)
        
        NSLayoutConstraint.activate([
            deleteAllButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            deleteAllButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            deleteAllButton.widthAnchor.constraint(equalToConstant: 108),
            deleteAllButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        PeakDesertTheme.updateGradientFrame(in: deleteAllButton)
    }
    
    /// 个人统计卡片
    private func setupStatsCard() {
        statsCardView = UIView()
        PeakDesertTheme.styleCard(statsCardView, cornerRadius: 16)
        statsCardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statsCardView)
        
        statsLabel = UILabel()
        statsLabel.font = PeakDesertTheme.roundedFont(size: 15, weight: .medium)
        statsLabel.textColor = PeakDesertTheme.textSecondary
        statsLabel.numberOfLines = 0
        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        statsCardView.addSubview(statsLabel)
        
        NSLayoutConstraint.activate([
            statsCardView.topAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor, constant: 16),
            statsCardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            statsCardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            statsLabel.topAnchor.constraint(equalTo: statsCardView.topAnchor, constant: 14),
            statsLabel.leadingAnchor.constraint(equalTo: statsCardView.leadingAnchor, constant: 16),
            statsLabel.trailingAnchor.constraint(equalTo: statsCardView.trailingAnchor, constant: -16),
            statsLabel.bottomAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: -14)
        ])
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RecordTableViewCell.self, forCellReuseIdentifier: "RecordCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: statsCardView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupEmptyState() {
        emptyStateLabel = UILabel()
        emptyStateLabel.text = "No game records yet.\nPlay a game to see your scores here!"
        emptyStateLabel.font = PeakDesertTheme.roundedFont(size: 18, weight: .medium)
        emptyStateLabel.textColor = PeakDesertTheme.textMuted
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateLabel.isHidden = true
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -40)
        ])
    }
    
    // MARK: - Data Management
    
    private func loadRecords() {
        records = GameRecordManager.shared.fetchAllRecords()
        updateStatistics()
        tableView.reloadData()
        updateEmptyState()
        updateDeleteAllButton()
    }
    
    /// 刷新个人统计文案
    private func updateStatistics() {
        let stats = GameRecordManager.shared.computeStatistics()
        if stats.totalGames == 0 {
            statsLabel.text = "No games played yet.\nStart playing to see your stats!"
            return
        }
        let avgScore = Int(stats.averageScore.rounded())
        let longest = GameRecordManager.formatDuration(stats.longestDuration)
        let avgTime = GameRecordManager.formatDuration(stats.averageDuration)
        statsLabel.text = """
        Total Games: \(stats.totalGames)
        Average Score: \(avgScore)
        Highest Score: \(stats.highestScore)
        Longest Survival: \(longest)
        Average Time: \(avgTime)
        """
    }
    
    private func updateEmptyState() {
        emptyStateLabel.isHidden = !records.isEmpty
        tableView.isHidden = records.isEmpty
    }
    
    private func updateDeleteAllButton() {
        deleteAllButton.isHidden = records.isEmpty
    }
    
    // MARK: - Actions
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func deleteAllButtonTapped() {
        let alert = UIAlertController(
            title: "Delete All Records",
            message: "Are you sure you want to delete all game records? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete All", style: .destructive) { [weak self] _ in
            GameRecordManager.shared.deleteAllRecords()
            self?.loadRecords()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension RecordsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return records.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecordCell", for: indexPath) as! RecordTableViewCell
        let record = records[indexPath.row]
        cell.configure(with: record, rank: indexPath.row + 1)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension RecordsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let record = records[indexPath.row]
            GameRecordManager.shared.deleteRecord(id: record.id)
            loadRecords()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Delete"
    }
}

// MARK: - RecordTableViewCell

/// 单条记录单元格
class RecordTableViewCell: UITableViewCell {
    
    private var cardView: UIView!
    private var rankLabel: UILabel!
    private var scoreLabel: UILabel!
    private var detailLabel: UILabel!
    private var dateLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        cardView = UIView()
        PeakDesertTheme.styleCard(cardView, cornerRadius: 14)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)
        
        rankLabel = UILabel()
        rankLabel.font = PeakDesertTheme.roundedFont(size: 22, weight: .heavy)
        rankLabel.textColor = PeakDesertTheme.textAccent
        rankLabel.textAlignment = .center
        rankLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(rankLabel)
        
        scoreLabel = UILabel()
        scoreLabel.font = PeakDesertTheme.roundedFont(size: 20, weight: .bold)
        scoreLabel.textColor = PeakDesertTheme.textPrimary
        scoreLabel.textAlignment = .left
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(scoreLabel)
        
        detailLabel = UILabel()
        detailLabel.font = PeakDesertTheme.roundedFont(size: 13, weight: .medium)
        detailLabel.textColor = PeakDesertTheme.textSecondary
        detailLabel.textAlignment = .left
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(detailLabel)
        
        dateLabel = UILabel()
        dateLabel.font = PeakDesertTheme.roundedFont(size: 12, weight: .regular)
        dateLabel.textColor = PeakDesertTheme.textMuted
        dateLabel.textAlignment = .left
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            rankLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            rankLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            rankLabel.widthAnchor.constraint(equalToConstant: 44),
            
            scoreLabel.leadingAnchor.constraint(equalTo: rankLabel.trailingAnchor, constant: 12),
            scoreLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            scoreLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            
            detailLabel.leadingAnchor.constraint(equalTo: scoreLabel.leadingAnchor),
            detailLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 2),
            detailLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            
            dateLabel.leadingAnchor.constraint(equalTo: scoreLabel.leadingAnchor),
            dateLabel.topAnchor.constraint(equalTo: detailLabel.bottomAnchor, constant: 4),
            dateLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14)
        ])
    }
    
    func configure(with record: GameRecord, rank: Int) {
        rankLabel.text = "#\(rank)"
        
        if rank <= 3 {
            rankLabel.textColor = rank == 1 ? PeakDesertTheme.textAccent : (rank == 2 ? PeakDesertTheme.textSecondary : PeakDesertTheme.recordsStart)
        } else {
            rankLabel.textColor = PeakDesertTheme.textMuted
        }
        
        scoreLabel.text = "Score: \(record.score)"
        detailLabel.text = "Time: \(GameRecordManager.formatDuration(record.duration)) · \(record.difficulty.displayName)"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: record.date)
    }
}
