import SwiftUI

/// Level 3 · Cách làm: spring khi bị ngắt và decay khi thả tay.
struct Level3_Motion: View {
    enum Tab: String, CaseIterable { case spring = "Spring vs Ease", decay = "Decay" }

    var body: some View {
        DemoTabs(Tab.spring) { tab in
            switch tab {
            case .spring: SpringVsEaseDemo()
            case .decay: DecayDemo()
            }
        }
    }
}
