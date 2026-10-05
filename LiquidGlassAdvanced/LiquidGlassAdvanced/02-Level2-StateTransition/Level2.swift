import SwiftUI

/// Level 2 · Chuyển trạng thái. Mỗi tab một cặp GOOD / BAD.
/// 2a: ba kiểu morph làm đúng. 2b: hai lỗi hay gặp nhất.
struct Level2_Morph: View {
    enum Tab: String, CaseIterable { case blend = "Hòa nhau", addRemove = "Thêm / bớt", shape = "Đổi shape" }

    var body: some View {
        DemoTabs(Tab.addRemove) { tab in
            switch tab {
            case .blend:
                GoodBad(good: "GlassEffectContainer { a; b }", bad: "mỗi nút một container") {
                    BlendPair(shared: true)
                } badContent: {
                    BlendPair(shared: false)
                }
            case .addRemove:
                GoodBad(good: "glassEffectID + withAnimation", bad: "thiếu ID và withAnimation") {
                    MorphMenu()
                } badContent: {
                    MorphMenu(broken: true)
                }
            case .shape:
                GoodBad(good: "một view, đổi frame", bad: "if / else hai view") {
                    MorphingGlass(splitViews: false)
                } badContent: {
                    MorphingGlass(splitViews: true)
                }
            }
        }
    }
}

struct Level2_Pitfalls: View {
    enum Tab: String, CaseIterable { case container = "Khác container", animatable = "Thiếu animatableData" }

    var body: some View {
        DemoTabs(Tab.container) { tab in
            switch tab {
            case .container:
                // Lỗi hay gặp nhất: mỗi nút tự bọc container → không morph được với nút chính
                GoodBad(good: "một container cho cả nhóm", bad: "mỗi nút tự bọc container") {
                    ContainerMenu(perItem: false)
                } badContent: {
                    ContainerMenu(perItem: true)
                }
            case .animatable:
                // Shape tự viết thiếu animatableData: path nhảy thẳng tới giá trị cuối
                GoodBad(good: "var animatableData { progress }", bad: "thiếu animatableData") {
                    ArcProgress(animatable: true)
                } badContent: {
                    ArcProgress(animatable: false)
                }
            }
        }
    }
}

// MARK: - Hòa nhau

/// Hai nút tự động lại gần rồi tách ra. Chung container thì hòa vào nhau; hai container riêng thì không bao giờ hòa.
private struct BlendPair: View {
    let shared: Bool
    @State private var close = false

    var body: some View {
        Group {
            if shared {
                GlassEffectContainer(spacing: 40) { pair }
            } else {
                ZStack {
                    GlassEffectContainer { GlassCircle(size: 84, symbol: "circle.dotted") }
                    GlassEffectContainer { moving }
                }
            }
        }
        .onTapGesture { withAnimation(.smooth(duration: 1)) { close.toggle() } }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.4))
                withAnimation(.smooth(duration: 1.1)) { close.toggle() }
            }
        }
    }

    private var pair: some View {
        ZStack { GlassCircle(size: 84, symbol: "circle.dotted"); moving }
    }

    private var moving: some View {
        GlassCircle(size: 84, symbol: "hand.draw").offset(x: close ? 70 : 130)
    }
}

// MARK: - Khác container

private struct ContainerMenu: View {
    let perItem: Bool
    @State private var open = false
    @Namespace private var ns

    var body: some View {
        Group {
            if perItem { stack } else { GlassEffectContainer(spacing: 24) { stack } }
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.4))
                withAnimation(.bouncy) { open.toggle() }
            }
        }
    }

    private var stack: some View {
        HStack(spacing: 12) {
            item(open ? "xmark" : "plus", id: "toggle", size: 64)
                .onTapGesture { withAnimation(.bouncy) { open.toggle() } }
            if open {
                item("photo", id: "photo")
                item("doc", id: "file")
            }
        }
    }

    @ViewBuilder
    private func item(_ symbol: String, id: String, size: CGFloat = 52) -> some View {
        let shaped = Image(systemName: symbol).font(.title2.weight(.semibold))
            .frame(width: size, height: size)
            .glassEffect(.regular.interactive(), in: .circle)
            .glassEffectID(id, in: ns)
        if perItem { GlassEffectContainer { shaped } } else { shaped }
    }
}

// MARK: - Thiếu animatableData

private struct ArcProgress: View {
    let animatable: Bool
    @State private var on = false

    var body: some View {
        let progress = on ? 1.0 : 0.15
        Group {
            if animatable {
                ArcFixed(progress: progress).stroke(.white, style: .init(lineWidth: 16, lineCap: .round))
            } else {
                ArcBroken(progress: progress).stroke(.white, style: .init(lineWidth: 16, lineCap: .round))
            }
        }
        .frame(width: 130, height: 130)
        .onTapGesture { withAnimation(.bouncy(duration: 0.8)) { on.toggle() } }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.4))
                withAnimation(.bouncy(duration: 0.8)) { on.toggle() }
            }
        }
    }
}

nonisolated private struct ArcBroken: Shape {
    var progress: Double

    func path(in rect: CGRect) -> Path {
        Path { $0.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2,
                         startAngle: .degrees(-90), endAngle: .degrees(-90 + 360 * progress), clockwise: false) }
    }
}

nonisolated private struct ArcFixed: Shape {
    var progress: Double
    var animatableData: Double { // iOS 26+: có thể thay bằng macro @Animatable
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        ArcBroken(progress: progress).path(in: rect)
    }
}

#Preview { Level2_Morph() }
