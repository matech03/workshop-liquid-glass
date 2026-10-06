import SwiftUI

// App đi theo bài (outline ở README gốc): Introduction → Implement levels → Examples. Phần Summary chỉ có trên slide.
// Mỗi demo so sánh chia đôi màn hình (GoodBad / Compare). Màn hình nhiều demo chọn demo bằng menu trên tiêu đề (DemoTabs).
// Màn hình ít chữ: hướng dẫn thao tác nằm trong README, dòng code hiện bằng nút ⓘ.

/// Ba nhóm trên màn home, trùng ba phần có demo trong outline slide (README).
enum Chapter: String, CaseIterable, Identifiable {
    case intro = "Introduction"
    case levels = "Implement levels"
    case examples = "Examples"

    var id: Self { self }
    var demos: [DemoID] { DemoID.allCases.filter { $0.chapter == self } }
}

enum DemoID: String, CaseIterable, Identifiable, Hashable {
    case intro, l1, l2, l3, l4
    case settings
    case photo, arc, match, fx

    var id: Self { self }

    /// Khoá hiện ở danh sách, trùng cột Màn trong outline (README).
    var key: String {
        switch self {
        case .intro: "0"
        case .l1: "1"
        case .l2: "2"
        case .l3: "3"
        case .l4: "4"
        case .settings: "cfg"
        case .photo: "photo"
        case .arc: "arc"
        case .match: "match"
        case .fx: "fx"
        }
    }

    var chapter: Chapter {
        switch self {
        case .intro: .intro
        case .l1, .l2, .l3, .l4, .settings: .levels
        case .photo, .arc, .match, .fx: .examples
        }
    }

    var title: String {
        switch self {
        case .intro: "Glass vs blur"
        case .l1: "Interactive glass"
        case .l2: "Morph"
        case .l3: "Physics"
        case .l4: "Shader"
        case .settings: "User settings"
        case .photo: "Controls on photos"
        case .arc: "Arc menu"
        case .match: "Transitions"
        case .fx: "Shader effects"
        }
    }

    /// Keyword dưới tên màn: nội dung chính của demo.
    var subtitle: String {
        switch self {
        case .intro: "Refraction · scroll edge"
        case .l1: "Glass styles · highlight · haptic · union"
        case .l2: "Blend · add / remove · shape · pitfalls"
        case .l3: "Interrupt · drag & release · spring presets"
        case .l4: "Color · distortion · layer effect"
        case .settings: "Accessibility · light / dark"
        case .photo: ".clear over images"
        case .arc: "Custom Layout · animatableData"
        case .match: "Zoom transition · sheet · push"
        case .fx: "Ripple · vortex · glitch · lens"
        }
    }

    @ViewBuilder var screen: some View {
        switch self {
        case .intro: GlassVsBlurDemo()
        case .l1: TouchFeedbackDemo()
        case .l2: Level2_Morph()
        case .l3: Level3_Motion()
        case .l4: Level4_Shaders()
        case .settings: SystemSettingsDemo()
        case .photo: PhotoControlsDemo()
        case .arc: ArcMenuDemo()
        case .match: MatchedTransitionDemo()
        case .fx: ShaderEffectsDemo()
        }
    }
}

struct RootView: View {
    @State private var path: [DemoID] = []
    @State private var showsCode = false // giữ nguyên khi chuyển màn

    var body: some View {
        NavigationStack(path: $path) {
            List {
                ForEach(Chapter.allCases) { chapter in
                    Section {
                        ForEach(chapter.demos) { demo in
                            NavigationLink(value: demo) { DemoRow(demo: demo) }
                                .listRowBackground(Palette.surface)
                        }
                    } header: {
                        Text(chapter.rawValue)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Palette.label)
                            .textCase(nil)
                    }
                }
            }
            .listSectionSpacing(28)
            .scrollContentBackground(.hidden)
            .background(Palette.background)
            .navigationTitle("Liquid Glass")
            .navigationDestination(for: DemoID.self) { demo in
                DemoContainer(demo: demo, showsCode: $showsCode)
            }
        }
        .task { await ShaderWarmup.run() }
    }
}

private struct DemoRow: View {
    let demo: DemoID

    var body: some View {
        HStack(spacing: 14) {
            // Khoá màn hình, trùng nhãn DEMO trên slide
            Text(demo.key)
                .font(.caption.monospaced().weight(.semibold))
                .foregroundStyle(Palette.label)
                .frame(width: 52, height: 26)
                .background(.white.opacity(0.06), in: .capsule)
            VStack(alignment: .leading, spacing: 3) {
                Text(demo.title).font(.body.weight(.medium))
                Text(demo.subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Khung chung: tên màn ở tiêu đề, nút ⓘ hiện / ẩn keyword và code.
/// Thanh điều hướng và các nút ở đây là glass của hệ thống: không có dòng glassEffect nào.
/// Tắt vuốt để back (cạnh trái và toàn màn hình): demo có nhiều thao tác kéo, dễ vuốt nhầm. Back bằng nút.
private struct DemoContainer: View {
    let demo: DemoID
    @Binding var showsCode: Bool

    var body: some View {
        demo.screen
            .environment(\.showsCode, showsCode)
            .navigationTitle(demo.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Hints", systemImage: "info.circle") {
                        withAnimation(.smooth(duration: 0.25)) { showsCode.toggle() }
                    }
                    .tint(showsCode ? Palette.accent : nil)
                }
            }
            .background { SwipeBackDisabler() }
    }
}

/// SwiftUI chưa có API tắt vuốt back của NavigationStack: tắt thẳng hai gesture của UINavigationController.
/// Chỉ tắt khi màn demo đang hiện. Màn con push từ demo (vd Hero trong `match`) vẫn vuốt back được.
private struct SwipeBackDisabler: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller { Controller() }
    func updateUIViewController(_ controller: Controller, context: Context) {}

    final class Controller: UIViewController {
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setSwipeBack(enabled: false)
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            setSwipeBack(enabled: true)
        }

        private func setSwipeBack(enabled: Bool) {
            guard let nav = navigationController else { return }
            nav.interactivePopGestureRecognizer?.isEnabled = enabled        // vuốt từ cạnh trái
            nav.interactiveContentPopGestureRecognizer?.isEnabled = enabled // iOS 26: vuốt từ bất kỳ đâu
        }
    }
}
