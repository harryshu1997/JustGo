import SwiftUI

enum BuddyPose {
    case idle
    case excited
    case celebrating
    case waiting
}

enum BuddyPixel: Int {
    case empty = 0
    case outline
    case body
    case belly
    case eyeWhite
    case eyePupil
    case nose
}

struct PixelBuddyView: View {
    var stage: BuddyStage = .baby
    var pose: BuddyPose = .idle
    var pixelSize: CGFloat = 4

    @State private var bounce: CGFloat = 0

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
        .offset(y: bounce)
        .onAppear { startIdleAnimation() }
    }

    private func startIdleAnimation() {
        withAnimation(
            .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
        ) {
            bounce = -2
        }
    }

    private func color(for c: BuddyPixel) -> Color {
        switch c {
        case .empty:    return .clear
        case .outline:  return Palette.foxOrangeDark
        case .body:     return Palette.foxOrange
        case .belly:    return Palette.foxBelly
        case .eyeWhite: return Palette.foxBelly
        case .eyePupil: return Palette.buddyEye
        case .nose:     return Palette.buddyEye
        }
    }

    private var pattern: [[BuddyPixel]] {
        switch stage {
        case .egg:       return Self.eggPattern
        case .baby:      return pose == .excited ? Self.babyExcited : Self.babyIdle
        case .juvenile,
             .mature,
             .guardian:  return Self.babyIdle  // 后续阶段先复用，Phase 2 再扩
        }
    }

    private static let O: BuddyPixel = .outline
    private static let F: BuddyPixel = .body
    private static let W: BuddyPixel = .belly
    private static let e: BuddyPixel = .empty
    private static let i: BuddyPixel = .eyeWhite
    private static let p: BuddyPixel = .eyePupil
    private static let n: BuddyPixel = .nose

    static let eggPattern: [[BuddyPixel]] = [
        [e,e,e,O,O,O,O,e,e,e],
        [e,e,O,F,F,F,F,O,e,e],
        [e,O,F,F,W,F,F,F,O,e],
        [e,O,F,W,W,W,F,F,O,e],
        [e,O,F,W,W,W,F,F,O,e],
        [e,O,F,F,W,W,F,F,O,e],
        [e,e,O,F,F,F,F,O,e,e],
        [e,e,e,O,O,O,O,e,e,e],
    ]

    static let babyIdle: [[BuddyPixel]] = [
        [e,e,e,O,e,e,e,e,O,e,e,e],
        [e,e,O,F,O,e,e,O,F,O,e,e],
        [e,e,O,F,F,F,F,F,F,O,e,e],
        [e,O,F,F,F,F,F,F,F,F,O,e],
        [e,O,F,i,p,F,F,p,i,F,O,e],
        [e,O,F,F,F,n,n,F,F,F,O,e],
        [e,O,F,W,W,W,W,W,W,F,O,e],
        [e,e,O,W,W,W,W,W,W,O,e,e],
        [e,e,e,O,O,e,e,O,O,e,e,e],
    ]

    static let babyExcited: [[BuddyPixel]] = [
        [e,O,e,O,e,e,e,e,O,e,O,e],
        [O,F,O,F,O,e,e,O,F,O,F,O],
        [O,F,F,F,F,F,F,F,F,F,F,O],
        [e,O,F,F,F,F,F,F,F,F,O,e],
        [e,O,F,p,p,F,F,p,p,F,O,e],
        [e,O,F,F,F,n,n,F,F,F,O,e],
        [e,O,F,W,W,W,W,W,W,F,O,e],
        [e,e,O,W,W,W,W,W,W,O,e,e],
        [e,e,e,O,O,e,e,O,O,e,e,e],
    ]
}

#Preview("buddy poses") {
    HStack(spacing: 24) {
        VStack { Text("egg"); PixelBuddyView(stage: .egg, pixelSize: 6) }
        VStack { Text("idle"); PixelBuddyView(stage: .baby, pose: .idle, pixelSize: 6) }
        VStack { Text("excited"); PixelBuddyView(stage: .baby, pose: .excited, pixelSize: 6) }
    }
    .padding()
    .background(Palette.bg)
}
