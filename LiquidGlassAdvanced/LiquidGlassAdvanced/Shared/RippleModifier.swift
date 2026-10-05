import SwiftUI

/// Ripple của Level 4 đóng gói thành ViewModifier: sóng lan ra từ điểm chạm.
struct RippleOnTap: ViewModifier {
    var amplitude: Double = 12
    var frequency: Double = 0.08
    var decay: Double = 2
    @Binding var origin: CGPoint
    @Binding var trigger: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        // Closure của keyframeAnimator là @Sendable: chụp giá trị thay vì đọc thuộc tính view.
        let (origin, amplitude, frequency, decay) = (origin, amplitude, frequency, decay)
        let enabled = !reduceMotion
        content
            .keyframeAnimator(initialValue: 0.0, trigger: trigger) { view, t in
                view.layerEffect(
                    ShaderLibrary.ripple(.float2(origin), .float(t),
                                         .float(amplitude), .float(frequency), .float(decay)),
                    maxSampleOffset: CGSize(width: amplitude, height: amplitude),
                    isEnabled: enabled && t > 0 && t < 1.5 // ngoài khoảng chạy thì bỏ shader khỏi pipeline
                )
            } keyframes: { _ in
                MoveKeyframe(0)
                LinearKeyframe(1.5, duration: 1.5)
            }
    }
}

private struct RippleOnTapSelfContained: ViewModifier {
    var amplitude: Double
    @State private var origin = CGPoint.zero
    @State private var trigger = 0

    func body(content: Content) -> some View {
        content
            .modifier(RippleOnTap(amplitude: amplitude, origin: $origin, trigger: $trigger))
            .onTapGesture { location in
                origin = location
                trigger += 1
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: trigger)
    }
}

extension View {
    func rippleOnTap(amplitude: Double = 12) -> some View {
        modifier(RippleOnTapSelfContained(amplitude: amplitude))
    }
}
