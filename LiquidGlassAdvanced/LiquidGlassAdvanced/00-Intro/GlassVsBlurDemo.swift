import SwiftUI

/// Giới thiệu · Liquid Glass so với blur + tint, trên cùng một nền.
/// Liquid Glass khúc xạ nền, có highlight và tự đổi độ sáng theo nền; Material chỉ làm mờ và phủ màu.
/// Kéo thanh công cụ qua vùng sáng và vùng tối để thấy khác biệt.
struct GlassVsBlurDemo: View {
    var body: some View {
        Compare(top: .glass, topCode: ".glassEffect(.regular)", bottom: .blur, bottomCode: ".background(.ultraThinMaterial)") {
            ZStack { LightDarkBackdrop(); DraggableToolbar(usesGlass: true) }
        } bottomContent: {
            ZStack { LightDarkBackdrop(); DraggableToolbar(usesGlass: false) }
        }
    }
}

/// Nền so sánh: trái sáng, phải tối. Mỗi bên có chữ to và một dải màu chạy ngang đúng chỗ thanh công cụ nằm.
/// Glass bẻ cong nét chữ và dải màu ở mép thanh, giữa thanh vẫn đọc được; blur chỉ còn một mảng nhoè.
/// Hai nửa màn hình dùng cùng một nền tĩnh để chỉ còn khác nhau ở lớp glass / blur.
private struct LightDarkBackdrop: View {
    var body: some View {
        HStack(spacing: 0) {
            side(light: true)
            side(light: false)
        }
    }

    private func side(light: Bool) -> some View {
        let ink: Color = light ? Palette.navy : .white
        return ZStack {
            light ? Color(white: 0.94) : Palette.background
            VStack(spacing: 6) {
                Text("Aa").font(.system(size: 64, weight: .heavy, design: .rounded))
                Capsule()
                    .fill(LinearGradient(colors: [Palette.rose, Palette.peach, Palette.teal], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 14)
                    .padding(.horizontal, 18)
                Text("Glass").font(.system(size: 30, weight: .bold, design: .rounded))
            }
            .foregroundStyle(ink)
        }
    }
}

private extension PaneLabel {
    static let glass = PaneLabel(text: "Liquid Glass", color: Palette.accent)
    static let blur = PaneLabel(text: "Blur", color: Palette.neutral)
}

private struct DraggableToolbar: View {
    let usesGlass: Bool
    @State private var offset: CGSize?
    @State private var dragStart: CGSize?
    @State private var width: CGFloat = 0

    var body: some View {
        // Mặc định nằm giữa nửa sáng; kéo sang phải để so trên nền tối
        let current = offset ?? CGSize(width: -width / 4, height: 0)
        return toolbar
            .offset(current)
            .gesture(DragGesture()
                .onChanged { v in
                    let start = dragStart ?? current
                    dragStart = start
                    offset = CGSize(width: start.width + v.translation.width, height: start.height + v.translation.height)
                }
                .onEnded { _ in dragStart = nil })
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
    }

    @ViewBuilder private var toolbar: some View {
        // Đủ hẹp để nằm trọn trong một nửa nền (sáng hoặc tối)
        let icons = HStack(spacing: 20) {
            ForEach(["magnifyingglass", "heart", "square.and.arrow.up"], id: \.self) {
                Image(systemName: $0).font(.title3)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 56)

        if usesGlass {
            icons.glassEffect(.regular.interactive(), in: .capsule)
        } else {
            icons.background(.ultraThinMaterial, in: .capsule)
        }
    }
}

#Preview { GlassVsBlurDemo() }
