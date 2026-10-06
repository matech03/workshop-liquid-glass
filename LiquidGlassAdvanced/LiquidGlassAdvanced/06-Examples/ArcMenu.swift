import SwiftUI

// Ví dụ · Thông dụng: menu cung tròn (kỹ thuật Level 3), hai style cùng vị trí cuối, khác đường đi.
// Quạt: Layout conform Animatable, đưa `progress` vào animatableData. SwiftUI nội suy progress theo từng frame
// và gọi lại placeSubviews → các nút quét theo cung tròn.
// Toả thẳng: đổi `offset` → SwiftUI nội suy x/y tuyến tính, nút bắn thẳng ra từ tâm; trễ lần lượt từng nút.

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
        let center = CGPoint(x: bounds.midX, y: bounds.maxY - 50)
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
    var body: some View {
        Compare(top: .fan, topCode: "Layout + animatableData", bottom: .burst, bottomCode: ".offset + delay") {
            ArcMenu(usesLayout: true)
        } bottomContent: {
            ArcMenu(usesLayout: false)
        }
    }
}

private extension PaneLabel {
    static let fan = PaneLabel(text: "Fan", color: Palette.accent)
    static let burst = PaneLabel(text: "Burst", color: Palette.warm)
}

private struct ArcMenu: View {
    let usesLayout: Bool
    @State private var open = false
    private let icons = ["camera", "photo", "mic", "doc", "location"]
    private let layout = ArcLayout(progress: 1, radius: 95)

    var body: some View {
        ZStack(alignment: .bottom) {
            if usesLayout {
                ArcLayout(progress: open ? 1 : 0, radius: 95) { items }
            } else {
                // Cùng vị trí cuối như ArcLayout, animate bằng offset: đường thẳng từ tâm, nút sau trễ hơn nút trước
                GeometryReader { geo in
                    ZStack {
                        ForEach(Array(icons.enumerated()), id: \.offset) { i, icon in
                            GlassCircle(size: 44, symbol: icon)
                                .opacity(open ? 1 : 0)
                                .position(x: geo.size.width / 2, y: geo.size.height - 50)
                                .offset(open ? layout.offset(for: i, of: icons.count) : .zero)
                                .animation(.spring(duration: 0.5, bounce: 0.35).delay(Double(open ? i : icons.count - 1 - i) * 0.04), value: open)
                        }
                    }
                }
            }
            GlassCircle(size: 60, symbol: open ? "xmark" : "plus")
                .contentTransition(.symbolEffect(.replace))
                .padding(.bottom, 20)
                .onTapGesture(perform: toggle)
        }
        .sensoryFeedback(.selection, trigger: open)
    }

    private var items: some View {
        ForEach(icons, id: \.self) { icon in
            GlassCircle(size: 44, symbol: icon).opacity(open ? 1 : 0)
        }
    }

    private func toggle() {
        withAnimation(.spring(duration: 0.6, bounce: 0.2)) { open.toggle() }
    }
}

extension ArcLayout {
    /// Độ lệch của nút thứ i so với tâm khi bung hết, dùng cho style toả thẳng.
    func offset(for i: Int, of count: Int) -> CGSize {
        let step = spread.radians / Double(max(count - 1, 1))
        let angle = -.pi / 2 - spread.radians / 2 + step * Double(i)
        return CGSize(width: radius * cos(angle), height: radius * sin(angle))
    }
}

#Preview { ArcMenuDemo() }
