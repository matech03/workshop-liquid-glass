import SwiftUI

// Tích hợp · Checkpoint 3: + morph bằng glassEffectID (Level 2). Chạm nút để thêm/bớt 2 nút con. Còn thiếu: ripple (Level 4).

struct Checkpoint3: View {
    @State private var open = false
    @State private var drag = CGSize.zero
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
        .ignoresSafeArea()
        .overlay { controls }
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

#Preview { Checkpoint3() }
