import SwiftUI

/// Level 4 · Cách làm: ba shader modifier (so với ảnh gốc) và ripple tại điểm chạm (GOOD / BAD).
struct Level4_Shaders: View {
    enum Tab: String, CaseIterable { case modifiers = "3 modifier", ripple = "Ripple" }

    var body: some View {
        DemoTabs(Tab.modifiers) { tab in
            switch tab {
            case .modifiers: ThreeModifiersDemo()
            case .ripple:
                // Sóng tắt sau 1,5 s. GOOD bỏ shader khỏi pipeline lúc đó; BAD vẫn chạy shader mỗi frame.
                GoodBad(good: "isEnabled: t > 0 && t < 1.5", bad: "layerEffect luôn bật") {
                    RippleCore(stopsWhenIdle: true)
                } badContent: {
                    RippleCore(stopsWhenIdle: false)
                }
            }
        }
    }
}
