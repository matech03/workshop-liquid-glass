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

/// Nhãn ở góc cho màn hình toàn cảnh (ẩn thanh điều hướng). Chạm để mở menu chuyển màn hình.
struct DemoTag: View {
    let demo: DemoID
    @Binding var path: [DemoID]

    var body: some View {
        Menu {
            if let next = demo.next {
                Button(next.title, systemImage: "chevron.down") { path = [next] }
            }
            if let previous = demo.previous {
                Button(previous.title, systemImage: "chevron.up") { path = [previous] }
            }
            Button("Danh sách", systemImage: "list.bullet") { path = [] }
        } label: {
            Text(demo.key)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .glassEffect(.clear, in: .capsule)
        }
        .opacity(0.6)
    }
}

/// Dòng hướng dẫn cố định ở đầu mỗi màn hình demo (xem `DemoID.hint`).
struct DemoHint: View {
    let text: String

    var body: some View {
        Label(text, systemImage: "hand.point.up.left.fill")
            .font(.subheadline.weight(.semibold))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.black.opacity(0.6), in: .capsule)
            .padding(.horizontal)
            .padding(.top, 4)
    }
}

/// Khung tối nhẹ cho bảng điều khiển đặt trên nền nhiều màu.
/// Chữ thường cho nhãn; tên API viết trong nhãn vẫn đọc được mà không bị xuống dòng như font mono.
struct ControlPanel<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) { content }
            .font(.callout)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.black.opacity(0.55), in: .rect(cornerRadius: 24))
            .padding(.horizontal)
    }
}
