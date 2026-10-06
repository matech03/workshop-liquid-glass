import SwiftUI

/// Màn hình gộp nhiều demo nhỏ. Chọn demo bằng menu hệ thống trên tiêu đề (`toolbarTitleMenu`),
/// tên demo đang chọn hiện ở dòng phụ dưới tiêu đề.
struct DemoTabs<Tab: Hashable & CaseIterable & RawRepresentable, Content: View>: View where Tab.RawValue == String, Tab.AllCases: RandomAccessCollection {
    @State private var tab: Tab
    @ViewBuilder var content: (Tab) -> Content

    init(_ initial: Tab, @ViewBuilder content: @escaping (Tab) -> Content) {
        _tab = State(initialValue: initial)
        self.content = content
    }

    var body: some View {
        content(tab)
            .id(tab) // đổi demo thì reset state của demo
            .navigationSubtitle(tab.rawValue)
            .toolbarTitleMenu {
                Picker("Demo", selection: $tab) {
                    ForEach(Array(Tab.allCases), id: \.self) { Text($0.rawValue).tag($0) }
                }
            }
    }
}
