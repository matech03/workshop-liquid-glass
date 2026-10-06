import SwiftUI

/// Level 3 · Drag & release: cửa sổ glass nổi kiểu Picture-in-Picture, thả tay thì bám vào một trong bốn góc.
/// GOOD (`physical`):
/// - Chọn góc gần `predictedEndLocation` (vị trí dự đoán theo vận tốc): hất nhẹ là sang góc đối diện.
/// - `.spring` nối tiếp `.interactiveSpring` nên nhận vận tốc của tay, không khựng lúc thả.
/// - Kéo quá mép: rubber band, càng kéo xa càng nặng tay.
/// BAD: chọn góc gần chỗ thả tay, `.easeInOut` bắt đầu từ vận tốc 0, mép chặn cứng.
/// Chấm tròn: góc mà mỗi bên nhắm tới, hiện lúc thả tay.
struct DragReleaseWindow: View {
    let physical: Bool
    @State private var position: CGPoint?
    @State private var dragStart: CGPoint?
    @State private var aim: CGPoint?
    @State private var corner = 0

    private let size = CGSize(width: 120, height: 76)
    private let inset: CGFloat = 16

    var body: some View {
        GeometryReader { geo in
            let corners = corners(in: geo.size)
            let current = position ?? corners[0]
            ZStack {
                ForEach(corners.indices, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Palette.hairline, style: .init(lineWidth: 1.5, dash: [5, 5]))
                        .frame(width: size.width, height: size.height)
                        .position(corners[i])
                }
                if let aim {
                    Circle()
                        .fill(physical ? Palette.good : Palette.bad)
                        .frame(width: 12, height: 12)
                        .position(aim)
                        .transition(.opacity)
                }
                Image(systemName: "play.rectangle.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: size.width, height: size.height)
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 18))
                    .position(current)
                    .gesture(DragGesture()
                        .onChanged { v in
                            let start = dragStart ?? current
                            dragStart = start
                            let raw = CGPoint(x: start.x + v.translation.width, y: start.y + v.translation.height)
                            withAnimation(.interactiveSpring) { position = constrained(raw, in: geo.size) }
                        }
                        .onEnded { v in
                            let start = dragStart ?? current
                            dragStart = nil
                            // GOOD nhắm theo vị trí dự đoán (có vận tốc), BAD theo chỗ thả tay
                            let translation = physical ? v.predictedEndTranslation : v.translation
                            let target = CGPoint(x: start.x + translation.width, y: start.y + translation.height)
                            let i = corners.indices.min { distance(corners[$0], target) < distance(corners[$1], target) }!
                            aim = corners[i]
                            corner = i
                            withAnimation(physical ? .spring(duration: 0.5, bounce: 0.25) : .easeInOut(duration: 0.5)) {
                                position = corners[i]
                            }
                            Task { try? await Task.sleep(for: .seconds(1.2)); withAnimation { aim = nil } }
                        })
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: corner)
    }

    private func corners(in s: CGSize) -> [CGPoint] {
        let x0 = inset + size.width / 2, x1 = s.width - inset - size.width / 2
        let y0 = inset + 34 + size.height / 2, y1 = s.height - inset - size.height / 2 // 34: chừa nhãn GOOD / BAD
        return [CGPoint(x: x0, y: y0), CGPoint(x: x1, y: y0), CGPoint(x: x0, y: y1), CGPoint(x: x1, y: y1)]
    }

    /// Trong vùng cho phép: theo tay 1:1. Quá mép: GOOD rubber band, BAD chặn cứng.
    private func constrained(_ p: CGPoint, in s: CGSize) -> CGPoint {
        let c = corners(in: s)
        return CGPoint(x: axis(p.x, c[0].x, c[3].x), y: axis(p.y, c[0].y, c[3].y))
    }

    private func axis(_ v: CGFloat, _ lo: CGFloat, _ hi: CGFloat) -> CGFloat {
        if v < lo { return physical ? lo - rubberBand(lo - v) : lo }
        if v > hi { return physical ? hi + rubberBand(v - hi) : hi }
        return v
    }

    /// Công thức lực cản của UIScrollView: càng kéo xa càng nặng tay, không bao giờ vượt quá `dimension`.
    private func rubberBand(_ offset: CGFloat, dimension: CGFloat = 80, c: CGFloat = 0.55) -> CGFloat {
        (1 - 1 / (offset * c / dimension + 1)) * dimension
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat { hypot(a.x - b.x, a.y - b.y) }
}

#Preview { DragReleaseWindow(physical: true) }
