import SwiftUI

/// Level 2 · Chuyển trạng thái. Mỗi demo một cặp GOOD / BAD, chọn bằng menu trên tiêu đề.
/// Ba demo đầu: ba kiểu morph làm đúng. Hai demo cuối: hai lỗi hay gặp nhất.
struct Level2_Morph: View {
    enum Tab: String, CaseIterable {
        case blend = "Blend", addRemove = "Add / remove", shape = "Change shape"
        case unstableID = "Unstable ID", animatable = "Missing animatableData"
    }

    var body: some View {
        DemoTabs(Tab.addRemove) { tab in
            switch tab {
            case .blend:
                BlendDemo()
            case .addRemove:
                GoodBad(good: "glassEffectID + withAnimation", bad: "no ID, no withAnimation") {
                    MorphMenu()
                } badContent: {
                    MorphMenu(broken: true)
                }
            case .shape:
                GoodBad(good: "one view, change frame", bad: "if / else, two views") {
                    MorphingGlass(splitViews: false)
                } badContent: {
                    MorphingGlass(splitViews: true)
                }
            case .unstableID:
                // ID theo vị trí: xoá phần tử giữa danh sách thì glass morph sai phần tử
                GoodBad(good: "glassEffectID(tag, in: ns)", bad: "glassEffectID(index, in: ns)") {
                    TagRow(stableID: true)
                } badContent: {
                    TagRow(stableID: false)
                }
            case .animatable:
                // Shape tự viết thiếu animatableData: path nhảy thẳng tới giá trị cuối
                GoodBad(good: "var animatableData { progress }", bad: "missing animatableData") {
                    ArcProgress(animatable: true)
                } badContent: {
                    ArcProgress(animatable: false)
                }
            }
        }
    }
}

// MARK: - Hòa nhau

/// Slider chỉnh `spacing` cho cả hai nửa. GOOD: mép hai nút cách nhau nhỏ hơn `spacing` là bắt đầu hòa
/// (lúc đầu mép cách 46 pt: kéo `spacing` qua 46 là hòa dù không chạm).
/// BAD: hai container riêng, `spacing` lớn đến đâu cũng không hòa.
private struct BlendDemo: View {
    @State private var spacing = 40.0

    var body: some View {
        GoodBad(good: "GlassEffectContainer(spacing: \(Int(spacing))) { a; b }", bad: "one container per button") {
            BlendPair(shared: true, spacing: spacing)
        } badContent: {
            BlendPair(shared: false, spacing: spacing)
        }
        .safeAreaInset(edge: .bottom) {
            ControlPanel {
                HStack {
                    Text("spacing").font(.callout.monospaced())
                    Spacer()
                    Text("\(Int(spacing)) pt").font(.callout.monospacedDigit()).foregroundStyle(.secondary)
                }
                // Không dùng `step`: iOS 26 vẽ vạch chia cho từng bước
                Slider(value: $spacing, in: 0...100) { Text("spacing") }
            }
        }
    }
}

/// Một nút cố định, nút còn lại kéo tự do trong nửa màn hình.
/// Chung container thì hòa vào nhau; hai container riêng thì không bao giờ hòa.
private struct BlendPair: View {
    let shared: Bool
    let spacing: CGFloat
    @State private var offset = CGSize(width: 130, height: 0) // so với nút cố định: mép cách 130 - 84 = 46 pt
    @State private var dragStart: CGSize?
    @State private var size = CGSize.zero

    private let diameter: CGFloat = 84
    private let fixedX: CGFloat = -65 // hai nút đối xứng quanh tâm lúc đầu

    var body: some View {
        Group {
            if shared {
                GlassEffectContainer(spacing: spacing) { ZStack { fixed; moving } }
            } else {
                ZStack {
                    GlassEffectContainer(spacing: spacing) { fixed }
                    GlassEffectContainer(spacing: spacing) { moving }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
    }

    private var fixed: some View {
        GlassCircle(size: diameter, symbol: "circle.dotted").offset(x: fixedX)
    }

    private var moving: some View {
        GlassCircle(size: diameter, symbol: "hand.draw")
            .offset(x: fixedX + offset.width, y: offset.height)
            .gesture(DragGesture()
                .onChanged { v in
                    let start = dragStart ?? offset
                    dragStart = start
                    offset = clamped(CGSize(width: start.width + v.translation.width,
                                            height: start.height + v.translation.height))
                }
                .onEnded { _ in dragStart = nil })
    }

    /// Giữ nút kéo nằm trọn trong nửa màn hình.
    private func clamped(_ o: CGSize) -> CGSize {
        let maxX = size.width / 2 - diameter / 2, maxY = size.height / 2 - diameter / 2
        return CGSize(width: min(max(o.width, -maxX - fixedX), maxX - fixedX),
                      height: min(max(o.height, -maxY), maxY))
    }
}

// MARK: - ID không ổn định

/// Chạm một tag để xoá. GOOD: `glassEffectID` theo dữ liệu (tên tag) nên đúng tag đó tan vào hàng.
/// BAD: ID theo vị trí (index). Xoá tag giữa hàng thì các ID dồn lên: glass của tag cuối biến mất,
/// glass ở chỗ tag bị xoá đứng yên đổi kích thước, còn chữ của các tag sau trượt sang, lệch khỏi glass.
private struct TagRow: View {
    let stableID: Bool
    @State private var tags = Self.all
    @Namespace private var ns

    private static let all = ["Swift", "Glass", "Morph", "Metal"]

    var body: some View {
        VStack(spacing: 20) {
            GlassEffectContainer(spacing: 6) {
                HStack(spacing: 10) { // lớn hơn spacing của container: các tag không dính vào nhau
                    ForEach(Array(tags.enumerated()), id: \.element) { index, tag in
                        Text(tag)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .glassEffect(.regular.interactive(), in: .capsule)
                            .glassEffectID(stableID ? tag : "\(index)", in: ns)
                            .onTapGesture { withAnimation(.bouncy) { tags.removeAll { $0 == tag } } }
                    }
                }
            }
            .frame(height: 44)
            Button("Reset", systemImage: "arrow.counterclockwise") {
                withAnimation(.bouncy) { tags = Self.all }
            }
            .buttonStyle(.glass)
            .disabled(tags == Self.all)
        }
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
