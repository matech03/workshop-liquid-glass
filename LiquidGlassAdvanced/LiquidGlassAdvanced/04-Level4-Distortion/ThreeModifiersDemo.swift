import SwiftUI

/// Level 4 · Ba shader modifier trên cùng một ảnh mẫu. Ảnh GỐC ở trên để so.
/// - colorEffect: chỉ đổi MÀU từng pixel, hình dạng giữ nguyên (lưới vẫn thẳng).
/// - distortionEffect: chỉ đổi VỊ TRÍ lấy mẫu, màu giữ nguyên (lưới lượn sóng).
/// - layerEffect: đọc NHIỀU điểm của layer rồi trộn (tách kênh màu ở mép chữ).
/// Bật ⓘ: mỗi hàng hiện dòng gọi modifier và signature của hàm Metal tương ứng.
struct ThreeModifiersDemo: View {
    @State private var strength = 1.0 // 0 = tắt cả ba, 1 = mạnh nhất

    var body: some View {
        VStack(spacing: 12) {
            Row(title: "Original", code: nil) {
                ShaderSample()
            }
            Row(title: "colorEffect", code: ".colorEffect(ShaderLibrary.duotone(…))\nhalf4 f(float2 position, half4 color, …)") {
                // Trộn ảnh gốc với bản duotone theo cường độ, để slider cũng điều khiển được colorEffect
                ShaderSample().overlay {
                    ShaderSample().colorEffect(ShaderLibrary.duotone(.color(Palette.navy), .color(Palette.sand))).opacity(strength)
                }
            }
            Row(title: "distortionEffect", code: ".distortionEffect(ShaderLibrary.wave(…), maxSampleOffset:)\nfloat2 f(float2 position, …)") {
                ShaderSample().distortionEffect(ShaderLibrary.wave(.float(14 * strength)),
                                          maxSampleOffset: CGSize(width: 14, height: 0))
            }
            Row(title: "layerEffect", code: ".layerEffect(ShaderLibrary.chromatic(…), maxSampleOffset:)\nhalf4 f(float2 position, SwiftUI::Layer layer, …)") {
                ShaderSample().layerEffect(ShaderLibrary.chromatic(.float(8 * strength)),
                                     maxSampleOffset: CGSize(width: 8, height: 0))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .background { Backdrop() }
        .safeAreaInset(edge: .bottom) {
            ControlPanel {
                Slider(value: $strength, in: 0...1) {
                    Text("Intensity")
                } minimumValueLabel: {
                    Image(systemName: "circle")
                } maximumValueLabel: {
                    Image(systemName: "circle.fill")
                }
            }
        }
    }
}

private struct Row<Content: View>: View {
    let title: String
    let code: String?
    @ViewBuilder var content: Content
    @Environment(\.showsCode) private var showsCode

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(.rect(cornerRadius: 20))
            .overlay { RoundedRectangle(cornerRadius: 20).strokeBorder(Palette.hairline) }
            .overlay(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title).font(.caption.monospaced().weight(.medium))
                    if showsCode, let code {
                        Text(code)
                            .font(.caption2.monospaced())
                            .lineLimit(2)
                            .minimumScaleFactor(0.7)
                            .transition(.opacity)
                    }
                }
                .foregroundStyle(Palette.label)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.black.opacity(0.45), in: .rect(cornerRadius: 10))
                .padding(10)
            }
    }
}

/// Ảnh mẫu tĩnh: dải màu, lưới thẳng và chữ có cạnh sắc. Tĩnh để chỉ thấy tác dụng của shader.
/// Dùng chung cho 3 modifier (Level 4) và Shader effects (Ví dụ).
struct ShaderSample: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Palette.rose, Palette.peach, Palette.teal, Palette.slate], startPoint: .leading, endPoint: .trailing)
            Canvas { context, size in
                var grid = Path()
                for x in stride(from: 0, through: size.width, by: 22) { grid.move(to: CGPoint(x: x, y: 0)); grid.addLine(to: CGPoint(x: x, y: size.height)) }
                for y in stride(from: 0, through: size.height, by: 22) { grid.move(to: CGPoint(x: 0, y: y)); grid.addLine(to: CGPoint(x: size.width, y: y)) }
                context.stroke(grid, with: .color(.white.opacity(0.4)), lineWidth: 1)
            }
            Text("GLASS").font(.system(size: 44, weight: .black, design: .rounded)).foregroundStyle(.white)
        }
    }
}

#Preview { ThreeModifiersDemo() }
