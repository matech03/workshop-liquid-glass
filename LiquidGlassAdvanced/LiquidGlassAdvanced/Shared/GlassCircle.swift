import SwiftUI

/// Nút: phần tử glass hình tròn dùng xuyên suốt các demo.
struct GlassCircle: View {
    var size: CGFloat = 72
    var symbol = "sparkles"
    var glass: Glass = .regular.interactive()

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.34, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .glassEffect(glass, in: .circle)
    }
}

/// Keyword / code ngắn ở đầu màn hình không chia đôi, để nhớ nhanh API của demo.
struct CodeHint: View {
    let code: String

    var body: some View {
        Text(code)
            .font(.caption.monospaced())
            .foregroundStyle(.white.opacity(0.9))
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.black.opacity(0.35), in: .capsule)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
    }
}

/// Bảng điều khiển ở cạnh dưới: nền tối mờ, viền mảnh, không phải glass để không chồng lên control glass bên trong.
struct ControlPanel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .font(.callout)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.black.opacity(0.35), in: .rect(cornerRadius: 24))
            .overlay { RoundedRectangle(cornerRadius: 24).strokeBorder(Palette.hairline) }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }
}
