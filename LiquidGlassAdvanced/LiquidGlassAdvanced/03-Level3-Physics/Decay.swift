import SwiftUI

// Level 3 · ĐỌC CODE: thả tay khi đang kéo → chuyển động giảm tốc theo hàm mũ (decay), như cuộn trong UIScrollView.
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
