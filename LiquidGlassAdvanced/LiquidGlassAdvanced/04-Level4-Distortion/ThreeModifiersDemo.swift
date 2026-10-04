import SwiftUI

/// Level 4 · Ba shader modifier trên cùng một nội dung. Khác nhau ở input và ở giá trị hàm Metal trả về.
struct ThreeModifiersDemo: View {
    @State private var dx: Double = 30
    @State private var amount: Double = 6

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Row(name: "colorEffect", returns: "màu mới của pixel") {
                    Sample()
                        .colorEffect(ShaderLibrary.duotone(.color(.indigo), .color(.yellow)))
                }
                Row(name: "distortionEffect", returns: "tọa độ nguồn để lấy mẫu") {
                    Sample()
                        // trả về position + dx → lấy mẫu từ bên phải → nội dung dịch sang TRÁI
                        .distortionEffect(ShaderLibrary.shift(.float(dx)),
                                          maxSampleOffset: CGSize(width: abs(dx), height: 0))
                }
                Row(name: "layerEffect", returns: "màu mới; gọi layer.sample() nhiều lần") {
                    Sample()
                        .layerEffect(ShaderLibrary.chromatic(.float(amount)),
                                     maxSampleOffset: CGSize(width: amount, height: 0))
                }
            }
            .padding()
        }
        .background(Color(white: 0.07))
        .safeAreaInset(edge: .bottom) {
            ControlPanel {
                LabeledContent("shift dx") { Text("\(Int(dx)) pt").monospacedDigit() }
                Slider(value: $dx, in: -60...60)
                LabeledContent("chromatic") { Text("\(Int(amount)) pt").monospacedDigit() }
                Slider(value: $amount, in: 0...20)
            }
        }
    }
}

private struct Row<Content: View>: View {
    let name: String
    let returns: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(".\(name)").font(.headline.monospaced())
                Spacer()
                Text("→ \(returns)").font(.caption).foregroundStyle(.secondary)
            }
            content
                .frame(height: 92)
                .clipShape(.rect(cornerRadius: 18))
        }
        .padding(14)
        .background(Color(white: 0.13), in: .rect(cornerRadius: 22))
    }
}

/// Nội dung mẫu có cạnh sắc và chữ để thấy rõ shader làm gì.
/// Chỉ phần nền đổi theo thời gian, nên TimelineView bọc riêng nền thay vì cả màn hình.
private struct Sample: View {
    var body: some View {
        ZStack {
            TimelineView(.animation) { context in
                MeshBackground(time: context.date.timeIntervalSinceReferenceDate, pattern: false)
            }
            HStack(spacing: 14) {
                GlassCircle(size: 64)
                Text("GLASS").font(.system(size: 48, weight: .black, design: .rounded))
            }
            // Vạch dọc làm mốc để thấy distortion dịch bao nhiêu pt
            Rectangle().fill(.white).frame(width: 2)
        }
    }
}

#Preview { ThreeModifiersDemo() }
