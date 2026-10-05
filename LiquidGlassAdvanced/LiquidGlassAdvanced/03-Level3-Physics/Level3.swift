import SwiftUI

/// Level 3 · Chuyển động vật lý. Mỗi tab một cặp GOOD / BAD.
/// Spring khi bị ngắt, decay khi thả tay. Animate theo cung: ví dụ menu cung tròn (06-Examples/ArcMenu.swift).
struct Level3_Motion: View {
    enum Tab: String, CaseIterable { case interrupt = "Bị ngắt", release = "Thả tay" }

    var body: some View {
        DemoTabs(Tab.interrupt) { tab in
            switch tab {
            case .interrupt:
                // Ngắt giữa chừng: spring quay đầu theo lệnh mới; ease vẫn chạy nốt animation cũ (cộng dồn) nên trôi tiếp rồi mới quay
                GoodBad(good: ".spring(duration: 0.8, bounce: 0)", bad: ".easeInOut(duration: 0.8)") {
                    InterruptLane(animation: .spring(duration: 0.8, bounce: 0), color: Palette.good)
                } badContent: {
                    InterruptLane(animation: .easeInOut(duration: 0.8), color: Palette.bad)
                }
            case .release:
                // Thả tay: decay trượt tiếp theo vận tốc; dừng ngay thì mất quán tính
                GoodBad(good: "Animation(Decay(k: 2))", bad: "dừng tại chỗ thả") {
                    FlingLane(decays: true)
                } badContent: {
                    FlingLane(decays: false)
                }
            }
        }
    }
}

/// Mỗi chu kỳ: nút chạy sang phải, 0,35 s sau bị ngắt và được gọi về trái, rồi nghỉ.
/// Vệt bên dưới là vị trí nút theo thời gian (mới nhất ở trên), chấm là lúc bị ngắt:
/// khoảng cách từ chấm tới chỗ vệt quay đầu là quãng nút còn trôi sau khi người dùng đã đổi ý.
/// Chạm vào làn để tự ngắt.
private struct InterruptLane: View {
    let animation: Animation
    let color: Color
    @State private var right = false
    @State private var trace = MotionTrace()

    var body: some View {
        GeometryReader { geo in
            let minX = 60.0, maxX = geo.size.width - 60
            let top = geo.size.height * 0.3
            ZStack {
                TimelineView(.animation) { context in
                    Canvas { ctx, size in
                        trace.draw(in: &ctx, now: context.date.timeIntervalSinceReferenceDate, top: top, color: color)
                    }
                }
                GlassCircle(size: 56)
                    .modifier(TracedX(x: right ? maxX : minX, y: top, trace: trace))
            }
        }
        .contentShape(.rect)
        .onTapGesture { interrupt() }
        .task {
            while !Task.isCancelled {
                withAnimation(animation) { right = true }
                try? await Task.sleep(for: .seconds(0.35))
                interrupt()
                try? await Task.sleep(for: .seconds(1.6))
            }
        }
    }

    private func interrupt() {
        trace.mark()
        withAnimation(animation) { right.toggle() }
    }
}

/// Vị trí x đang hiển thị (đã nội suy) mỗi frame. Không phải @Observable: ghi trong body không kích hoạt cập nhật view.
private final class MotionTrace {
    private var samples: [(t: Double, x: Double)] = []
    private var marks: [Double] = []
    private let window = 2.0     // giây hiển thị trên vệt: đủ một chu kỳ ngắt
    private let speed = 105.0    // pt mỗi giây theo chiều dọc

    private var now: Double { Date().timeIntervalSinceReferenceDate }

    func add(_ x: Double) {
        samples.append((now, x))
        samples.removeAll { now - $0.t > window + 0.5 }
    }

    func mark() {
        marks.append(now)
        marks.removeAll { now - $0 > window }
    }

    /// x tại thời điểm t: giữ giá trị gần nhất trước t (giữa hai frame animation, nút đứng yên).
    private func x(at t: Double) -> Double? {
        samples.last { $0.t <= t }?.x ?? samples.first?.x
    }

    func draw(in ctx: inout GraphicsContext, now: Double, top: Double, color: Color) {
        guard !samples.isEmpty else { return }
        var path = Path()
        for step in 0...96 {
            let age = window * Double(step) / 96
            guard let x = x(at: now - age) else { continue }
            let point = CGPoint(x: x, y: top + age * speed)
            if step == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        ctx.stroke(path, with: .color(color.opacity(0.75)), style: .init(lineWidth: 3, lineCap: .round, lineJoin: .round))
        for t in marks {
            guard let x = x(at: t) else { continue }
            let y = top + (now - t) * speed
            ctx.fill(Path(ellipseIn: CGRect(x: x - 6, y: y - 6, width: 12, height: 12)), with: .color(.white))
        }
    }
}

/// Đưa x vào animatableData để mỗi frame của animation đều đi qua đây và được ghi lại.
private struct TracedX: ViewModifier, Animatable {
    var x: Double
    let y: Double
    let trace: MotionTrace

    var animatableData: Double {
        get { x }
        set { x = newValue }
    }

    func body(content: Content) -> some View {
        trace.add(x)
        return content.position(x: x, y: y)
    }
}

/// Kéo rồi thả nút. Có `decays` thì trượt tiếp tới p₀ + v₀ / k (vòng nét đứt), không thì dừng ngay.
private struct FlingLane: View {
    let decays: Bool
    @State private var position: CGPoint?
    @State private var dragStart: CGPoint?
    @State private var projected: CGPoint?

    var body: some View {
        GeometryReader { geo in
            let home = CGPoint(x: 70, y: geo.size.height / 2 + 14)
            ZStack {
                if let projected {
                    Circle()
                        .strokeBorder(.white.opacity(0.8), style: .init(lineWidth: 2, dash: [5, 5]))
                        .frame(width: 72, height: 72)
                        .position(projected)
                }
                GlassCircle(size: 64, symbol: "hand.draw")
                    .position(position ?? home)
                    .gesture(DragGesture()
                        .onChanged { v in
                            let start = dragStart ?? position ?? home
                            dragStart = start
                            position = CGPoint(x: start.x + v.translation.width, y: start.y + v.translation.height)
                            projected = nil
                        }
                        .onEnded { v in
                            dragStart = nil
                            guard decays else { return }
                            let k = 2.0, p = position ?? home
                            let target = CGPoint(x: p.x + v.velocity.width / k, y: p.y + v.velocity.height / k)
                                .clamped(to: geo.size, inset: 36)
                            projected = target
                            withAnimation(Animation(Decay(k: k))) { position = target }
                        })
            }
        }
    }
}

#Preview { Level3_Motion() }
