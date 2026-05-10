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
    var x: Double = 0
    var y: Double = 0

    var species: TreeSpecies {
        get { TreeSpecies(rawValue: speciesRaw) ?? .oak }
        set { speciesRaw = newValue.rawValue }
    }

    init(
        sessionID: UUID? = nil,
        species: TreeSpecies = .oak,
        x: Double = 0,
        y: Double = 0
    ) {
        self.sessionID = sessionID
        self.speciesRaw = species.rawValue
        self.x = x
        self.y = y
    }
}
