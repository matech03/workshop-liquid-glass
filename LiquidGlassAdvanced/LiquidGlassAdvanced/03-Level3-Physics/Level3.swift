import SwiftUI

/// Level 3 · Chuyển động vật lý. Ba demo, chọn bằng menu trên tiêu đề. Dòng chữ trên cùng: thao tác · điều cần thấy.
/// - Interrupt: spring giữ vận tốc khi bị ngắt, ease chạy nốt animation cũ (GOOD / BAD).
/// - Drag & release: thả tay thì nhắm theo `predictedEndLocation`, kéo quá mép thì rubber band (GOOD / BAD, DragReleaseDemo.swift).
/// - Spring presets: `.smooth`, `.snappy`, `.bouncy`, custom, kèm đồ thị đường đi (SpringPresetsDemo.swift).
struct Level3_Motion: View {
    enum Tab: String, CaseIterable { case interrupt = "Interrupt", dragRelease = "Drag & release", presets = "Spring presets" }

    var body: some View {
        DemoTabs(Tab.interrupt) { tab in
            switch tab {
            case .interrupt:
                GoodBad(good: ".spring(duration: 0.55, bounce: 0.15)", bad: ".easeInOut(duration: 0.55)") {
                    InterruptCard(animation: .spring(duration: 0.55, bounce: 0.15))
                } badContent: {
                    InterruptCard(animation: .easeInOut(duration: 0.55))
                }
                .safeAreaInset(edge: .top) {
                    DemoCaption("Tap twice · spring turns back, ease overshoots")
                }
            case .dragRelease:
                GoodBad(good: "nearest(predictedEndLocation) · .spring · rubber band", bad: "nearest(location) · .easeInOut · clamp") {
                    DragReleaseWindow(physical: true)
                } badContent: {
                    DragReleaseWindow(physical: false)
                }
                .safeAreaInset(edge: .top) {
                    DemoCaption("Flick to a corner · follows momentum vs. release point")
                }
            case .presets:
                SpringPresetsDemo()
            }
        }
    }
}

// MARK: - Interrupt

/// Thẻ glass mở rộng / thu gọn khi chạm. Chạm lần hai khi thẻ đang chạy để ngắt giữa chừng.
/// Spring nhận vị trí và vận tốc hiện tại nên quay đầu êm ngay khi bị ngắt.
/// Ease không merge: animation cũ vẫn chạy nốt, cộng dồn với animation mới, nên thẻ đi tiếp một đoạn rồi mới quay.
private struct InterruptCard: View {
    let animation: Animation
    @State private var expanded = false

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "music.note")
            Text("Now Playing")
        }
        .font(.headline)
        .foregroundStyle(.white)
        .frame(width: expanded ? 300 : 150, height: expanded ? 190 : 56)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 26))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(.rect)
        .onTapGesture { withAnimation(animation) { expanded.toggle() } }
        .sensoryFeedback(.impact(weight: .light), trigger: expanded)
    }
}

#Preview { NavigationStack { Level3_Motion() } }
