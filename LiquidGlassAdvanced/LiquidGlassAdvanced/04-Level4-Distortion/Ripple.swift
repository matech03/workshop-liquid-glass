import SwiftUI

// Level 4 · LIVE CODE: ripple tại điểm chạm. Shader ở Shared/Shaders.metal → ripple().
// Input của shader: origin (điểm chạm), time, amplitude, frequency, decay.
// RippleCore: onTapGesture lấy location → origin; keyframeAnimator chạy time từ 0 đến 1.5 s.
// Closure của keyframeAnimator là @Sendable (Swift 6): phải capture giá trị trước, ví dụ [origin].

struct RippleCore: View {
    var amplitude = 12.0, frequency = 0.08, decay = 2.0
    @State private var origin = CGPoint.zero
    @State private var taps = 0

    var body: some View {
        MeshBackground(time: 2)
            .keyframeAnimator(initialValue: 0.0, trigger: taps) { [origin, amplitude, frequency, decay] view, t in
                view.layerEffect(
                    ShaderLibrary.ripple(.float2(origin), .float(t),
                                         .float(amplitude), .float(frequency), .float(decay)),
                    maxSampleOffset: CGSize(width: amplitude, height: amplitude),
                    isEnabled: t > 0 && t < 1.5) // sóng đã tắt: bỏ shader khỏi pipeline
            } keyframes: { _ in
                MoveKeyframe(0)
                LinearKeyframe(1.5, duration: 1.5)
            }
            .onTapGesture { origin = $0; taps += 1 }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: taps)
            .autoplay(every: 1.6) { origin = CGPoint(x: .random(in: 100...300), y: .random(in: 250...500)); taps += 1 }
    }
}

struct RippleDemo: View {
    @State private var amplitude = 12.0
    @State private var frequency = 0.08
    @State private var decay = 2.0

    var body: some View {
        ZStack {
            RippleCore(amplitude: amplitude, frequency: frequency, decay: decay)
                .ignoresSafeArea()
            GlassCircle(size: 96).allowsHitTesting(false)
        }
        .safeAreaInset(edge: .bottom) {
            // Shader là pure function: cùng input → cùng output. Kéo slider rồi chạm lại.
            ControlPanel {
                slider("amplitude", value: $amplitude, in: 0...40, digits: 0, unit: "pt")
                slider("frequency", value: $frequency, in: 0.02...0.2, digits: 2, unit: "")
                slider("decay", value: $decay, in: 0.5...6, digits: 1, unit: "")
            }
        }
    }

    private func slider(_ name: String, value: Binding<Double>, in range: ClosedRange<Double>,
                        digits: Int, unit: String) -> some View {
        VStack(spacing: 4) {
            LabeledContent(name) {
                Text("\(value.wrappedValue, format: .number.precision(.fractionLength(digits))) \(unit)")
                    .monospacedDigit()
            }
            Slider(value: value, in: range)
        }
    }
}

#Preview { RippleDemo() }
