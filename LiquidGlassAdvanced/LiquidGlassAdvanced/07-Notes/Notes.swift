import SwiftUI

/// Lưu ý trước khi ship: glass khác blur, trợ năng, 3 quy tắc.
struct NotesDemo: View {
    enum Tab: String, CaseIterable { case material = "Glass vs blur", accessibility = "Trợ năng", rules = "Quy tắc" }

    var body: some View {
        DemoTabs(Tab.material) { tab in
            switch tab {
            case .material: GlassVariantsDemo()
            case .accessibility: AccessibilityDemo()
            case .rules: ShipRulesDemo()
            }
        }
    }
}
