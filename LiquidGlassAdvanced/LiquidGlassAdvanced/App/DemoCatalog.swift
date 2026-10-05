import SwiftUI

// App đi theo bài: giới thiệu → 4 level → cấu hình hệ thống → ví dụ. Phần nguyên tắc chỉ có trên slide.
// Mỗi demo so sánh chia đôi màn hình (GoodBad / Compare). Màn hình nhiều demo dùng tab (DemoTabs).
// Màn hình ít chữ: hướng dẫn thao tác và dòng code nằm trên slide, không nằm trong app.

enum Part: String, CaseIterable, Identifiable {
    case intro = "Giới thiệu"
    case level1 = "Level 1 · Phản hồi chạm"
    case level2 = "Level 2 · Chuyển trạng thái"
    case level3 = "Level 3 · Chuyển động vật lý"
    case level4 = "Level 4 · Biến dạng tại điểm chạm"
    case config = "Cấu hình hệ thống"
    case examples = "Ví dụ"

    var id: Self { self }
    var demos: [DemoID] { DemoID.allCases.filter { $0.part == self } }

}

enum DemoID: String, CaseIterable, Identifiable, Hashable {
    case intro, l1, l2a, l2b, l3, l4
    case settings
    case photo, arc, match, lens

    var id: Self { self }

    /// Khoá hiện ở danh sách, trùng nhãn DEMO trên slide.
    var key: String {
        switch self {
        case .intro: "0"
        case .l1: "1"
        case .l2a: "2a"
        case .l2b: "2b"
        case .l3: "3"
        case .l4: "4"
        case .settings: "cfg"
        case .photo: "photo"
        case .arc: "arc"
        case .match: "match"
        case .lens: "lens"
        }
    }

    var part: Part {
        switch self {
        case .intro: .intro
        case .l1: .level1
        case .l2a, .l2b: .level2
        case .l3: .level3
        case .l4: .level4
        case .settings: .config
        case .photo, .arc, .match, .lens: .examples
        }
    }

    var title: String {
        switch self {
        case .intro: "Glass và blur"
        case .l1: "Phản hồi chạm"
        case .l2a: "Morph"
        case .l2b: "Lỗi morph"
        case .l3: "Spring và decay"
        case .l4: "Shader"
        case .settings: "Cài đặt người dùng"
        case .photo: "Nút trên ảnh"
        case .arc: "Menu cung tròn"
        case .match: "Chuyển cảnh"
        case .lens: "Biến dạng"
        }
    }

    @ViewBuilder var screen: some View {
        switch self {
        case .intro: GlassVsBlurDemo()
        case .l1: TouchFeedbackDemo()
        case .l2a: Level2_Morph()
        case .l2b: Level2_Pitfalls()
        case .l3: Level3_Motion()
        case .l4: Level4_Shaders()
        case .settings: SystemSettingsDemo()
        case .photo: PhotoControlsDemo()
        case .arc: ArcMenuDemo()
        case .match: MatchedTransitionDemo()
        case .lens: DistortionUnderGlassDemo()
        }
    }

    var next: DemoID? { offset(1) }
    var previous: DemoID? { offset(-1) }

    private func offset(_ step: Int) -> DemoID? {
        let all = Self.allCases
        let i = all.firstIndex(of: self)! + step
        return all.indices.contains(i) ? all[i] : nil
    }
}

struct RootView: View {
    @State private var path: [DemoID] = []

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(Part.allCases) { part in
                    Section(part.rawValue) {
                        ForEach(part.demos) { demo in
                            NavigationLink(value: demo) { DemoRow(demo: demo) }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Palette.background)
            .navigationTitle("Liquid Glass")
            .navigationDestination(for: DemoID.self) { demo in
                DemoContainer(demo: demo, path: $path)
            }
        }
        .task { await ShaderWarmup.run() }
    }
}

private struct DemoRow: View {
    let demo: DemoID

    var body: some View {
        HStack(spacing: 14) {
            Text(demo.key)
                .font(.system(.footnote, design: .rounded).weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(.secondary)
                .frame(width: 38, alignment: .leading)
            Text(demo.title)
        }
    }
}

/// Khung chung: tên màn ở tiêu đề, nút lên/xuống để chuyển nhanh.
/// Thanh điều hướng và các nút ở đây là glass của hệ thống: không có dòng glassEffect nào.
private struct DemoContainer: View {
    let demo: DemoID
    @Binding var path: [DemoID]

    var body: some View {
        demo.screen
            .navigationTitle(demo.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Màn trước", systemImage: "chevron.up") { go(demo.previous) }
                        .disabled(demo.previous == nil)
                    Button("Màn sau", systemImage: "chevron.down") { go(demo.next) }
                        .disabled(demo.next == nil)
                }
            }
    }

    private func go(_ target: DemoID?) {
        guard let target else { return }
        path = [target]
    }
}
