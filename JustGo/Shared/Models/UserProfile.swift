import Foundation
import SwiftData

@Model
final class UserProfile {
    var id: UUID = UUID()
    var totalPoints: Int = 0
    var level: Int = 1
    var unlockedSpeciesRaw: [String] = ["oak"]
    var forestSeasonRaw: String = Season.spring.rawValue
    var streakDays: Int = 0
    var lastSessionDate: Date? = nil

    var buddySpeciesRaw: String = "fox"
    var buddyName: String = "小狐"
    var buddyExp: Int = 0
    var buddyStageRaw: Int = BuddyStage.egg.rawValue
    var buddyMoodRaw: String = BuddyMood.calm.rawValue

    var forestSeason: Season {
        get { Season(rawValue: forestSeasonRaw) ?? .spring }
        set { forestSeasonRaw = newValue.rawValue }
    }

    var buddyStage: BuddyStage {
        get { BuddyStage(rawValue: buddyStageRaw) ?? .egg }
        set { buddyStageRaw = newValue.rawValue }
    }

    var buddyMood: BuddyMood {
        get { BuddyMood(rawValue: buddyMoodRaw) ?? .calm }
        set { buddyMoodRaw = newValue.rawValue }
    }

    var unlockedSpecies: [TreeSpecies] {
        get { unlockedSpeciesRaw.compactMap(TreeSpecies.init) }
        set { unlockedSpeciesRaw = newValue.map(\.rawValue) }
    }

    init() {}

    func recomputeBuddyStage() {
        let candidate = BuddyStage.allCases
            .filter { buddyExp >= $0.requiredExp }
            .max(by: { $0.rawValue < $1.rawValue }) ?? .egg
        if candidate != buddyStage {
            buddyStage = candidate
        }
    }
}
