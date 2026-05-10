import Foundation
import SwiftData

@Model
final class Tree {
    var id: UUID = UUID()
    var sessionID: UUID? = nil
    var speciesRaw: String = TreeSpecies.oak.rawValue
    var plantedAt: Date = Date()
    var growthStage: Int = 3
    var isAlive: Bool = true
    var isWilted: Bool = false   // 未达标记录：仍种树但灰色枯萎
    var x: Double = 0
    var y: Double = 0

    var species: TreeSpecies {
        get { TreeSpecies(rawValue: speciesRaw) ?? .oak }
        set { speciesRaw = newValue.rawValue }
    }

    init(
        sessionID: UUID? = nil,
        species: TreeSpecies = .oak,
        isWilted: Bool = false,
        x: Double = 0,
        y: Double = 0
    ) {
        self.sessionID = sessionID
        self.speciesRaw = species.rawValue
        self.isWilted = isWilted
        self.x = x
        self.y = y
    }
}
