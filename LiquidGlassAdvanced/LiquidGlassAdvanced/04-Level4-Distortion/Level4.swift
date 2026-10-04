import SwiftUI

/// Level 4 · Cách làm: ba shader modifier và ripple tại điểm chạm.
struct Level4_Shaders: View {
    enum Tab: String, CaseIterable { case modifiers = "3 modifier", ripple = "Ripple" }

    var body: some View {
        DemoTabs(Tab.ripple) { tab in
            switch tab {
            case .modifiers: ThreeModifiersDemo()
            case .ripple: RippleDemo()
            }
        }
    }
}
