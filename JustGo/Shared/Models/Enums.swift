import Foundation

enum GoalType: String, Codable, CaseIterable {
    case duration
    case reps
    case phased

    var displayName: String {
        switch self {
        case .duration: return "时长型"
        case .reps:     return "次数型"
        case .phased:   return "分阶段"
        }
    }

    var sfSymbol: String {
        switch self {
        case .duration: return "stopwatch"
        case .reps:     return "number.circle"
        case .phased:   return "flame"
        }
    }
}

enum PhaseType: String, Codable {
    case duration
    case reps
}

enum SessionStatus: String, Codable {
    case active
    case paused
    case completed
    case abandoned
}

enum TreeSpecies: String, Codable, CaseIterable {
    case shrub
    case oak
    case sequoia
    case sakura

    var displayName: String {
        switch self {
        case .shrub:    return "灌木"
        case .oak:      return "橡树"
        case .sequoia:  return "红杉"
        case .sakura:   return "樱花"
        }
    }
}

enum Season: String, Codable {
    case spring, summer, autumn, winter
}

enum BuddyStage: Int, Codable, CaseIterable {
    case egg = 0
    case baby = 1
    case juvenile = 2
    case mature = 3
    case guardian = 4

    var displayName: String {
        switch self {
        case .egg:       return "蛋"
        case .baby:      return "幼体"
        case .juvenile:  return "成长"
        case .mature:    return "成熟"
        case .guardian:  return "守护"
        }
    }

    var requiredExp: Int {
        switch self {
        case .egg:       return 0
        case .baby:      return 50
        case .juvenile:  return 200
        case .mature:    return 500
        case .guardian:  return 1500
        }
    }
}

enum BuddyMood: String, Codable {
    case excited, calm, tired
}
