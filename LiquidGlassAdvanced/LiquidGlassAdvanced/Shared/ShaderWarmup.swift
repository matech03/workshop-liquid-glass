import SwiftUI

/// Shader được compile lúc dùng lần đầu, gây hitch. Gọi Shader.compile(as:) một lần khi khởi động.
/// Tắt bằng `-warmup NO` để thấy hitch lần đầu ở màn hình Performance.
@Observable
final class ShaderWarmup {
    static let shared = ShaderWarmup()

    private(set) var milliseconds: Double?
    private(set) var running = false

    static func run() async { await shared.run() }

    private func run() async {
        guard Launch.warmup, milliseconds == nil, !running else { return }
        running = true
        defer { running = false }
        let start = ContinuousClock.now
        let lib = ShaderLibrary.default
        let zero = Shader.Argument.float(0)
        let jobs: [(Shader, Shader.UsageType)] = [
            (lib.ripple(.float2(CGPoint.zero), zero, zero, zero, zero), .layerEffect),
            (lib.chromatic(zero), .layerEffect),
            (lib.fingerWarp(.float2(CGPoint.zero), zero, zero, zero), .distortionEffect),
            (lib.shift(zero), .distortionEffect),
            (lib.duotone(.color(.black), .color(.white)), .colorEffect),
            (lib.sheen(.boundingRect, .float2(CGPoint.zero)), .colorEffect),
        ]
        for (shader, usage) in jobs {
            try? await shader.compile(as: usage)
        }
        let elapsed = (ContinuousClock.now - start).components
        milliseconds = Double(elapsed.seconds) * 1000 + Double(elapsed.attoseconds) / 1e15
    }
}
