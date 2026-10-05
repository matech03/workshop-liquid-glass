import SwiftUI

/// Level 1 · Phản hồi chạm. Hai tab, mỗi tab một cặp GOOD / BAD.
struct TouchFeedbackDemo: View {
    enum Tab: String, CaseIterable { case highlight = "Highlight", haptic = "Haptic" }

    var body: some View {
        DemoTabs(Tab.highlight) { tab in
            switch tab {
            case .highlight:
                // View tự vẽ: thiếu .interactive() thì chạm không sáng, không co giãn
                GoodBad(good: ".glassEffect(.regular.interactive())", bad: ".glassEffect(.regular)") {
                    TapButton(glass: .regular.interactive())
                } badContent: {
                    TapButton(glass: .regular)
                }
            case .haptic:
                // sensoryFeedback phát khi trigger ĐỔI giá trị. Gán lại cùng giá trị thì không rung.
                GoodBad(good: "trigger: count  // đổi mỗi lần", bad: "trigger: liked  // true lặp lại") {
                    HapticButton(changesTrigger: true)
                } badContent: {
                    HapticButton(changesTrigger: false)
                }
            }
        }
    }
}

private struct TapButton: View {
    let glass: Glass

    var body: some View {
        Image(systemName: "hand.tap.fill")
            .font(.largeTitle)
            .frame(width: 110, height: 110)
            .glassEffect(glass, in: .circle)
            .onTapGesture {}
    }
}

private struct HapticButton: View {
    let changesTrigger: Bool
    @State private var count = 0
    @State private var liked = false
    @State private var taps = 0

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "heart.fill")
                .font(.largeTitle)
                .frame(width: 110, height: 110)
                .glassEffect(.regular.interactive(), in: .circle)
                .onTapGesture {
                    taps += 1
                    if changesTrigger { count += 1 } else { liked = true }
                }
            // Số lần chạm · giá trị trigger: BAD đứng yên ở true, nên không rung lại
            Text("\(taps) · \(changesTrigger ? "\(count)" : "\(liked)")")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(Palette.label)
        }
        .sensoryFeedback(.impact(weight: .medium), trigger: count)
        .sensoryFeedback(.impact(weight: .medium), trigger: liked)
    }
}

#Preview { TouchFeedbackDemo() }
