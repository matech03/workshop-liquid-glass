import SwiftUI

/// Shader được compile lúc dùng lần đầu, gây hitch. Gọi Shader.compile(as:) một lần khi khởi động.
enum ShaderWarmup {
    private static var done = false

    static func run() async {
        guard !done else { return }
        done = true
        let lib = ShaderLibrary.default
        let zero = Shader.Argument.float(0)
        let jobs: [(Shader, Shader.UsageType)] = [
            (lib.ripple(.float2(CGPoint.zero), zero, zero, zero, zero), .layerEffect),
            (lib.chromatic(zero), .layerEffect),
            (lib.fingerWarp(.float2(CGPoint.zero), zero, zero, zero), .distortionEffect),
            (lib.wave(zero), .distortionEffect),
            (lib.duotone(.color(.black), .color(.white)), .colorEffect),
        ]
        for (shader, usage) in jobs {
            try? await shader.compile(as: usage)
        }
    }
}
