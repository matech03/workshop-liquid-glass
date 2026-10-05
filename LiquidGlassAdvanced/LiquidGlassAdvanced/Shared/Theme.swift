import SwiftUI

/// Bảng màu chung: nền tối trung tính, màu nhấn dịu. Mọi màn hình lấy màu từ đây để hài hoà với nhau.
enum Palette {
    static let background = Color(red: 0.05, green: 0.055, blue: 0.07)
    static let surface = Color.white.opacity(0.035)
    static let hairline = Color.white.opacity(0.08)
    static let label = Color.white.opacity(0.72)

    static let accent = Color.accentColor
    static let good = Color(red: 0.48, green: 0.83, blue: 0.64)
    static let bad = Color(red: 0.95, green: 0.55, blue: 0.50)
    static let warm = Color(red: 0.96, green: 0.70, blue: 0.52)
    static let neutral = Color.white.opacity(0.45)

    /// Màu dịu cho nền nhiều màu, thẻ ảnh, ảnh mẫu shader
    static let navy = Color(red: 0.11, green: 0.12, blue: 0.24)
    static let violet = Color(red: 0.36, green: 0.30, blue: 0.58)
    static let slate = Color(red: 0.20, green: 0.34, blue: 0.52)
    static let rose = Color(red: 0.70, green: 0.40, blue: 0.54)
    static let peach = Color(red: 0.90, green: 0.62, blue: 0.48)
    static let teal = Color(red: 0.30, green: 0.60, blue: 0.62)
    static let sand = Color(red: 0.86, green: 0.76, blue: 0.54)
}
