import SwiftUI

// Level 3 · LIVE CODE: thả tay khi đang kéo → chuyển động giảm tốc theo hàm mũ (decay), như cuộn trong UIScrollView.
// x(t) = Δ·(1 − e^(−k·t)),  v(t) = Δ·k·e^(−k·t). Với Δ = v₀ / k thì v(0) = v₀: vận tốc lúc bắt đầu bằng vận tốc lúc thả tay.
// k mặc định lấy từ UIScrollView.DecelerationRate.normal = 0.998 mỗi ms → k = −ln(0.998) · 1000 ≈ 2.0 /s.

nonisolated struct Decay: CustomAnimation {
    var k = 2.0 // hệ số giảm tốc (1/s)

    func animate<V: VectorArithmetic>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? {
        let remaining = exp(-k * time)
        return remaining < 0.002 ? nil : value.scaled(by: 1 - remaining) // nil = đã xong (còn < 0.2% quãng đường)
    }

    func velocity<V: VectorArithmetic>(value: V, time: TimeInterval, context: AnimationContext<V>) -> V? {
        value.scaled(by: k * exp(-k * time)) // để animation kế tiếp (spring) nhận đúng vận tốc hiện tại
    }

    func shouldMerge<V: VectorArithmetic>(previous: Animation, value: V, time: TimeInterval, context: inout AnimationContext<V>) -> Bool {
        false
    }
}

struct DecayDemo: View {
    static let scrollViewK = -log(0.998) * 1000 // ≈ 2.002

    @State private var k = Self.scrollViewK
    @State private var position: CGPoint?
    @State private var dragStart: CGPoint?
    @State private var projected: CGPoint?
    @State private var releaseSpeed: Double = 0

    var body: some View {
        GeometryReader { geo in
            let home = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.4)
            ZStack {
                Backdrop()
                if let projected {
                    // Điểm dừng tính trước: p₀ + v₀ / k
                    Circle()
                        .strokeBorder(.white.opacity(0.8), style: .init(lineWidth: 2, dash: [5, 5]))
                        .frame(width: 84, height: 84)
                        .position(projected)
                }
                GlassCircle(size: 76, symbol: "hand.draw")
                    .position(position ?? home)
                    .gesture(drag(home: home))
            }
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom) {
            ControlPanel {
                LabeledContent("k (1/s)") {
                    Text(k, format: .number.precision(.fractionLength(2))).monospacedDigit()
                }
                Slider(value: $k, in: 0.5...8)
                HStack {
                    Button("UIScrollView .normal (0.998)") { k = Self.scrollViewK }
                    Spacer()
                    Button(".fast (0.99)") { k = -log(0.99) * 1000 }
                }
                .buttonStyle(.bordered)
                .font(.caption.monospaced())
                LabeledContent("v₀ lúc thả") {
                    Text("\(Int(releaseSpeed)) pt/s").monospacedDigit()
                }
                Text("Điểm dừng = p₀ + v₀ / k. Viền nét đứt là điểm dừng tính trước.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func drag(home: CGPoint) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let start = dragStart ?? position ?? home
                dragStart = start
                position = CGPoint(x: start.x + value.translation.width, y: start.y + value.translation.height)
                projected = nil
            }
            .onEnded { value in
                dragStart = nil
                let p = position ?? home
                let v = value.velocity
                releaseSpeed = (v.width * v.width + v.height * v.height).squareRoot()
                let target = CGPoint(x: p.x + v.width / k, y: p.y + v.height / k)
                projected = target
                withAnimation(Animation(Decay(k: k))) { position = target }
            }
    }
}

#Preview { DecayDemo() }
