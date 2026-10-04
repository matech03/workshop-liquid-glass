import SwiftUI

/// Level 2 · Hòa nhau: chung container và gap < spacing.
/// Glass không lấy mẫu glass khác, nên chỉ các phần tử trong CÙNG một `GlassEffectContainer` mới hòa được.
/// `spacing` của container là khoảng cách bắt đầu hòa: hai mép gần nhau hơn `spacing` thì glass nối lại.
struct BlendingDemo: View {
    @State private var spacing: CGFloat = 40
    @State private var offset = CGSize(width: 150, height: 0)
    @State private var dragStart: CGSize?
    @State private var shared = true

    private let size: CGFloat = 96

    /// Khoảng cách giữa hai mép (tâm cách nhau |offset|, trừ đi hai bán kính).
    private var gap: CGFloat {
        max(0, (offset.width * offset.width + offset.height * offset.height).squareRoot() - size)
    }

    var body: some View {
        ZStack {
            Backdrop()
            if shared {
                GlassEffectContainer(spacing: spacing) { pair }
            } else {
                // Mỗi nút một container: không bao giờ hòa vào nhau
                ZStack {
                    GlassEffectContainer { fixedCircle }
                    GlassEffectContainer { movingCircle }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            ControlPanel {
                LabeledContent("GlassEffectContainer(spacing:)") {
                    Text("\(Int(spacing)) pt").monospacedDigit()
                }
                Slider(value: $spacing, in: 0...120)
                LabeledContent("Khoảng cách hai mép") {
                    Text("\(Int(gap)) pt").monospacedDigit()
                        .foregroundStyle(shared && gap < spacing ? .green : .primary)
                }
                Text(shared ? (gap < spacing ? "gap < spacing: hai phần tử hòa vào nhau" : "gap ≥ spacing: hai phần tử tách rời")
                            : "Hai container riêng: không hòa ở bất kỳ khoảng cách nào")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Toggle("Chung một container", isOn: $shared)
            }
        }
        .autoplay(every: 1.6) {
            withAnimation(.smooth(duration: 1.2)) {
                offset.width = offset.width > 120 ? 80 : 160
            }
        }
    }

    private var pair: some View {
        ZStack {
            fixedCircle
            movingCircle
        }
    }

    private var fixedCircle: some View {
        GlassCircle(size: size, symbol: "circle.dotted")
    }

    private var movingCircle: some View {
        GlassCircle(size: size, symbol: "hand.draw")
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        let start = dragStart ?? offset
                        dragStart = start
                        offset = CGSize(width: start.width + value.translation.width,
                                        height: start.height + value.translation.height)
                    }
                    .onEnded { _ in dragStart = nil }
            )
    }
}

#Preview { BlendingDemo() }
