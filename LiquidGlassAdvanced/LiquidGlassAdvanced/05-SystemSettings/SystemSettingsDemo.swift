import SwiftUI

/// Cấu hình hệ thống · Glass hệ thống tự thích ứng với cài đặt người dùng: Giảm độ trong suốt, Tăng độ tương phản, sáng / tối.
/// Shader và animation tự viết thì không: app phải tự đọc @Environment và tự tắt/giảm.
/// App ép .dark ở gốc, nên Picker phía dưới đổi colorScheme cho riêng phần demo để so sáng với tối.
struct SystemSettingsDemo: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var open = false
    @State private var scheme = ColorScheme.dark

    var body: some View {
        ZStack {
            Backdrop(style: .vivid) // cần nhiều màu: thấy glass đục hơn khi Giảm độ trong suốt
            VStack(spacing: 28) {
                SettingsCard()
                Image(systemName: open ? "xmark" : "plus")
                    .font(.title3.weight(.semibold))
                    .frame(width: open ? 240 : 64, height: open ? 120 : 64)
                    .adaptiveGlass(in: .rect(cornerRadius: open ? 30 : 32))
                    .onTapGesture {
                        // Reduce Motion: bỏ spring có bounce, dùng easeInOut ngắn. Vẫn giữ phản hồi, chỉ giảm chuyển động.
                        withAnimation(reduceMotion ? .easeInOut(duration: 0.2) : .bouncy) { open.toggle() }
                    }
            }
        }
        .environment(\.colorScheme, scheme)
        .safeAreaInset(edge: .top) { CodeHint(code: "@Environment(\\.accessibilityReduceTransparency)") }
        .safeAreaInset(edge: .bottom) {
            ControlPanel {
                Picker("Appearance", selection: $scheme) {
                    Image(systemName: "moon.fill").tag(ColorScheme.dark)
                    Image(systemName: "sun.max.fill").tag(ColorScheme.light)
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

/// Đọc cài đặt từ @Environment. Nằm bên trong vùng đã đổi colorScheme nên thấy đúng giá trị của Picker.
private struct SettingsCard: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            row("Reduce Transparency", path: "Accessibility › Display & Text Size", on: reduceTransparency)
            row("Increase Contrast", path: "Accessibility › Display & Text Size", on: contrast == .increased)
            row("Reduce Motion", path: "Accessibility › Motion", on: reduceMotion)
            // iOS 26.1+: không có API để đọc lựa chọn này, nên không có dấu tích; đổi trong Cài đặt rồi xem lại glass.
            row("Liquid Glass", path: "Display & Brightness › Clear / Tinted", on: nil)
        }
        .padding(20)
        .adaptiveGlass(in: .rect(cornerRadius: 28))
    }

    /// `on == nil`: cài đặt app không đọc được.
    private func row(_ title: String, path: String, on: Bool?) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.callout)
                Text("Settings › \(path)").font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            Image(systemName: on == true ? "checkmark.circle.fill" : on == false ? "circle" : "minus.circle")
                .foregroundStyle(on == true ? Palette.good : .secondary)
        }
        .frame(width: 300)
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
            // Màu hệ thống: tự đổi theo sáng / tối.
            content.background(.background.secondary, in: shape)
                .overlay(shape.stroke(.primary.opacity(contrast == .increased ? 0.9 : 0.25), lineWidth: 1))
        } else {
            content
                .glassEffect(.regular.interactive(), in: shape)
                .overlay(shape.stroke(.primary.opacity(contrast == .increased ? 0.8 : 0), lineWidth: 1.5))
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

#Preview { SystemSettingsDemo() }
