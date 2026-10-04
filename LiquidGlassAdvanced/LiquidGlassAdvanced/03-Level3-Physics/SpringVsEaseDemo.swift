import SwiftUI

/// Level 3 · Spring vs ease: hai nút A/B, ẩn nhãn đến khi bật "Hiện nhãn". Cùng duration 0.55 s, spring không nảy (bounce: 0)
/// để khác biệt chỉ nằm ở cách xử lý khi bị ngắt giữa chừng.
/// Spring: shouldMerge = true → nhận vị trí + vận tốc hiện tại, đổi đích liền mạch.
/// Timing curve: cộng dồn (additive), animation cũ vẫn chạy nốt về đích cũ → chững lại rồi tăng tốc khi đổi hướng.
struct SpringVsEaseDemo: View {
    @State private var revealed = false

    var body: some View {
        ZStack {
            Backdrop()
            HStack(spacing: 0) {
                Lane(name: "A", curve: ".spring(duration: 0.55, bounce: 0)",
                     animation: .spring(duration: 0.55, bounce: 0), revealed: revealed)
                Lane(name: "B", curve: ".easeInOut(duration: 0.55)",
                     animation: .easeInOut(duration: 0.55), revealed: revealed)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 10) {
                if revealed {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Spring: shouldMerge = true → nhận vị trí + vận tốc hiện tại, đổi đích liền mạch.")
                        Text("Timing curve: cộng dồn (additive), animation cũ vẫn chạy nốt về đích cũ → chững lại rồi tăng tốc khi đổi hướng.")
                    }
                    .font(.footnote)
                    .padding(14)
                    .background(.black.opacity(0.6), in: .rect(cornerRadius: 16))
                    .padding(.horizontal)
                    .transition(.opacity)
                }
                Toggle("Hiện nhãn", isOn: $revealed.animation(.smooth))
                    .fixedSize()
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(.black.opacity(0.55), in: .capsule)
            }
            .padding(.bottom, 8)
        }
    }
}

private struct Lane: View {
    let name: String
    let curve: String
    let animation: Animation
    let revealed: Bool

    @State private var up = false
    @State private var taps = 0

    var body: some View {
        VStack(spacing: 20) {
            Text(revealed ? curve : name)
                .font(revealed ? .caption.monospaced() : .largeTitle.bold())
                .multilineTextAlignment(.center)
                .contentTransition(.opacity)
                .frame(height: 44)

            GlassCircle(size: 76)
                .scaleEffect(up ? 1.25 : 0.85)
                .offset(y: up ? -150 : 150)
                .frame(maxHeight: .infinity)

            Button {
                taps += 1
                withAnimation(animation) { up.toggle() }
            } label: {
                Text(name).font(.title.bold()).frame(width: 84, height: 64)
            }
            .buttonStyle(.glass)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: taps)
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
        // Bấm liên tục khi animation đang chạy: chỗ khác biệt lộ rõ nhất
        .autoplay(every: 0.35) { withAnimation(animation) { up.toggle() } }
    }
}

#Preview { SpringVsEaseDemo() }
