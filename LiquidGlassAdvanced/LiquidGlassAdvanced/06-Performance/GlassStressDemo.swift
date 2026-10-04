import SwiftUI

/// Performance · 5, 20, 50 phần tử glass, ba chế độ: glass riêng lẻ / trong GlassEffectContainer / + layerEffect.
/// Overlay chỉ đo nhịp main thread. Glass do render server vẽ trên GPU, nên số liệu để trình bày phải lấy từ
/// Instruments (Metal System Trace, Hitches) trên máy thật.
struct GlassStressDemo: View {
    enum Mode: String, CaseIterable, Identifiable {
        case separate = "Riêng lẻ"
        case container = "Container"
        case shader = "+ layerEffect nền"
        var id: Self { self }
    }

    @State private var count = 5
    @State private var mode = Mode.separate
    @State private var clock = FrameClock()
    private var warmup: ShaderWarmup { .shared }

    var body: some View {
        TimelineView(.animation) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            GeometryReader { geo in
                ZStack {
                    // Shader đặt trên NỀN dưới glass. Bọc cả cụm glass trong layerEffect thì glass bị
                    // rasterize vào layer riêng, không lấy mẫu được nền phía sau và biến mất (kể cả isEnabled: false).
                    MeshBackground(time: t)
                        // isEnabled: false → SwiftUI bỏ shader khỏi pipeline, không chạy shader rỗng
                        .layerEffect(ShaderLibrary.chromatic(.float(4)),
                                     maxSampleOffset: CGSize(width: 4, height: 0),
                                     isEnabled: mode == .shader)
                    swarm(time: t, in: geo.size)
                }
            }
        }
        .ignoresSafeArea()
        .safeAreaInset(edge: .top) {
            VStack(spacing: 4) {
                FrameTimeOverlay(clock: clock)
                Text("Nhịp main thread (CADisplayLink), không đo GPU. Số liệu thật: Instruments (Metal System Trace, Hitches)")
                    .font(.caption2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.6), in: .capsule)
            }
            .padding(.horizontal)
            .padding(.top, 4)
        }
        .safeAreaInset(edge: .bottom) {
            ControlPanel {
                Picker("Chế độ", selection: $mode) {
                    ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                HStack {
                    ForEach([5, 20, 50], id: \.self) { n in
                        Button("\(n)") { count = n; clock.resetDrops() }
                            .buttonStyle(.glass)
                            .tint(count == n ? .orange : nil)
                    }
                    Spacer()
                    Text("\(count) phần tử").font(.headline.monospacedDigit())
                }
                Group {
                    if let ms = warmup.milliseconds {
                        Text("Shader.compile(as:) lúc khởi động: \(ms, format: .number.precision(.fractionLength(0))) ms cho 6 shader")
                            .foregroundStyle(.secondary)
                    } else if warmup.running {
                        Text("Đang compile shader…").foregroundStyle(.secondary)
                    } else {
                        Text("Chưa compile trước (-warmup NO): lần bật layerEffect đầu tiên sẽ có hitch")
                            .foregroundStyle(.orange)
                    }
                }
                .font(.footnote)
            }
        }
        .autoplay(every: 3) {
            let steps = [5, 20, 50]
            count = steps[((steps.firstIndex(of: count) ?? -1) + 1) % steps.count]
        }
    }

    @ViewBuilder
    private func swarm(time t: Double, in size: CGSize) -> some View {
        let circles = ForEach(0..<count, id: \.self) { i in
            let seed = Double(i) * 1.7
            GlassCircle(size: 56, glass: .regular)
                .position(x: size.width * (0.5 + 0.4 * sin(t * 0.7 + seed)),
                          y: size.height * (0.45 + 0.35 * cos(t * 0.5 + seed * 1.3)))
        }
        if mode == .separate {
            ZStack { circles }
        } else {
            GlassEffectContainer(spacing: 0) { ZStack { circles } }
        }
    }
}

#Preview { GlassStressDemo() }
