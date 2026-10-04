import SwiftUI

/// Nền nhiều màu, có chữ: glass cần nội dung phía sau thì mới thấy được khúc xạ.
struct Backdrop: View {
    enum Style { case vivid, flat }

    var style: Style = .vivid
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            switch style {
            case .flat:
                Color(white: 0.16)
            case .vivid:
                // Nền chỉ trôi chậm: 30 fps là đủ, để GPU dành cho phần tử đang demo.
                TimelineView(.animation(minimumInterval: 1 / 30, paused: reduceMotion)) { context in
                    MeshBackground(time: context.date.timeIntervalSinceReferenceDate)
                }
            }
        }
        .ignoresSafeArea()
    }
}

/// Vẽ nền theo thời gian truyền vào, để shader và TimelineView bên ngoài điều khiển.
struct MeshBackground: View {
    var time: Double
    var pattern = true

    var body: some View {
        MeshGradient(width: 3, height: 3, points: Self.points(time), colors: Self.colors)
            .overlay { if pattern { BackdropPattern() } }
    }

    static func points(_ t: Double) -> [SIMD2<Float>] {
        let s = Float(sin(t * 0.55)) * 0.2
        let c = Float(cos(t * 0.45)) * 0.2
        return [
            [0, 0], [0.5 + s * 0.6, 0], [1, 0],
            [0, 0.5 + c * 0.6], [0.5 + s, 0.5 + c], [1, 0.5 - s * 0.6],
            [0, 1], [0.5 - c * 0.6, 1], [1, 1],
        ]
    }

    static let colors: [Color] = [
        Color(red: 0.10, green: 0.07, blue: 0.32), Color(red: 0.38, green: 0.14, blue: 0.64), Color(red: 0.04, green: 0.32, blue: 0.58),
        Color(red: 0.94, green: 0.30, blue: 0.50), Color(red: 0.99, green: 0.56, blue: 0.24), Color(red: 0.18, green: 0.76, blue: 0.80),
        Color(red: 0.05, green: 0.12, blue: 0.36), Color(red: 0.56, green: 0.20, blue: 0.76), Color(red: 0.96, green: 0.80, blue: 0.34),
    ]
}

/// Lưới chấm mờ: đủ chi tiết để thấy glass khúc xạ, không tranh sự chú ý với phần tử đang demo.
private struct BackdropPattern: View {
    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 28
            var dots = Path()
            for x in stride(from: step / 2, to: size.width, by: step) {
                for y in stride(from: step / 2, to: size.height, by: step) {
                    dots.addEllipse(in: CGRect(x: x - 1.5, y: y - 1.5, width: 3, height: 3))
                }
            }
            context.fill(dots, with: .color(.white.opacity(0.28)))
        }
        .allowsHitTesting(false)
    }
}
