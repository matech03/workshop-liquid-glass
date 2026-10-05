import SwiftUI

// Level 4 · ĐỌC CODE: ripple tại điểm chạm. Shader ở Shared/Shaders.metal → ripple().
// Input của shader: origin (điểm chạm), time, amplitude, frequency, decay.
// RippleCore: onTapGesture lấy location → origin; keyframeAnimator chạy time từ 0 đến 1.5 s.
// `stopsWhenIdle`: GOOD tắt shader khi sóng đã xong, BAD để shader chạy mãi.
// Closure của keyframeAnimator là @Sendable (Swift 6): phải capture giá trị trước, ví dụ [origin].

struct RippleCore: View {
    var stopsWhenIdle = true
    var amplitude = 12.0, frequency = 0.08, decay = 2.0
    @State private var origin = CGPoint.zero
    @State private var taps = 0
    @State private var size = CGSize.zero

    var body: some View {
        MeshBackground(time: 2)
            .keyframeAnimator(initialValue: 0.0, trigger: taps) { [origin, amplitude, frequency, decay, stopsWhenIdle] view, t in
                let active = t > 0 && t < 1.5
                return view
                    .layerEffect(
                        ShaderLibrary.ripple(.float2(origin), .float(t),
                                             .float(amplitude), .float(frequency), .float(decay)),
                        maxSampleOffset: CGSize(width: amplitude, height: amplitude),
                        isEnabled: stopsWhenIdle ? active : true) // GOOD: sóng đã tắt thì bỏ shader khỏi pipeline
                    .overlay(alignment: .bottomTrailing) { ShaderBadge(on: stopsWhenIdle ? active : true) }
            } keyframes: { _ in
                MoveKeyframe(0)
                LinearKeyframe(1.5, duration: 1.5)
            }
            .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
            .onTapGesture { origin = $0; taps += 1 }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: taps)
            .task {
                while !Task.isCancelled {
                    try? await Task.sleep(for: .seconds(2.6))
                    origin = CGPoint(x: size.width * .random(in: 0.25...0.75), y: size.height * .random(in: 0.35...0.75))
                    taps += 1
                }
            }
    }
}

/// Chấm nhỏ ở góc: sáng khi shader đang chạy, mờ khi đã bỏ khỏi pipeline.
private struct ShaderBadge: View {
    let on: Bool

    var body: some View {
        Image(systemName: on ? "bolt.fill" : "bolt.slash")
            .font(.caption.weight(.semibold))
            .foregroundStyle(on ? Palette.warm : Palette.neutral)
            .frame(width: 28, height: 28)
            .background(.black.opacity(0.3), in: .circle)
            .padding(12)
    }
}

#Preview { RippleCore() }
