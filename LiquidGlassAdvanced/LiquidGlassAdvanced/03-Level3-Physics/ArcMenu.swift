import SwiftUI

// Level 3 · Menu cung tròn: Layout conform Animatable: đưa `progress` vào animatableData,
// SwiftUI nội suy progress theo từng frame và gọi lại placeSubviews → các nút di chuyển theo cung tròn, không theo đường thẳng.

struct ArcLayout: Layout {
    var progress: Double // 0 = gom ở tâm, 1 = bung hết
    var radius: CGFloat = 120
    var spread: Angle = .degrees(150)

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        proposal.replacingUnspecifiedDimensions()
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let center = CGPoint(x: bounds.midX, y: bounds.maxY - 60)
        let step = spread.radians / Double(max(subviews.count - 1, 1))
        for (i, view) in subviews.enumerated() {
            // Góc và bán kính cùng tăng theo progress: vị trí nằm trên cung tròn ở mọi frame
            let angle = -.pi / 2 - spread.radians / 2 + step * Double(i) * progress
            let r = radius * progress
            view.place(at: CGPoint(x: center.x + r * cos(angle), y: center.y + r * sin(angle)),
                       anchor: .center, proposal: .unspecified)
        }
    }
}

struct ArcMenuDemo: View {
    enum Style: String, CaseIterable, Identifiable {
        case layout = "Layout + spring", keyframes = "KeyframeAnimator"
        var id: Self { self }
    }

    @State private var open = false
    @State private var style = Style.layout
    private let icons = ["camera", "photo", "mic", "doc", "location"]

    var body: some View {
        ZStack {
            Backdrop()
            ZStack(alignment: .bottom) {
                switch style {
                case .layout: springArc
                case .keyframes: keyframeArc
                }
                GlassCircle(size: 76, symbol: open ? "xmark" : "plus")
                    .contentTransition(.symbolEffect(.replace))
                    .padding(.bottom, 22)
                    .onTapGesture(perform: toggle)
            }
            .frame(height: 300)
        }
        .safeAreaInset(edge: .bottom) {
            Picker("Kiểu", selection: $style) {
                ForEach(Style.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .sensoryFeedback(.selection, trigger: open)
        .autoplay(every: 1.4, toggle)
    }

    /// Spring: bấm khi đang chạy thì progress đổi đích và giữ vận tốc hiện tại.
    private var springArc: some View {
        ArcLayout(progress: open ? 1 : 0) {
            ForEach(icons, id: \.self) { icon in
                GlassCircle(size: 54, symbol: icon)
                    .opacity(open ? 1 : 0)
            }
        }
    }

    /// KeyframeAnimator: overshoot được định nghĩa sẵn trên timeline cố định.
    /// Không nhận vận tốc hiện tại: bấm khi đang chạy thì timeline mới bắt đầu từ giá trị hiện tại.
    private var keyframeArc: some View {
        KeyframeAnimator(initialValue: 0.0, trigger: open) { p in
            ArcLayout(progress: p) {
                ForEach(icons, id: \.self) { icon in
                    GlassCircle(size: 54, symbol: icon)
                }
            }
            .opacity(min(max(p, 0) * 3, 1))
        } keyframes: { _ in
            if open {
                CubicKeyframe(1.18, duration: 0.25) // overshoot
                SpringKeyframe(0.94, duration: 0.15)
                SpringKeyframe(1.0, duration: 0.2)
            } else {
                CubicKeyframe(1.1, duration: 0.1)   // anticipation
                CubicKeyframe(0, duration: 0.25)
            }
        }
    }

    private func toggle() {
        withAnimation(.spring(duration: 0.5, bounce: 0.3)) { open.toggle() }
    }
}

#Preview { ArcMenuDemo() }
