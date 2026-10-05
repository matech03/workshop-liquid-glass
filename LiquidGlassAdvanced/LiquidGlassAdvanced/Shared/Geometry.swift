import SwiftUI

extension CGPoint {
    func clamped(to size: CGSize, inset: CGFloat = 0) -> CGPoint {
        CGPoint(x: min(max(x, inset), size.width - inset),
                y: min(max(y, inset), size.height - inset))
    }
}
