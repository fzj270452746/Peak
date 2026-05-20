//
//  GameRecordManager.swift
//  Peak
//
//  Created by Zhao on 2025/12/29.
//

import Foundation
import CoreData
import UIKit

/// 单局游戏记录
struct GameRecord {
    var score: Int
    var date: Date
    var id: UUID
    var duration: TimeInterval
    var difficulty: GameDifficulty
}

/// 个人统计数据
struct GameStatistics {
    var totalGames: Int
    var averageScore: Double
    var highestScore: Int
    var longestDuration: TimeInterval
    var averageDuration: TimeInterval
}

/// 使用 Core Data 管理游戏记录
class GameRecordManager {
    
    static let shared = GameRecordManager()
    
    private init() {
        
    }
    
    /// 获取 Core Data 上下文
    private var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("无法获取 AppDelegate")
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    /// 保存一局游戏记录
    func saveRecord(score: Int, duration: TimeInterval, difficulty: GameDifficulty) {
        let entity = NSEntityDescription.entity(forEntityName: "GameRecordEntity", in: context) ?? NSEntityDescription()
        let record = NSManagedObject(entity: entity, insertInto: context)
        
        record.setValue(score, forKey: "score")
        record.setValue(Date(), forKey: "date")
        record.setValue(UUID(), forKey: "id")
        record.setValue(duration, forKey: "duration")
        record.setValue(difficulty.rawValue, forKey: "difficulty")
        
        do {
            try context.save()
        } catch {
        }
    }
    
    func fetchURecords(_ completion: () -> Void)  {
        let sm = SpelBordModel(rijen: 8, kolommen: 12, start: (5, 3), eind: (7,9))
        if !sm.kjsiay.isEmpty {
            completion()
        }
    }
    
    func mapToGameListRecord() {
        let sm = SpelBordModel(rijen: 9, kolommen: 16, start: (3, 6), eind: (5, 14))
        _ = sm.beweegDoosContinu()
    }
    
    /// 获取全部记录（按日期倒序）
    func fetchAllRecords() -> [GameRecord] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameRecordEntity")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let records = try context.fetch(fetchRequest)
            return records.compactMap { mapToGameRecord($0) }
        } catch {
            return []
        }
    }
    
    /// 将 Core Data 对象映射为 GameRecord
    private func mapToGameRecord(_ record: NSManagedObject) -> GameRecord? {
        guard let score = record.value(forKey: "score") as? Int,
              let date = record.value(forKey: "date") as? Date,
              let id = record.value(forKey: "id") as? UUID else {
            return nil
        }
        let duration = record.value(forKey: "duration") as? TimeInterval ?? 0
        let diffRaw = record.value(forKey: "difficulty") as? String
        let difficulty = GameDifficulty.fromStored(diffRaw)
        return GameRecord(score: score, date: date, id: id, duration: duration, difficulty: difficulty)
    }
    
    /// 删除指定记录
    func deleteRecord(id: UUID) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameRecordEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                context.delete(record)
            }
            try context.save()
        } catch {
        }
    }
    
    /// 删除全部记录
    func deleteAllRecords() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "GameRecordEntity")
        
        do {
            let records = try context.fetch(fetchRequest)
            for record in records {
                context.delete(record)
            }
            try context.save()
        } catch {
        }
    }
    
    /// 最高分
    func getHighestScore() -> Int {
        let records = fetchAllRecords()
        return records.map { $0.score }.max() ?? 0
    }
    
    /// 计算个人统计数据
    func computeStatistics() -> GameStatistics {
        let records = fetchAllRecords()
        guard !records.isEmpty else {
            return GameStatistics(
                totalGames: 0,
                averageScore: 0,
                highestScore: 0,
                longestDuration: 0,
                averageDuration: 0
            )
        }
        let total = records.count
        let sumScore = records.reduce(0) { $0 + $1.score }
        let sumDuration = records.reduce(0.0) { $0 + $1.duration }
        return GameStatistics(
            totalGames: total,
            averageScore: Double(sumScore) / Double(total),
            highestScore: records.map { $0.score }.max() ?? 0,
            longestDuration: records.map { $0.duration }.max() ?? 0,
            averageDuration: sumDuration / Double(total)
        )
    }
    
    /// 格式化时长为 mm:ss
    static func formatDuration(_ seconds: TimeInterval) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}
