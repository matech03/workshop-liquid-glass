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

extension EnvironmentValues {
    /// Hiện keyword / code trên demo. Bật bằng nút ⓘ trên thanh điều hướng (DemoContainer).
    @Entry var showsCode = false
}

/// Keyword / code ngắn ở đầu màn hình không chia đôi, để nhớ nhanh API của demo. Ẩn cho tới khi bật `showsCode`.
struct CodeHint: View {
    let code: String
    @Environment(\.showsCode) private var showsCode

    var body: some View {
        if showsCode { label.transition(.opacity.combined(with: .move(edge: .top))) }
    }

    private var label: some View {
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

/// Keyword ngắn nói mục đích demo: thao tác · điều cần thấy. Luôn hiện, khác CodeHint (chỉ hiện khi bật ⓘ).
struct DemoCaption: View {
    let text: String

    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.white.opacity(0.85))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.black.opacity(0.35), in: .rect(cornerRadius: 14))
            .padding(.horizontal, 16)
            .padding(.top, 4)
    }
}

/// Bảng điều khiển ở cạnh dưới: nền tối mờ, viền mảnh, không phải glass để không chồng lên control glass bên trong.
struct ControlPanel<Content: View>: View {
    var spacing: CGFloat = 12
    var padding: CGFloat = 16
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: spacing) { content }
            .font(.callout)
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.black.opacity(0.35), in: .rect(cornerRadius: 24))
            .overlay { RoundedRectangle(cornerRadius: 24).strokeBorder(Palette.hairline) }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
    }
}

/// Một dòng trong bảng điều khiển: tên bên trái, menu hệ thống chọn giá trị bên phải.
struct MenuRow<Value: Hashable & CaseIterable & RawRepresentable>: View where Value.RawValue == String, Value.AllCases: RandomAccessCollection {
    let title: String
    @Binding var selection: Value

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker(title, selection: $selection) {
                ForEach(Array(Value.allCases), id: \.self) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.menu)
            .labelsHidden()
        }
    }
}
