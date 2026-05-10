import SwiftUI
import WatchKit

struct CompletionView: View {
    let result: SessionResult
    @Binding var path: [WatchRoute]
    @EnvironmentObject private var sync: WatchSessionDelegate

    @State private var phase: Int = 0  // 0=庆祝, 1=抱树苗, 2=跑出
    @State private var didTransfer = false

    var body: some View {
        VStack(spacing: 8) {
            switch phase {
            case 0:
                celebrate
            case 1:
                hugSapling
            default:
                runningOut
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if !didTransfer {
                sync.completeSession(result)
                didTransfer = true
            }
            WKInterfaceDevice.current().play(.success)
            scheduleNextPhase()
        }
    }

    private var celebrate: some View {
        VStack(spacing: 6) {
            Text("完成 🎉").font(.headline)
            PixelBuddyView(stage: .baby, pose: .excited, pixelSize: 4)
            Text(durationLine)
                .font(.system(.title3, design: .rounded).monospacedDigit())
        }
    }

    private var hugSapling: some View {
        VStack(spacing: 6) {
            Text("新树诞生").font(.headline)
            HStack(spacing: 4) {
                PixelBuddyView(stage: .baby, pose: .excited, pixelSize: 3)
                PixelTreeView(
                    pattern: PixelTreePatterns.oak(stage: 0),
                    pixelSize: 3
                )
            }
        }
    }

    private var runningOut: some View {
        VStack(spacing: 8) {
            Text("返回森林...").font(.caption).foregroundStyle(.secondary)
            HStack {
                Spacer()
                PixelBuddyView(stage: .baby, pose: .excited, pixelSize: 3)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var durationLine: String {
        let m = Int(result.duration / 60)
        let s = Int(result.duration) % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func scheduleNextPhase() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            phase = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                phase = 2
                WKInterfaceDevice.current().play(.directionUp)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    path.append(.nextPrompt)
                }
            }
        }
    }
}
