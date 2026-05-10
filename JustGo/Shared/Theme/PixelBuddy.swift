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

enum BuddyAnimation {
    case gentle   // 静止时的轻微呼吸
    case lively   // 更明显的弹跳 + 横摆 + 偶尔眨眼
}

struct PixelBuddyView: View {
    var stage: BuddyStage = .baby
    var pose: BuddyPose = .idle
    var pixelSize: CGFloat = 4
    var animation: BuddyAnimation = .gentle

    @State private var bounce: CGFloat = 0
    @State private var sway: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var poseBlink: Bool = false

    private var effectivePose: BuddyPose {
        if animation == .lively && poseBlink { return .excited }
        return pose
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<currentPattern.count, id: \.self) { y in
                HStack(spacing: 0) {
                    ForEach(0..<currentPattern[y].count, id: \.self) { x in
                        Rectangle()
                            .fill(color(for: currentPattern[y][x]))
                            .frame(width: pixelSize, height: pixelSize)
                    }
                }
            }
        }
        .offset(x: sway, y: bounce)
        .rotationEffect(.degrees(rotation))
        .onAppear {
            switch animation {
            case .gentle: startGentleAnimation()
            case .lively: startLivelyAnimation()
            }
        }
    }

    private func startGentleAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            bounce = -2
        }
    }

    private func startLivelyAnimation() {
        withAnimation(.easeInOut(duration: 0.7).repeatForever(autoreverses: true)) {
            bounce = -6
        }
        withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
            sway = 5
        }
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            rotation = 5
        }
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(.easeInOut(duration: 0.3)) {
                    poseBlink.toggle()
                }
            }
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

    private var currentPattern: [[BuddyPixel]] {
        switch stage {
        case .egg:       return Self.eggPattern
        case .baby:      return effectivePose == .excited ? Self.babyExcited : Self.babyIdle
        case .juvenile,
             .mature,
             .guardian:  return Self.babyIdle
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
