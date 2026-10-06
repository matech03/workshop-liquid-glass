import SwiftUI

// Ví dụ · Shader effects: chọn một hiệu ứng shader trong bảng điều khiển. Shader ở Shared/Shaders.metal.
// Dùng ba modifier của Level 4 (colorEffect, distortionEffect, layerEffect) cho hiệu ứng tại điểm chạm.
// Ý tưởng từ krispuckett/SwiftUIShaders (MIT), viết lại gọn cho demo.
// - Chạm (Ripple, Pixelate, Glitch): keyframeAnimator chạy `time` từ 0 tới hết hiệu ứng, origin là điểm chạm.
// - Kéo (Vortex, Thermal): `strength` lên 1 khi kéo, spring về 0 khi thả.
// - Lens, Jelly: biến dạng nền dưới glass, khác nhau ở chỗ shader bọc gì (DistortionUnderGlassDemo.swift).
// Cả hai: `isEnabled` bỏ shader khỏi pipeline khi không chạy, và tắt hẳn khi bật Giảm chuyển động.
// Closure của keyframeAnimator là @Sendable (Swift 6): phải capture giá trị trước, ví dụ [origin].

nonisolated enum ShaderEffect: String, CaseIterable {
    case ripple = "Ripple", vortex = "Vortex", pixelate = "Pixelate", glitch = "Glitch", thermal = "Thermal"
    case lens = "Lens", jelly = "Jelly" // biến dạng nền dưới glass (DistortionUnderGlassDemo.swift)

    var isTap: Bool { self == .ripple || self == .pixelate || self == .glitch }

    var hint: String {
        switch self {
        case .lens: "Drag the lens"
        case .jelly: "Drag next to the button, then release"
        default: isTap ? "Tap the image" : "Drag on the image"
        }
    }

    var duration: Double {
        switch self {
        case .ripple: 1.5
        case .pixelate: 1.2
        default: 0.6
        }
    }

    var maxSampleOffset: CGSize {
        switch self {
        case .ripple: CGSize(width: 12, height: 12)
        case .pixelate: CGSize(width: 20, height: 20)
        case .glitch: CGSize(width: 48, height: 0)
        case .vortex: CGSize(width: 150, height: 150)
        case .thermal: .zero
        case .lens, .jelly: CGSize(width: 80, height: 80)
        }
    }

    /// Shader của hiệu ứng chạm tại thời điểm `t`.
    func tapShader(origin: CGPoint, time t: Double) -> Shader {
        switch self {
        case .pixelate: ShaderLibrary.pixelBurst(.float2(origin), .float(t), .float(40))
        case .glitch: ShaderLibrary.glitch(.float(t), .float(1))
        default: ShaderLibrary.ripple(.float2(origin), .float(t), .float(12), .float(0.08), .float(2))
        }
    }

    var code: String {
        switch self {
        case .ripple: ".layerEffect(ripple(origin, t), isEnabled: t < 1.5)"
        case .pixelate: ".layerEffect(pixelBurst(origin, t), isEnabled: t < 1.2)"
        case .glitch: ".layerEffect(glitch(t), isEnabled: t < 0.6)"
        case .vortex: ".distortionEffect(vortex(touch, twist), isEnabled: strength > 0)"
        case .thermal: ".colorEffect(thermal(touch, radius), isEnabled: strength > 0)"
        case .lens: "background.distortionEffect(fingerWarp) · glass on top"
        case .jelly: "ZStack { background; button }.distortionEffect(fingerWarp)"
        }
    }
}

struct ShaderEffectsDemo: View {
    @State private var effect = ShaderEffect.ripple

    var body: some View {
        Group {
            switch effect {
            case .lens: LensField()
            case .jelly: JellyField()
            default:
                if effect.isTap { TapCanvas(effect: effect) } else { DragCanvas(effect: effect) }
            }
        }
        .id(effect) // đổi hiệu ứng thì reset state
        .clipShape(.rect(cornerRadius: 28))
        .overlay { RoundedRectangle(cornerRadius: 28).strokeBorder(Palette.hairline) }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .background { Backdrop() }
        .safeAreaInset(edge: .top) { CodeHint(code: effect.code) }
        .safeAreaInset(edge: .bottom) {
            ControlPanel(spacing: 20, padding: 20) {
                MenuRow(title: "Effect", selection: $effect)
                Label(effect.hint, systemImage: effect.isTap ? "hand.tap" : "hand.draw")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// Hiệu ứng chạm: mỗi lần chạm chạy `time` từ 0 tới `duration`.
private struct TapCanvas: View {
    let effect: ShaderEffect
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var origin = CGPoint.zero
    @State private var taps = 0

    var body: some View {
        ShaderSample()
            .keyframeAnimator(initialValue: 0.0, trigger: taps) { [origin, effect, enabled = !reduceMotion] view, t in
                let active = enabled && t > 0 && t < effect.duration
                return view
                    .layerEffect(effect.tapShader(origin: origin, time: t), maxSampleOffset: effect.maxSampleOffset, isEnabled: active)
                    .overlay(alignment: .bottomTrailing) { ShaderBadge(on: active) }
            } keyframes: { [effect] _ in
                MoveKeyframe(0)
                LinearKeyframe(effect.duration, duration: effect.duration)
            }
            .onTapGesture { origin = $0; taps += 1 }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: taps)
    }
}

/// Hiệu ứng kéo: shader theo ngón tay, `strength` animate để thả tay thì hiệu ứng tan dần.
private struct DragCanvas: View {
    let effect: ShaderEffect
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var touch = CGPoint.zero
    @State private var strength = 0.0

    var body: some View {
        ShaderSample()
            .modifier(DragShader(effect: effect, touch: touch, strength: strength, enabled: !reduceMotion))
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { v in
                    touch = v.location
                    if strength < 1 { withAnimation(.smooth(duration: 0.25)) { strength = 1 } }
                }
                .onEnded { _ in withAnimation(.spring(duration: 0.8, bounce: 0.3)) { strength = 0 } })
            .sensoryFeedback(.impact(flexibility: .soft), trigger: strength == 1)
    }
}

/// Đưa `strength` vào animatableData: tham số của shader không tự animate theo withAnimation.
private struct DragShader: ViewModifier, Animatable {
    let effect: ShaderEffect
    let touch: CGPoint
    var strength: Double
    let enabled: Bool

    var animatableData: Double {
        get { strength }
        set { strength = newValue }
    }

    func body(content: Content) -> some View {
        let active = enabled && strength > 0.001
        Group {
            if effect == .vortex {
                content.distortionEffect(ShaderLibrary.vortex(.float2(touch), .float(150), .float(5 * strength)),
                                         maxSampleOffset: effect.maxSampleOffset, isEnabled: active)
            } else {
                content.colorEffect(ShaderLibrary.thermal(.float2(touch), .float(170), .float(strength)), isEnabled: active)
            }
        }
        .overlay(alignment: .bottomTrailing) { ShaderBadge(on: active) }
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

#Preview { ShaderEffectsDemo() }
