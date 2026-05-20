//
//  GameDifficulty.swift
//  Peak
//
//  Created by Zhao on 2025/12/29.
//

import Foundation
import CoreGraphics

/// 游戏难度档位
enum GameDifficulty: String, CaseIterable {
    case easy = "easy"
    case normal = "normal"
    case hard = "hard"
    
    /// 界面展示名称（英文）
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .normal: return "Normal"
        case .hard: return "Hard"
        }
    }
    
    /// 初始生成间隔（秒）
    var initialSpawnInterval: TimeInterval {
        switch self {
        case .easy: return 2.4
        case .normal: return 2.0
        case .hard: return 1.5
        }
    }
    
    /// 最短生成间隔（秒）
    var minSpawnInterval: TimeInterval {
        switch self {
        case .easy: return 1.0
        case .normal: return 0.8
        case .hard: return 0.55
        }
    }
    
    /// 每次缩短的间隔步长
    var spawnIntervalStep: TimeInterval {
        switch self {
        case .easy: return 0.04
        case .normal: return 0.05
        case .hard: return 0.06
        }
    }
    
    /// 重力倍率
    var gravityScale: CGFloat {
        switch self {
        case .easy: return 0.85
        case .normal: return 1.0
        case .hard: return 1.2
        }
    }
    
    /// 分数翻倍牌出现概率
    var multiplierChance: Double {
        switch self {
        case .easy: return 0.20
        case .normal: return 0.15
        case .hard: return 0.10
        }
    }
    
    /// 障碍牌出现概率
    var obstacleChance: Double {
        switch self {
        case .easy: return 0.05
        case .normal: return 0.10
        case .hard: return 0.18
        }
    }
    
    /// 炸弹牌出现概率
    var bombChance: Double {
        switch self {
        case .easy: return 0.08
        case .normal: return 0.10
        case .hard: return 0.12
        }
    }
    
    /// 危险线高度占屏幕比例（超过则预警）
    var dangerLineRatio: CGFloat {
        switch self {
        case .easy: return 0.72
        case .normal: return 0.75
        case .hard: return 0.78
        }
    }
    
    /// 从字符串解析难度，无效时返回普通
    static func fromStored(_ raw: String?) -> GameDifficulty {
        guard let raw = raw, let d = GameDifficulty(rawValue: raw) else { return .normal }
        return d
    }
}
