import SwiftUI

/// Màn hình gộp nhiều demo nhỏ: thanh chọn tab ở trên, mỗi tab một demo.
struct DemoTabs<Tab: Hashable & CaseIterable & RawRepresentable, Content: View>: View where Tab.RawValue == String, Tab.AllCases: RandomAccessCollection {
    @State private var tab: Tab
    @ViewBuilder var content: (Tab) -> Content

    init(_ initial: Tab, @ViewBuilder content: @escaping (Tab) -> Content) {
        _tab = State(initialValue: initial)
        self.content = content
    }

    var body: some View {
        content(tab)
            .id(tab) // đổi tab thì reset state của demo
            .safeAreaInset(edge: .top) {
                Picker("Demo", selection: $tab) {
                    ForEach(Array(Tab.allCases), id: \.self) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.vertical, 6)
            }
    }
}
