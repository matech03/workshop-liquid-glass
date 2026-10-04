import SwiftUI

// Tích hợp · Checkpoint 2: + nút (Level 1 .interactive()), kéo được, thả tay thì spring về với vận tốc lúc thả (Level 3).

struct Checkpoint2: View {
    @State private var drag = CGSize.zero

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
    }

    private var controls: some View {
        Image(systemName: "sparkles")
            .font(.title)
            .frame(width: 88, height: 88)
            .glassEffect(.regular.interactive(), in: .circle)
            .offset(drag)
            .gesture(DragGesture()
                .onChanged { v in withAnimation(.interactiveSpring) { drag = v.translation } }
                .onEnded { _ in withAnimation(.spring(duration: 0.6, bounce: 0.45)) { drag = .zero } })
    }
}

#Preview { Checkpoint2() }
