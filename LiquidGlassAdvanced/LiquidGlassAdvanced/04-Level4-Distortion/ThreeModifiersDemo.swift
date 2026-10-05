import SwiftUI

/// Level 4 · Ba shader modifier trên cùng một ảnh mẫu. Ảnh GỐC ở trên để so.
/// - colorEffect: chỉ đổi MÀU từng pixel, hình dạng giữ nguyên (lưới vẫn thẳng).
/// - distortionEffect: chỉ đổi VỊ TRÍ lấy mẫu, màu giữ nguyên (lưới lượn sóng).
/// - layerEffect: đọc NHIỀU điểm của layer rồi trộn (tách kênh màu ở mép chữ).
struct ThreeModifiersDemo: View {
    @State private var strength = 1.0 // 0 = tắt cả ba, 1 = mạnh nhất

    var body: some View {
        VStack(spacing: 12) {
            Row(title: "Gốc") {
                Sample()
            }
            Row(title: "colorEffect") {
                // Trộn ảnh gốc với bản duotone theo cường độ, để slider cũng điều khiển được colorEffect
                Sample().overlay {
                    Sample().colorEffect(ShaderLibrary.duotone(.color(Palette.navy), .color(Palette.sand))).opacity(strength)
                }
            }
            Row(title: "distortionEffect") {
                Sample().distortionEffect(ShaderLibrary.wave(.float(14 * strength)),
                                          maxSampleOffset: CGSize(width: 14, height: 0))
            }
            Row(title: "layerEffect") {
                Sample().layerEffect(ShaderLibrary.chromatic(.float(8 * strength)),
                                     maxSampleOffset: CGSize(width: 8, height: 0))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .background { Backdrop() }
        .safeAreaInset(edge: .bottom) {
            ControlPanel {
                Slider(value: $strength, in: 0...1) {
                    Text("Cường độ")
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
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(.rect(cornerRadius: 20))
            .overlay { RoundedRectangle(cornerRadius: 20).strokeBorder(Palette.hairline) }
            .overlay(alignment: .topLeading) {
                Text(title)
                    .font(.caption.monospaced().weight(.medium))
                    .foregroundStyle(Palette.label)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.3), in: .capsule)
                    .padding(10)
            }
    }
}

/// Ảnh mẫu tĩnh: dải màu, lưới thẳng và chữ có cạnh sắc. Tĩnh để chỉ thấy tác dụng của shader.
private struct Sample: View {
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
