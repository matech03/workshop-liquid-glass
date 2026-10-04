import SwiftUI

/// Tham số khi chạy (Edit Scheme → Run → Arguments):
/// `-demo 2a` mở thẳng màn hình 2a (`-demo cp2` cho checkpoint), `-autoplay YES` cho demo tự chạy,
/// `-meter YES` hiện đồng hồ frame time ở mọi màn hình, `-warmup NO` tắt compile shader trước,
/// `-logTransactions YES` in Transaction ở tab Không nội suy (2b) ra console.
enum Launch {
    private static let defaults = UserDefaults.standard

    static var demo: String? { defaults.string(forKey: "demo") }
    static var autoplay: Bool { defaults.bool(forKey: "autoplay") }
    static var showsMeter: Bool { defaults.bool(forKey: "meter") }
    static var logsTransactions: Bool { defaults.bool(forKey: "logTransactions") }
    static var warmup: Bool { defaults.object(forKey: "warmup") == nil || defaults.bool(forKey: "warmup") }
    static func flag(_ key: String) -> Bool { defaults.bool(forKey: key) }
}

extension View {
    /// Lặp `step` khi chạy với `-autoplay YES`: để quay video dự phòng và chụp màn hình.
    func autoplay(every seconds: Double, _ step: @escaping @MainActor () -> Void) -> some View {
        task {
            guard Launch.autoplay else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(seconds))
                guard !Task.isCancelled else { break }
                step()
            }
        }
    }
}

extension CGPoint {
    func clamped(to size: CGSize, inset: CGFloat = 0) -> CGPoint {
        CGPoint(x: min(max(x, inset), size.width - inset),
                y: min(max(y, inset), size.height - inset))
    }
}
