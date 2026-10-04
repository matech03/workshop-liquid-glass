import SwiftUI

/// Lưu ý · Trợ năng: glass hệ thống tự thích ứng, shader tự viết phải tự xử lý.
/// Glass hệ thống tự thích ứng với Reduce Transparency / Increase Contrast.
/// Shader và animation tự viết thì app phải tự đọc @Environment và tự tắt/giảm.
struct AccessibilityDemo: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var open = false

    var body: some View {
        ZStack {
            Backdrop()
                .rippleOnTap() // RippleOnTap đọc accessibilityReduceMotion và tắt layerEffect
            VStack(spacing: 28) {
                VStack(alignment: .leading, spacing: 10) {
                    flag("accessibilityReduceTransparency", "Trợ năng › Màn hình & cỡ chữ › Giảm độ trong suốt", reduceTransparency)
                    flag("colorSchemeContrast == .increased", "Trợ năng › Màn hình & cỡ chữ › Tăng độ tương phản", contrast == .increased)
                    flag("accessibilityReduceMotion", "Trợ năng › Chuyển động › Giảm chuyển động", reduceMotion)
                }
                .padding(20)
                .adaptiveGlass(in: .rect(cornerRadius: 28))

                Text(open ? "Đã mở" : "Chạm để mở")
                    .font(.headline)
                    .frame(width: open ? 240 : 150, height: open ? 120 : 56)
                    .adaptiveGlass(in: .rect(cornerRadius: open ? 30 : 28))
                    .onTapGesture {
                        // Reduce Motion: bỏ spring có bounce, dùng easeInOut ngắn. Vẫn giữ phản hồi, chỉ giảm chuyển động.
                        withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .bouncy) { open.toggle() }
                    }
            }
        }
    }

    private func flag(_ key: String, _ path: String, _ on: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: on ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(on ? .green : .secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(key).font(.caption.monospaced().weight(.semibold))
                Text(path).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            Text(on ? "true" : "false").font(.caption.monospaced().weight(.bold)).foregroundStyle(on ? .green : .secondary)
        }
        .frame(width: 320)
    }
}

/// Một ViewModifier duy nhất quyết định glass hiển thị thế nào khi bật tùy chọn trợ năng.
struct AdaptiveGlass<S: Shape>: ViewModifier {
    let shape: S
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast

    func body(content: Content) -> some View {
        if reduceTransparency {
            // Hệ thống đã tự tăng độ đục của glass; ở đây thay hẳn bằng nền đặc để đảm bảo độ tương phản chữ.
            content.background(Color(white: 0.12), in: shape)
                .overlay(shape.stroke(.white.opacity(contrast == .increased ? 0.9 : 0.25), lineWidth: 1))
        } else {
            content
                .glassEffect(.regular.interactive(), in: shape)
                .overlay(shape.stroke(.white.opacity(contrast == .increased ? 0.8 : 0), lineWidth: 1.5))
        }
    }
}

extension View {
    func adaptiveGlass(in shape: some Shape) -> some View {
        modifier(AdaptiveGlass(shape: shape))
    }
}

/* App hỗ trợ iOS < 26: đóng gói nhánh #available vào MỘT ViewModifier,
   không rải `if #available` khắp nơi. (Target của project này là iOS 26 nên đoạn này chỉ để tham khảo.)

struct GlassOrMaterial<S: Shape>: ViewModifier {
    let shape: S

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content.glassEffect(.regular.interactive(), in: shape)
        } else {
            content.background(.ultraThinMaterial, in: shape)
        }
    }
}

   UIDesignRequiresCompatibility = YES (Info.plist): giữ giao diện trước Liquid Glass khi build bằng SDK 26.
   Apple thông báo key này chỉ là tạm thời và sẽ bị bỏ ở bản lớn tiếp theo. Kiểm tra lại trên SDK đang dùng trước khi dựa vào nó.
*/

#Preview { AccessibilityDemo() }
