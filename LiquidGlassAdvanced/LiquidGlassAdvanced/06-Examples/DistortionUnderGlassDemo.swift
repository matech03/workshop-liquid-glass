import SwiftUI

/// Ví dụ · Shader effects: hai hiệu ứng biến dạng bằng distortionEffect (kỹ thuật Level 4). Khác nhau ở chỗ shader bọc gì.
/// Lens: shader bọc nền, glass ở trên. Glass giữ nguyên hình, khúc xạ phần nền đã phóng to: hợp cho kính lúp, vùng chọn.
/// Jelly: shader bọc cả nền lẫn nút glass, nên chính nút cong theo ngón tay. Chữ cũng cong và vùng chạm vẫn ở frame cũ,
/// nên chỉ biến dạng lúc đang kéo; thả tay thì spring đưa lực về 0, nút rung nhẹ rồi về đúng hình.

// MARK: - Thấu kính

struct LensField: View {
    @State private var center: CGPoint?
    @State private var dragging = false
    private let lens: CGFloat = 130

    var body: some View {
        GeometryReader { geo in
            let c = center ?? CGPoint(x: geo.size.width * 0.3, y: geo.size.height / 2 + 14)
            TimelineView(.animation) { context in
                ZStack {
                    GridBackdrop()
                        .modifier(Warp(center: c, radius: lens * 0.6, strength: 0.45, time: context.date.timeIntervalSinceReferenceDate))
                    Circle()
                        .fill(.clear)
                        .frame(width: lens, height: lens)
                        .glassEffect(.clear.interactive(), in: .circle)
                        .position(c)
                }
            }
            .contentShape(.rect)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { v in
                    withAnimation(.interactiveSpring) { center = v.location }
                    dragging = true
                }
                .onEnded { v in
                    // Thả tay: spring tới predictedEndLocation, nhận vận tốc của gesture
                    withAnimation(.spring(duration: 0.6, bounce: 0.3)) {
                        center = v.predictedEndLocation.clamped(to: geo.size, inset: lens / 2)
                    }
                    dragging = false
                })
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: dragging)
    }
}

// MARK: - Dẻo

struct JellyField: View {
    @State private var center: CGPoint?
    @State private var strength = 0.0
    @State private var taps = 0

    var body: some View {
        GeometryReader { geo in
            let mid = middle(of: geo.size)
            TimelineView(.animation) { context in
                ZStack {
                    GridBackdrop()
                    postButton.position(mid)
                }
                .modifier(Warp(center: center ?? mid, radius: 90, strength: strength, time: context.date.timeIntervalSinceReferenceDate))
            }
            .contentShape(.rect)
            .gesture(DragGesture(minimumDistance: 6) // > 0 để chạm vào nút vẫn là chạm, không thành kéo
                .onChanged { v in
                    withAnimation(.interactiveSpring) {
                        center = v.location
                        strength = 0.6
                    }
                }
                .onEnded { _ in release() })
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: strength > 0)
        .sensoryFeedback(.impact(weight: .light), trigger: taps)
    }

    private var postButton: some View {
        Button { taps += 1 } label: {
            Label("Post", systemImage: "paperplane.fill")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 210, height: 60)
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .capsule)
    }

    /// Spring có bounce đưa lực về 0 và vượt qua 0 một chút: nút co lại rồi về đúng hình, như thạch.
    private func release() {
        withAnimation(.spring(duration: 0.7, bounce: 0.5)) { strength = 0 }
    }

    private func middle(of size: CGSize) -> CGPoint { CGPoint(x: size.width / 2, y: size.height / 2 + 14) }
}

// MARK: - Chung

/// Nền lưới: đường thẳng cho thấy rõ chỗ nào bị cong. Màu dịu để mắt nhìn vào phần biến dạng.
private struct GridBackdrop: View {
    var body: some View {
        Canvas { ctx, size in
            ctx.fill(Path(CGRect(origin: .zero, size: size)),
                     with: .linearGradient(Gradient(colors: [Palette.navy, Palette.background]),
                                           startPoint: .zero, endPoint: CGPoint(x: size.width, y: size.height)))
            var grid = Path()
            for x in stride(from: 0, through: size.width, by: 24) {
                grid.move(to: CGPoint(x: x, y: 0)); grid.addLine(to: CGPoint(x: x, y: size.height))
            }
            for y in stride(from: 0, through: size.height, by: 24) {
                grid.move(to: CGPoint(x: 0, y: y)); grid.addLine(to: CGPoint(x: size.width, y: y))
            }
            ctx.stroke(grid, with: .color(.white.opacity(0.16)), lineWidth: 1)
        }
    }
}

/// Tham số shader không tự animate. Đưa tâm và lực vào animatableData
/// để vùng biến dạng đi cùng spring thay vì nhảy thẳng tới giá trị cuối.
private struct Warp: ViewModifier, Animatable {
    var center: CGPoint
    var radius: Double
    var strength: Double
    var time: Double

    var animatableData: AnimatablePair<CGPoint.AnimatableData, Double> {
        get { AnimatablePair(center.animatableData, strength) }
        set { center.animatableData = newValue.first; strength = newValue.second }
    }

    func body(content: Content) -> some View {
        content.distortionEffect(
            ShaderLibrary.fingerWarp(.float2(center), .float(radius), .float(strength), .float(time)),
            maxSampleOffset: CGSize(width: 80, height: 80)
        )
    }
}

#Preview { LensField() }
