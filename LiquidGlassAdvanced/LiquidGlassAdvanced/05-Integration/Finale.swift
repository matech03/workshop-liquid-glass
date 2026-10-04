import SwiftUI

// Tích hợp · Đủ 4 level trên một màn hình:
// Level 1 .interactive() + sensoryFeedback · Level 2 glassEffectID morph · Level 3 drag + spring giữ vận tốc · Level 4 layerEffect ripple.

struct Finale: View {
    @State private var open = false
    @State private var drag = CGSize.zero
    @State private var origin = CGPoint.zero
    @State private var taps = 0
    @Namespace private var ns

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = Float(timeline.date.timeIntervalSinceReferenceDate)
            MeshGradient(width: 3, height: 3, points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5 + 0.2 * sin(t), 0.5 + 0.2 * cos(t)], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1],
            ], colors: [.indigo, .purple, .blue, .pink, .orange, .teal, .indigo, .purple, .yellow])
        }
        .keyframeAnimator(initialValue: 0.0, trigger: taps) { [origin] view, t in
            view.layerEffect(ShaderLibrary.ripple(.float2(origin), .float(t), .float(14), .float(0.08), .float(2)),
                             maxSampleOffset: CGSize(width: 14, height: 14), isEnabled: t > 0 && t < 1.5)
        } keyframes: { _ in
            MoveKeyframe(0); LinearKeyframe(1.5, duration: 1.5) // mỗi lần chạm chạy lại từ 0
        }
        .onTapGesture { origin = $0; taps += 1 }
        .ignoresSafeArea()
        .overlay { controls }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: taps)
        .sensoryFeedback(.selection, trigger: open)
    }

    private var controls: some View {
        GlassEffectContainer(spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: open ? "xmark" : "sparkles").font(.title).frame(width: 88, height: 88)
                    .glassEffect(.regular.interactive(), in: .circle)
                    .glassEffectID("main", in: ns)
                    .onTapGesture { withAnimation(.bouncy) { open.toggle() } }
                if open {
                    ForEach(["photo", "doc"], id: \.self) { icon in
                        Image(systemName: icon).font(.title2).frame(width: 64, height: 64)
                            .glassEffect(.regular.interactive(), in: .circle)
                            .glassEffectID(icon, in: ns)
                    }
                }
            }
        }
        .offset(drag)
        .gesture(DragGesture()
            .onChanged { v in withAnimation(.interactiveSpring) { drag = v.translation } }
            .onEnded { _ in withAnimation(.spring(duration: 0.6, bounce: 0.3)) { drag = .zero } })
    }
}

#Preview { Finale() }
