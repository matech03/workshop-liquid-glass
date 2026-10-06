import SwiftUI

/// Level 3 · Spring presets: chọn spring nào cho tình huống nào. Chạm nút để chạy, đồ thị bên dưới là đường đi theo thời gian.
/// - `.smooth`: không nảy. Chuyển trạng thái thông thường.
/// - `.snappy`: nhanh, nảy rất nhẹ. Phản hồi chạm, bật / tắt.
/// - `.bouncy`: nảy rõ. Phần tử vui, mời chạm.
/// - Custom: `.spring(duration:bounce:)`. `duration` là thời gian cảm nhận, `bounce` 0 = không nảy, càng lớn càng nảy.
struct SpringPresetsDemo: View {
    enum Preset: String, CaseIterable { case smooth = "Smooth", snappy = "Snappy", bouncy = "Bouncy", custom = "Custom" }

    @State private var preset = Preset.bouncy
    @State private var duration = 0.5
    @State private var bounce = 0.3
    @State private var on = false

    private var spring: Spring {
        switch preset {
        case .smooth: .smooth
        case .snappy: .snappy
        case .bouncy: .bouncy
        case .custom: Spring(duration: duration, bounce: bounce)
        }
    }

    private var code: String {
        switch preset {
        case .smooth: "withAnimation(.smooth)"
        case .snappy: "withAnimation(.snappy)"
        case .bouncy: "withAnimation(.bouncy)"
        case .custom: "withAnimation(.spring(duration: \(duration.formatted(.number.precision(.fractionLength(2)))), bounce: \(bounce.formatted(.number.precision(.fractionLength(2))))))"
        }
    }

    var body: some View {
        VStack(spacing: 24) {
            GeometryReader { geo in
                let travel = geo.size.width - 96
                Image(systemName: "hand.tap.fill")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 64, height: 64)
                    .glassEffect(.regular.interactive(), in: .circle)
                    .position(x: 48 + (on ? travel : 0), y: geo.size.height / 2)
                    .onTapGesture { withAnimation(.spring(spring)) { on.toggle() } }
            }
            .frame(height: 90)
            SpringCurve(spring: spring)
                .frame(height: 160)
                .padding(.horizontal, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Backdrop() }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 0) {
                DemoCaption(caption)
                CodeHint(code: code)
            }
        }
        .safeAreaInset(edge: .bottom) {
            ControlPanel(spacing: 16, padding: 20) {
                Picker("Preset", selection: $preset) {
                    ForEach(Preset.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                if preset == .custom {
                    slider("duration", value: $duration, in: 0.2...1.5)
                    slider("bounce", value: $bounce, in: 0...0.8)
                }
            }
        }
        .animation(.smooth(duration: 0.25), value: preset)
    }

    private var caption: String {
        switch preset {
        case .smooth: "No bounce · state changes"
        case .snappy: "Quick, tiny bounce · taps, toggles"
        case .bouncy: "Visible bounce · playful elements"
        case .custom: "duration · bounce (0 = no overshoot)"
        }
    }

    private func slider(_ title: String, value: Binding<Double>, in range: ClosedRange<Double>) -> some View {
        HStack {
            Text(title).font(.callout.monospaced()).lineLimit(1).fixedSize()
            Slider(value: value, in: range)
            Text(value.wrappedValue.formatted(.number.precision(.fractionLength(2))))
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 40, alignment: .trailing)
        }
    }
}

/// Đường đi của spring từ 0 tới 1 theo thời gian, tính bằng `Spring.value(target:time:)`.
/// Vạch ngang là đích: phần vượt qua vạch là độ nảy.
private struct SpringCurve: View {
    let spring: Spring
    private let span = 1.6 // giây hiển thị

    var body: some View {
        Canvas { ctx, size in
            let scale = size.height * 0.7
            func y(_ v: Double) -> CGFloat { size.height - 8 - (scale * v) }
            var goal = Path()
            goal.move(to: CGPoint(x: 0, y: y(1)))
            goal.addLine(to: CGPoint(x: size.width, y: y(1)))
            ctx.stroke(goal, with: .color(.white.opacity(0.35)), style: .init(lineWidth: 1, dash: [5, 5]))
            var curve = Path()
            for step in 0...120 {
                let t = span * Double(step) / 120
                let v = spring.value(target: 1.0, time: t)
                let p = CGPoint(x: size.width * Double(step) / 120, y: y(v))
                if step == 0 { curve.move(to: p) } else { curve.addLine(to: p) }
            }
            ctx.stroke(curve, with: .color(Palette.accent), style: .init(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
        .background(.black.opacity(0.25), in: .rect(cornerRadius: 16))
        .overlay(alignment: .topLeading) {
            Text("position over \(span.formatted()) s")
                .font(.caption2.monospaced())
                .foregroundStyle(Palette.label)
                .padding(10)
        }
    }
}

#Preview { SpringPresetsDemo() }
