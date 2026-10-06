import SwiftUI

/// Level 1 · Interactive glass. Ba nút cạnh nhau, mỗi nút một kiểu glass; bảng điều khiển áp dụng cho cả ba:
/// - Kiểu glass: `.regular` (mặc định, tự thích ứng), `.clear` (trong hơn, cần nền đủ tối), `.tint(_:)` (nhuộm màu, cho nút chính).
/// - Highlight: `.interactive()` làm glass sáng lên và co giãn khi nhấn.
/// - Haptic: `sensoryFeedback` rung khi `trigger` đổi giá trị; `taps` tăng mỗi lần chạm nên lần nào cũng rung.
/// - Shape: hình của glass. Highlight và co giãn bám theo đúng hình.
/// - Icon effect: lớp phản hồi trên icon: nảy, đổi icon, đổi màu.
/// - Union: ba nút gộp thành một khối glass dù đứng cách nhau (`glassEffectUnion`).
///   Union chỉ gộp glass cùng id, cùng kiểu glass, cùng shape, trong chung `GlassEffectContainer`:
///   nên khi bật, cả ba chuyển về `.regular`.
///   Shape được vẽ lên khung bao chung của cả nhóm: Circle trong khung dài chỉ còn một hình tròn ở giữa,
///   nên khi bật Union, Circle đổi sang Capsule (nút vuông thì Capsule trông như hình tròn).
/// Nền nhiều màu để thấy rõ khác biệt giữa các kiểu glass.
struct TouchFeedbackDemo: View {
    @State private var highlight = true
    @State private var haptic = true
    @State private var shape = GlassShape.circle
    @State private var effect = IconEffect.bounce
    @State private var union = false
    @Namespace private var ns

    var body: some View {
        GlassEffectContainer(spacing: 0) { // spacing 0: không tự hòa, chỉ gộp khi bật Union
            HStack(spacing: 24) {
                button(glass: .regular)
                button(glass: .clear)
                button(glass: .regular.tint(Palette.accent))
            }
        }
        .animation(.bouncy, value: shape)
        .animation(.bouncy, value: union)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background { Backdrop(style: .vivid) }
        .safeAreaInset(edge: .top) {
            VStack(spacing: 0) {
                CodeHint(code: union ? ".regular" : ".regular · .clear · .regular.tint(.accent)")
                CodeHint(code: ".glassEffect(glass\(highlight ? ".interactive()" : ""), in: \(shape.code))")
                if union { CodeHint(code: ".glassEffectUnion(id: \"row\", namespace: ns)") }
                if let code = effect.code { CodeHint(code: code) }
                if haptic { CodeHint(code: ".sensoryFeedback(.impact, trigger: taps)") }
            }
        }
        .safeAreaInset(edge: .bottom) {
            ControlPanel(spacing: 20, padding: 20) {
                Toggle("Highlight", isOn: $highlight)
                Toggle("Haptic", isOn: $haptic)
                MenuRow(title: "Shape", selection: $shape)
                MenuRow(title: "Icon effect", selection: $effect)
                Toggle("Union", isOn: $union)
            }
        }
    }

    private func button(glass: Glass) -> some View {
        // Union: cùng một kiểu glass (.regular) và Circle → Capsule, để khối gộp là một capsule dài
        let glassShape = union && shape == .circle ? AnyShape(Capsule()) : shape.shape
        return FeedbackButton(symbol: "heart.fill", glass: union ? .regular : glass, highlight: highlight, haptic: haptic,
                              size: shape.size, glassShape: glassShape, effect: effect,
                              unionID: union ? "row" : nil, ns: ns)
    }
}

enum GlassShape: String, CaseIterable {
    case circle = "Circle", capsule = "Capsule", rounded = "Rounded rect"

    var size: CGSize {
        switch self {
        case .circle, .rounded: CGSize(width: 72, height: 72)
        case .capsule: CGSize(width: 96, height: 56)
        }
    }

    var shape: AnyShape {
        switch self {
        case .circle: AnyShape(Circle())
        case .capsule: AnyShape(Capsule())
        case .rounded: AnyShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    var code: String {
        switch self {
        case .circle: ".circle"
        case .capsule: ".capsule"
        case .rounded: ".rect(cornerRadius: 20)"
        }
    }
}

enum IconEffect: String, CaseIterable {
    case none = "None", bounce = "Bounce", replace = "Replace", color = "Color"

    var code: String? {
        switch self {
        case .none: nil
        case .bounce: ".symbolEffect(.bounce, value: taps)"
        case .replace: "Image(liked ? \"star.fill\" : \"heart.fill\").contentTransition(.symbolEffect(.replace))"
        case .color: ".foregroundStyle(liked ? .like : .white)"
        }
    }
}

/// Một nút glass, giữ số lần chạm riêng: chạm nút này chỉ nút này nảy, đổi icon, đổi màu.
private struct FeedbackButton: View {
    let symbol: String
    let glass: Glass
    let highlight: Bool
    let haptic: Bool
    let size: CGSize
    let glassShape: AnyShape
    let effect: IconEffect
    let unionID: String?
    let ns: Namespace.ID
    @State private var taps = 0

    private var liked: Bool { !taps.isMultiple(of: 2) } // đổi mỗi lần chạm, cho Replace và Color

    var body: some View {
        icon
            .font(.system(size: 30))
            .frame(width: size.width, height: size.height)
            .glassEffect(glass.interactive(highlight), in: glassShape)
            .glassEffectUnion(id: unionID, namespace: ns)
            .contentShape(glassShape)
            .onTapGesture { withAnimation(.smooth(duration: 0.25)) { taps += 1 } } // Replace và Color cần animation
            .sensoryFeedback(.impact(weight: .medium), trigger: taps) { _, _ in haptic }
    }

    @ViewBuilder private var icon: some View {
        switch effect {
        case .none:
            Image(systemName: symbol).foregroundStyle(.white)
        case .bounce:
            Image(systemName: symbol).foregroundStyle(.white)
                .symbolEffect(.bounce, value: taps)
        case .replace:
            // Đổi hẳn sang icon khác (tim ↔ sao) để thấy rõ icon cũ biến mất, icon mới hiện ra
            Image(systemName: liked ? "star.fill" : symbol).foregroundStyle(.white)
                .contentTransition(.symbolEffect(.replace))
        case .color:
            Image(systemName: symbol).foregroundStyle(liked ? Palette.like : .white)
        }
    }
}

#Preview { TouchFeedbackDemo() }
