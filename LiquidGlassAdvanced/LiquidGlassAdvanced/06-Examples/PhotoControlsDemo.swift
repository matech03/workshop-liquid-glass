import SwiftUI

/// Ví dụ · Thông dụng: nút điều khiển trên ảnh, video. `.clear` trong hơn `.regular` nên hợp với nền nhiều hình ảnh,
/// nhưng icon trắng sẽ chìm ở vùng sáng. Cần thêm một lớp làm tối nền phía sau nút.
/// GOOD: `.clear` + lớp LinearGradient làm tối. BAD: `.clear` đặt thẳng lên nền sáng.
/// Nền phẳng hoặc nền chữ thì dùng `.regular`.
struct PhotoControlsDemo: View {
    var body: some View {
        GoodBad(good: ".clear + darkening LinearGradient", bad: ".clear on a bright background") {
            PlayerOverlay(dims: true)
        } badContent: {
            PlayerOverlay(dims: false)
        }
    }
}

private struct PlayerOverlay: View {
    let dims: Bool
    @State private var playing = true

    var body: some View {
        ZStack(alignment: .bottom) {
            BrightScene(playing: playing)
            if dims {
                // Lớp làm tối chỉ ở nửa dưới, nằm sau nút: ảnh phía trên giữ nguyên
                LinearGradient(colors: [.clear, .black.opacity(0.45)], startPoint: .center, endPoint: .bottom)
                    .allowsHitTesting(false)
            }
            controls.padding(.bottom, 22)
        }
        .sensoryFeedback(.impact(weight: .light), trigger: playing)
    }

    private var controls: some View {
        GlassEffectContainer(spacing: 16) {
            VStack(spacing: 14) {
                HStack(spacing: 18) {
                    button("gobackward.15", size: 52) {}
                    button(playing ? "pause.fill" : "play.fill", size: 68) { playing.toggle() }
                    button("goforward.15", size: 52) {}
                }
                Capsule()
                    .fill(.white)
                    .frame(width: 90, height: 4)
                    .frame(width: 230, alignment: .leading)
                    .padding(.horizontal, 14)
                    .frame(height: 22)
                    .glassEffect(.clear, in: .capsule)
            }
        }
    }

    private func button(_ symbol: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.38, weight: .semibold))
            .foregroundStyle(.white)
            .contentTransition(.symbolEffect(.replace))
            .frame(width: size, height: size)
            .glassEffect(.clear.interactive(), in: .circle)
            .onTapGesture(perform: action)
    }
}

/// Giả lập một khung hình video: trời sáng, mặt trời, mây trôi. Có vùng gần trắng để thấy icon trắng bị chìm.
private struct BrightScene: View {
    let playing: Bool

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30, paused: !playing)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                ctx.fill(Path(CGRect(origin: .zero, size: size)),
                         with: .linearGradient(Gradient(colors: [Color(red: 0.55, green: 0.80, blue: 0.98), Color(red: 0.97, green: 0.97, blue: 0.93)]),
                                               startPoint: .zero, endPoint: CGPoint(x: 0, y: size.height)))
                let sun = CGRect(x: size.width * 0.68, y: size.height * 0.12, width: 70, height: 70)
                ctx.fill(Path(ellipseIn: sun.insetBy(dx: -30, dy: -30)), with: .color(.yellow.opacity(0.25)))
                ctx.fill(Path(ellipseIn: sun), with: .color(Color(red: 1, green: 0.95, blue: 0.75)))
                for i in 0..<5 {
                    let x = (Double(i) * 0.27 + t * 0.03).truncatingRemainder(dividingBy: 1.3) - 0.15
                    let y = 0.45 + 0.1 * Double(i % 3)
                    cloud(&ctx, at: CGPoint(x: size.width * x, y: size.height * y), scale: 0.8 + 0.15 * Double(i % 2))
                }
            }
        }
    }

    private func cloud(_ ctx: inout GraphicsContext, at p: CGPoint, scale s: Double) {
        var path = Path()
        for (dx, dy, r) in [(0.0, 0.0, 34.0), (38, -12, 42), (80, 0, 32), (40, 14, 36)] {
            path.addEllipse(in: CGRect(x: p.x + dx * s - r * s, y: p.y + dy * s - r * s, width: 2 * r * s, height: 2 * r * s))
        }
        ctx.fill(path, with: .color(.white))
    }
}

#Preview { PhotoControlsDemo() }
