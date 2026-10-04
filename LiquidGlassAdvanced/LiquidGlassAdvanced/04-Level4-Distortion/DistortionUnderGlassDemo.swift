import SwiftUI
import CoreMotion

/// Level 4 · distortionEffect đặt trên lớp NỀN dưới glass: glass khúc xạ nền đã biến dạng.
/// Đặt trên cả glass thì glass cũng bị biến dạng theo, không còn là một lớp phía trên nền.
/// Kéo nút: tâm biến dạng đi theo. Nghiêng máy: highlight do shader `sheen` vẽ trượt theo.
/// Liquid Glass của hệ thống vốn đã có highlight phản ứng theo chuyển động máy; lớp sheen ở đây là shader tự viết.
struct DistortionUnderGlassDemo: View {
    enum Placement: String, CaseIterable, Identifiable {
        case below = "Dưới lớp glass (nền)", above = "Trên lớp glass (cả cụm)"
        var id: Self { self }
    }

    @State private var sensor = TiltSensor()
    @State private var center: CGPoint?
    @State private var dragging = false
    @State private var placement: Placement = Launch.flag("above") ? .above : .below

    var body: some View {
        GeometryReader { geo in
            let home = CGPoint(x: geo.size.width / 2, y: geo.size.height * 0.4)
            let c = center ?? home
            TimelineView(.animation) { context in
                let t = context.date.timeIntervalSinceReferenceDate
                let warp = Warp(center: c, strength: dragging ? 0.55 : 0.3, time: t)

                if placement == .below {
                    ZStack {
                        MeshBackground(time: t).modifier(warp)
                        GlassLens(tilt: sensor.read(time: t)).position(c)
                    }
                } else {
                    ZStack {
                        MeshBackground(time: t)
                        GlassLens(tilt: sensor.read(time: t)).position(c)
                    }
                    .modifier(warp) // so sánh: biến dạng cả glass lẫn nền
                }
            }
            .contentShape(.rect)
            .gesture(drag(in: geo.size))
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .bottom) {
            ControlPanel {
                Picker("Vị trí distortionEffect", selection: $placement) {
                    ForEach(Placement.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                Text("Liquid Glass hệ thống đã có highlight theo chuyển động máy. Highlight theo góc nghiêng ở đây là lớp shader tự viết (sheen + CoreMotion).")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                HStack {
                    Label(sensor.isAvailable ? "CoreMotion: cảm biến thật" : "Simulator: góc nghiêng giả lập",
                          systemImage: sensor.isAvailable ? "gyroscope" : "wand.and.rays")
                    Spacer()
                    Button("Lấy góc chuẩn") { sensor.recenter() }
                        .disabled(!sensor.isAvailable)
                }
                .font(.footnote)
            }
        }
        .onAppear { sensor.start() }
        .onDisappear { sensor.stop() }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: dragging)
    }

    private func drag(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                withAnimation(.interactiveSpring(duration: 0.25)) {
                    center = value.location
                    dragging = true
                }
            }
            .onEnded { value in
                // Thả tay: spring tới predictedEndLocation, nhận vận tốc của gesture
                withAnimation(.spring(duration: 0.8, bounce: 0.3)) {
                    center = value.predictedEndLocation.clamped(to: size, inset: 100)
                    dragging = false
                }
            }
    }
}

/// Tham số shader không tự animate. Đưa tâm và lực vào animatableData
/// để vùng biến dạng đi cùng spring của nút thay vì nhảy thẳng tới giá trị cuối.
private struct Warp: ViewModifier, Animatable {
    var center: CGPoint
    var strength: Double
    var time: Double

    var animatableData: AnimatablePair<CGPoint.AnimatableData, Double> {
        get { AnimatablePair(center.animatableData, strength) }
        set { center.animatableData = newValue.first; strength = newValue.second }
    }

    func body(content: Content) -> some View {
        content.distortionEffect(
            ShaderLibrary.fingerWarp(.float2(center), .float(170), .float(strength), .float(time)),
            maxSampleOffset: CGSize(width: 80, height: 80)
        )
    }
}

/// Vùng méo phủ glassEffect + highlight do shader `sheen` vẽ theo góc nghiêng.
private struct GlassLens: View {
    let tilt: CGPoint

    var body: some View {
        Circle()
            .fill(.clear)
            .frame(width: 170, height: 170)
            .glassEffect(.clear.interactive(), in: .circle)
            .overlay {
                Circle()
                    .fill(.white)
                    .colorEffect(ShaderLibrary.sheen(.boundingRect, .float2(tilt)))
                    .blendMode(.plusLighter)
                    .allowsHitTesting(false)
            }
    }
}

/// Đọc trọng lực theo kiểu "kéo" trong mỗi frame của TimelineView: không closure, không hàng đợi.
/// Simulator không có cảm biến nên trả về một chuyển động nghiêng giả lập.
final class TiltSensor {
    private let manager = CMMotionManager()
    private var baseline: CMAcceleration?

    var isAvailable: Bool { manager.isDeviceMotionAvailable }

    func start() {
        guard isAvailable, !manager.isDeviceMotionActive else { return }
        manager.deviceMotionUpdateInterval = 1 / 120
        manager.startDeviceMotionUpdates()
    }

    func stop() { manager.stopDeviceMotionUpdates() }
    func recenter() { baseline = nil }

    /// Độ nghiêng so với tư thế lúc bắt đầu, mỗi trục trong khoảng -1...1.
    func read(time: Double) -> CGPoint {
        guard let g = manager.deviceMotion?.gravity else {
            return CGPoint(x: sin(time * 0.9) * 0.8, y: cos(time * 0.6) * 0.6)
        }
        if baseline == nil { baseline = g }
        let b = baseline!
        return CGPoint(x: max(-1, min(1, (g.x - b.x) * 2.5)),
                       y: max(-1, min(1, (b.y - g.y) * 2.5)))
    }
}

#Preview { DistortionUnderGlassDemo() }
