import SwiftUI

// Tích hợp · Checkpoint 1: nền MeshGradient động (TimelineView đổi điểm giữa theo thời gian).

struct Checkpoint1: View {
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
    }
}

#Preview { Checkpoint1() }
