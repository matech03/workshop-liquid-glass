import SwiftUI

/// Giới thiệu · Liquid Glass so với blur + tint. Mỗi nửa: nội dung cuộn dưới một nhóm nút nổi ở góc dưới phải.
/// Nội dung xen kẽ khối nền sáng và nền tối, mỗi khối có chữ to và một dải màu. Cuộn để các khối đi qua dưới thanh:
/// - Khúc xạ: glass bẻ cong nét chữ và dải màu ở mép thanh, tự sáng / tối theo khối bên dưới; blur chỉ là một mảng nhoè xám.
/// - Scroll edge: `safeAreaBar` đăng ký thanh với ScrollView, nội dung mờ dần ở mép dưới;
///   blur kiểu cũ (`safeAreaInset`, tắt edge effect) cắt ngang, nội dung trôi thẳng vào dưới thanh.
struct GlassVsBlurDemo: View {
    var body: some View {
        Compare(top: .glass, topCode: ".glassEffect · .safeAreaBar", bottom: .blur, bottomCode: ".ultraThinMaterial · .safeAreaInset") {
            Feed(usesGlass: true)
        } bottomContent: {
            Feed(usesGlass: false)
        }
    }
}

private struct Feed: View {
    let usesGlass: Bool
    private let colors = [Palette.rose, Palette.peach, Palette.teal, Palette.violet]

    var body: some View {
        let feed = ScrollView {
            VStack(spacing: 10) {
                ForEach(0..<4, id: \.self) { i in
                    TextBlock(light: !i.isMultiple(of: 2)) // khối tối trước: khối sáng thứ hai nằm sẵn dưới nhóm nút
                    card(colors[i])
                    card(colors[(i + 2) % colors.count])
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 44) // chừa chỗ cho nhãn Liquid Glass / Blur ở góc trái
            .padding(.bottom, 14)
        }

        if usesGlass {
            feed
                .scrollEdgeEffectStyle(.soft, for: .bottom)
                .safeAreaBar(edge: .bottom) { bar }
        } else {
            feed
                .scrollEdgeEffectHidden(true, for: .bottom)
                .safeAreaInset(edge: .bottom) { bar }
        }
    }

    private func card(_ color: Color) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 10).fill(color).frame(width: 44, height: 44)
            VStack(alignment: .leading, spacing: 6) {
                Capsule().fill(.white.opacity(0.85)).frame(width: 140, height: 9)
                Capsule().fill(.white.opacity(0.4)).frame(width: 90, height: 7)
            }
            Spacer()
        }
        .padding(10)
        .background(color.opacity(0.25), in: .rect(cornerRadius: 16))
    }

    @ViewBuilder private var bar: some View {
        let icons = HStack(spacing: 20) {
            ForEach(["magnifyingglass", "heart", "square.and.arrow.up"], id: \.self) {
                Image(systemName: $0).font(.title3)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 50)

        Group {
            if usesGlass {
                icons.glassEffect(.regular.interactive(), in: .capsule)
            } else {
                icons.background(.ultraThinMaterial, in: .capsule)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.horizontal, 14)
        .padding(.top, 6)
        .padding(.bottom, 14)
    }
}

/// Khối chữ to và dải màu trên nền sáng hoặc tối: chi tiết để thấy khúc xạ, độ sáng để thấy glass đổi theo nền.
private struct TextBlock: View {
    let light: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text("Aa").font(.system(size: 52, weight: .heavy, design: .rounded))
            VStack(alignment: .leading, spacing: 8) {
                Capsule()
                    .fill(LinearGradient(colors: [Palette.rose, Palette.peach, Palette.teal], startPoint: .leading, endPoint: .trailing))
                    .frame(height: 12)
                Text("Glass").font(.system(size: 26, weight: .bold, design: .rounded))
            }
        }
        .foregroundStyle(light ? Palette.navy : .white)
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(light ? Color(white: 0.94) : Palette.background, in: .rect(cornerRadius: 16))
        .overlay { RoundedRectangle(cornerRadius: 16).strokeBorder(Palette.hairline) }
    }
}

private extension PaneLabel {
    static let glass = PaneLabel(text: "Liquid Glass", color: Palette.accent)
    static let blur = PaneLabel(text: "Blur", color: Palette.neutral)
}

#Preview { GlassVsBlurDemo() }
