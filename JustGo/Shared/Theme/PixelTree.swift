import SwiftUI

enum PixelColor: Int {
    case empty = 0
    case trunk
    case primaryDark
    case primary
    case primaryLight
    case sakuraLight
    case sakuraDark
}

struct PixelTreeView: View {
    let pattern: [[PixelColor]]
    var pixelSize: CGFloat = 6

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<pattern.count, id: \.self) { y in
                HStack(spacing: 0) {
                    ForEach(0..<pattern[y].count, id: \.self) { x in
                        Rectangle()
                            .fill(color(for: pattern[y][x]))
                            .frame(width: pixelSize, height: pixelSize)
                    }
                }
            }
        }
    }

    private func color(for c: PixelColor) -> Color {
        switch c {
        case .empty:        return .clear
        case .trunk:        return Palette.trunk
        case .primaryDark:  return Palette.primaryDark
        case .primary:      return Palette.primary
        case .primaryLight: return Palette.primaryLight
        case .sakuraLight:  return Palette.sakuraLight
        case .sakuraDark:   return Palette.sakuraDark
        }
    }
}

enum PixelTreePatterns {
    static func oak(stage: Int) -> [[PixelColor]] {
        switch stage {
        case 0: return seed
        case 1: return sapling
        case 2: return small
        default: return large
        }
    }

    static func sakura(stage: Int) -> [[PixelColor]] {
        oak(stage: stage).map { row in
            row.map { c in
                switch c {
                case .primary:      return .sakuraLight
                case .primaryDark:  return .sakuraDark
                case .primaryLight: return .sakuraLight
                default:            return c
                }
            }
        }
    }

    private static let e: PixelColor = .empty
    private static let D: PixelColor = .primaryDark
    private static let G: PixelColor = .primary
    private static let L: PixelColor = .primaryLight
    private static let B: PixelColor = .trunk

    static let seed: [[PixelColor]] = [
        Array(repeating: e, count: 10),
        Array(repeating: e, count: 10),
        Array(repeating: e, count: 10),
        Array(repeating: e, count: 10),
        [e,e,e,e,D,L,e,e,e,e],
        [e,e,e,e,D,D,e,e,e,e],
        Array(repeating: e, count: 10),
        Array(repeating: e, count: 10),
        Array(repeating: e, count: 10),
        Array(repeating: e, count: 10),
    ]

    static let sapling: [[PixelColor]] = [
        Array(repeating: e, count: 10),
        Array(repeating: e, count: 10),
        [e,e,e,e,G,L,e,e,e,e],
        [e,e,e,D,G,G,e,e,e,e],
        [e,e,D,G,G,L,e,e,e,e],
        [e,e,e,e,B,e,e,e,e,e],
        [e,e,e,e,B,e,e,e,e,e],
        Array(repeating: e, count: 10),
        Array(repeating: e, count: 10),
        Array(repeating: e, count: 10),
    ]

    static let small: [[PixelColor]] = [
        Array(repeating: e, count: 10),
        [e,e,e,e,G,L,e,e,e,e],
        [e,e,e,D,G,G,L,e,e,e],
        [e,e,D,G,G,G,L,e,e,e],
        [e,e,D,D,G,G,G,e,e,e],
        [e,e,e,D,G,G,e,e,e,e],
        [e,e,e,e,B,e,e,e,e,e],
        [e,e,e,e,B,e,e,e,e,e],
        Array(repeating: e, count: 10),
        Array(repeating: e, count: 10),
    ]

    static let large: [[PixelColor]] = [
        [e,e,e,D,G,G,L,e,e,e],
        [e,e,D,G,G,G,L,L,e,e],
        [e,D,D,G,G,G,G,L,L,e],
        [D,D,D,G,G,G,G,L,L,L],
        [e,D,D,G,G,G,G,L,L,e],
        [e,e,e,D,G,G,L,e,e,e],
        [e,e,e,e,B,e,e,e,e,e],
        [e,e,e,e,B,e,e,e,e,e],
        [e,e,e,e,B,B,e,e,e,e],
        Array(repeating: e, count: 10),
    ]
}

#Preview("oak stages") {
    HStack(spacing: 16) {
        ForEach(0..<4, id: \.self) { stage in
            PixelTreeView(
                pattern: PixelTreePatterns.oak(stage: stage),
                pixelSize: 8
            )
        }
    }
    .padding()
    .background(Palette.bg)
}
