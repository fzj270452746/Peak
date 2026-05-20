
import Foundation

enum GameMode: String, CaseIterable {
    case classic = "classic"
    case matchChallenge = "match_challenge"
    
    /// 界面展示名称（英文）
    var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .matchChallenge: return "Match & Clear"
        }
    }
    
    /// 简短说明（英文，用于菜单）
    var shortDescription: String {
        switch self {
        case .classic:
            return "Tap tiles multiple times to clear"
        case .matchChallenge:
            return "Tap matching tiles; delete mismatches"
        }
    }
    
    /// 从存储字符串解析，无效时返回经典模式
    static func fromStored(_ raw: String?) -> GameMode {
        guard let raw = raw, let mode = GameMode(rawValue: raw) else { return .classic }
        return mode
    }
}

/// 游戏模式与难度偏好设置
enum GameSettings {
    private static let difficultyKey = "peak_selected_difficulty"
    private static let gameModeKey = "peak_selected_game_mode"
    
    /// 读取已保存的难度
    static var selectedDifficulty: GameDifficulty {
        get {
            let raw = UserDefaults.standard.string(forKey: difficultyKey)
            return GameDifficulty.fromStored(raw)
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: difficultyKey)
        }
    }
    
    /// 读取已保存的游戏模式
    static var selectedGameMode: GameMode {
        get {
            let raw = UserDefaults.standard.string(forKey: gameModeKey)
            return GameMode.fromStored(raw)
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: gameModeKey)
        }
    }
}
