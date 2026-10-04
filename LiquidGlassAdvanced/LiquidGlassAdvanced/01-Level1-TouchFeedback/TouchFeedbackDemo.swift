import SwiftUI

/// Level 1 · Phản hồi chạm: thị giác + xúc giác.
/// - Thị giác: `.interactive()` cho glass co giãn và sáng lên tại điểm chạm. `.buttonStyle(.glass)` có sẵn,
///   view tự dựng thì phải viết `.glassEffect(.regular.interactive())`.
/// - Xúc giác: `sensoryFeedback(_:trigger:)` phát khi giá trị `trigger` THAY ĐỔI, không phát theo gesture.
///   Chạm mà state không đổi thì không có haptic.
struct TouchFeedbackDemo: View {
    enum Feedback: String, CaseIterable, Identifiable {
        case selection, light, heavy, success
        var id: Self { self }

        var value: SensoryFeedback {
            switch self {
            case .selection: .selection
            case .light: .impact(weight: .light)
            case .heavy: .impact(weight: .heavy)
            case .success: .success
            }
        }

        var label: String {
            switch self {
            case .selection: ".selection"
            case .light: ".impact(.light)"
            case .heavy: ".impact(.heavy)"
            case .success: ".success"
            }
        }
    }

    @State private var interactive = true
    @State private var haptics = true
    @State private var feedback = Feedback.light
    @State private var count = 0     // trigger: tăng mỗi lần chạm
    @State private var taps = 0      // chỉ đếm số lần chạm, không dùng làm trigger
    @State private var countOnTap = true

    var body: some View {
        ZStack {
            Backdrop()
            VStack(spacing: 28) {
                HStack(spacing: 28) {
                    VStack(spacing: 10) {
                        // .buttonStyle(.glass): phản hồi chạm có sẵn, không cần .interactive()
                        Button { tap() } label: {
                            Image(systemName: "hand.tap").font(.title).frame(width: 64, height: 64)
                        }
                        .buttonStyle(.glass)
                        Text(".buttonStyle(.glass)").font(.caption2.monospaced())
                    }
                    VStack(spacing: 10) {
                        // View tự dựng: phải bật .interactive() thì mới có phản hồi khi chạm
                        Image(systemName: "hand.tap.fill")
                            .font(.title)
                            .frame(width: 92, height: 92)
                            .glassEffect(.regular.interactive(interactive), in: .circle)
                            .onTapGesture { tap() }
                        Text(interactive ? ".glassEffect(\n.regular.interactive())" : ".glassEffect(\n.regular)")
                            .font(.caption2.monospaced())
                            .multilineTextAlignment(.center)
                    }
                }

                VStack(spacing: 4) {
                    Text("số lần chạm: \(taps)")
                    Text("trigger (count): \(count)")
                        .foregroundStyle(countOnTap ? .primary : .secondary)
                }
                .font(.callout.monospacedDigit())
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.black.opacity(0.5), in: .rect(cornerRadius: 14))
            }
        }
        .sensoryFeedback(feedback.value, trigger: count) { _, _ in haptics }
        .safeAreaInset(edge: .bottom) {
            ControlPanel {
                Toggle(".interactive() (view tự dựng)", isOn: $interactive)
                Toggle("sensoryFeedback", isOn: $haptics)
                Toggle("Chạm thì đổi trigger (count += 1)", isOn: $countOnTap)
                Picker("Loại phản hồi", selection: $feedback) {
                    ForEach(Feedback.allCases) { Text($0.label).tag($0) }
                }
                .pickerStyle(.menu)
                Text(countOnTap
                     ? "Haptic phát vì trigger đổi giá trị."
                     : "Trigger không đổi: chạm vẫn có highlight nhưng không có haptic.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .autoplay(every: 0.9) { tap() }
    }

    private func tap() {
        taps += 1
        if countOnTap { count += 1 }
    }
}

#Preview { TouchFeedbackDemo() }
