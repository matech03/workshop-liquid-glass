import SwiftUI

/// Nền phía sau demo. Glass cần chi tiết phía sau thì mới thấy được khúc xạ, nên nền nào cũng có lưới chấm.
/// `.muted` (mặc định): tối, chỉ có hai vệt màu dịu ở góc, để mắt nhìn vào phần tử đang demo.
/// `.vivid`: nhiều màu, cho demo cần thấy rõ nền bị biến đổi.
struct Backdrop: View {
    enum Style { case muted, vivid }

    var style: Style = .muted
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            switch style {
            case .muted:
                ZStack {
                    Palette.background
                    RadialGradient(colors: [Palette.violet.opacity(0.45), .clear], center: .topLeading, startRadius: 0, endRadius: 460)
                    RadialGradient(colors: [Palette.teal.opacity(0.30), .clear], center: .bottomTrailing, startRadius: 0, endRadius: 420)
                    BackdropPattern(opacity: 0.10)
                }
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
        Palette.navy, Palette.violet, Palette.slate,
        Palette.rose, Palette.peach, Palette.teal,
        Palette.navy, Palette.violet, Palette.sand,
    ]
}

/// Lưới chấm mờ: đủ chi tiết để thấy glass khúc xạ, không tranh sự chú ý với phần tử đang demo.
private struct BackdropPattern: View {
    var opacity = 0.22

    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 28
            var dots = Path()
            for x in stride(from: step / 2, to: size.width, by: step) {
                for y in stride(from: step / 2, to: size.height, by: step) {
                    dots.addEllipse(in: CGRect(x: x - 1.5, y: y - 1.5, width: 3, height: 3))
                }
            }
            context.fill(dots, with: .color(.white.opacity(opacity)))
        }
        .allowsHitTesting(false)
    }
}
