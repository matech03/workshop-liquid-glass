import SwiftUI

/// Level 2 · Cách làm: ba kiểu morph, mỗi tab một kiểu.
struct Level2_Morph: View {
    enum Tab: String, CaseIterable { case blend = "Hòa nhau", addRemove = "Thêm / bớt", shape = "Đổi shape" }

    var body: some View {
        DemoTabs(Tab.addRemove) { tab in
            switch tab {
            case .blend: BlendingDemo()
            case .addRemove: MorphMenuDemo()
            case .shape: ShapeMorphDemo()
            }
        }
    }
}

/// Level 2 · Lỗi hay gặp: morph hỏng và view không nội suy.
struct Level2_Pitfalls: View {
    enum Tab: String, CaseIterable { case morph = "Morph hỏng", interpolation = "Không nội suy" }

    var body: some View {
        DemoTabs(Tab.morph) { tab in
            switch tab {
            case .morph: BrokenMorphDemo()
            case .interpolation: NoInterpolationDemo()
            }
        }
    }
}
