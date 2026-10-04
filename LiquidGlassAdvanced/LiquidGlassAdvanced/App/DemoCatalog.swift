import SwiftUI

// App đi theo bài: 4 level → tích hợp → performance → lưu ý. Mỗi level tối đa 2 màn hình:
// "a" là cách làm, "b" là lỗi hay gặp. Màn hình gộp nhiều demo dùng tab (DemoTabs).

enum Part: String, CaseIterable, Identifiable {
    case level1 = "Level 1 · Phản hồi chạm"
    case level2 = "Level 2 · Chuyển trạng thái"
    case level3 = "Level 3 · Chuyển động vật lý"
    case level4 = "Level 4 · Biến dạng tại điểm chạm"
    case integration = "Tích hợp"
    case performance = "Performance"
    case notes = "Lưu ý"

    var id: Self { self }
    var demos: [DemoID] { DemoID.allCases.filter { $0.part == self } }

    var tint: Color {
        switch self {
        case .level1: .blue
        case .level2: .teal
        case .level3: .orange
        case .level4: .pink
        case .integration: .indigo
        case .performance: .red
        case .notes: .gray
        }
    }
}

enum DemoID: String, CaseIterable, Identifiable, Hashable {
    case l1, l2a, l2b, l3a, l3b, l4a, l4b
    case finale, checkpoint1, checkpoint2, checkpoint3
    case performance, notes

    var id: Self { self }

    /// Khoá cho launch argument `-demo`, ví dụ `-demo 2a`, `-demo cp2`.
    var key: String {
        switch self {
        case .l1: "1"
        case .l2a: "2a"
        case .l2b: "2b"
        case .l3a: "3a"
        case .l3b: "3b"
        case .l4a: "4a"
        case .l4b: "4b"
        case .finale: "all"
        case .checkpoint1: "cp1"
        case .checkpoint2: "cp2"
        case .checkpoint3: "cp3"
        case .performance: "perf"
        case .notes: "notes"
        }
    }

    var part: Part {
        switch self {
        case .l1: .level1
        case .l2a, .l2b: .level2
        case .l3a, .l3b: .level3
        case .l4a, .l4b: .level4
        case .finale, .checkpoint1, .checkpoint2, .checkpoint3: .integration
        case .performance: .performance
        case .notes: .notes
        }
    }

    var title: String {
        switch self {
        case .l1: "Highlight + haptic"
        case .l2a: "Morph: hòa nhau, thêm/bớt, đổi shape"
        case .l2b: "Lỗi: morph hỏng, không nội suy"
        case .l3a: "Spring khi bị ngắt, decay khi thả"
        case .l3b: "Menu cung tròn"
        case .l4a: "Shader modifier, ripple"
        case .l4b: "Méo nền dưới lớp glass"
        case .finale: "Đủ 4 level · 53 dòng"
        case .checkpoint1: "Checkpoint 1 · nền"
        case .checkpoint2: "Checkpoint 2 · + kéo thả"
        case .checkpoint3: "Checkpoint 3 · + morph"
        case .performance: "Đo GPU: 5 / 20 / 50 phần tử"
        case .notes: "Glass vs blur, trợ năng, quy tắc ship"
        }
    }

    /// Một dòng hướng dẫn ở đầu màn hình. Màn hình toàn cảnh không có.
    var hint: String? {
        switch self {
        case .l1: "Chạm 2 nút. Tắt “Đổi trigger”: mất haptic"
        case .l2a: "Đổi tab, chạm hoặc kéo để morph"
        case .l2b: "Bật 1 lỗi → chạm → so với bản đúng"
        case .l3a: "Bấm liên tục / kéo rồi thả"
        case .l3b: "Chạm +: so Layout với Keyframe"
        case .l4a: "Kéo slider / chạm nền"
        case .l4b: "Kéo vùng méo, đổi dưới/trên"
        case .performance: "Chọn 5 / 20 / 50, mở Instruments"
        case .notes: "Đổi tab: 3 lưu ý trước khi ship"
        default: nil
        }
    }

    var file: String {
        switch self {
        case .l1: "TouchFeedbackDemo.swift"
        case .l2a, .l2b: "Level2.swift"
        case .l3a: "Level3.swift"
        case .l3b: "ArcMenu.swift"
        case .l4a: "Level4.swift"
        case .l4b: "DistortionUnderGlassDemo.swift"
        case .finale: "Finale.swift"
        case .checkpoint1: "Checkpoint1.swift"
        case .checkpoint2: "Checkpoint2.swift"
        case .checkpoint3: "Checkpoint3.swift"
        case .performance: "GlassStressDemo.swift"
        case .notes: "Notes.swift"
        }
    }

    @ViewBuilder var screen: some View {
        switch self {
        case .l1: TouchFeedbackDemo()
        case .l2a: Level2_Morph()
        case .l2b: Level2_Pitfalls()
        case .l3a: Level3_Motion()
        case .l3b: ArcMenuDemo()
        case .l4a: Level4_Shaders()
        case .l4b: DistortionUnderGlassDemo()
        case .finale: Finale()
        case .checkpoint1: Checkpoint1()
        case .checkpoint2: Checkpoint2()
        case .checkpoint3: Checkpoint3()
        case .performance: GlassStressDemo()
        case .notes: NotesDemo()
        }
    }

    /// Màn hình toàn cảnh: ẩn thanh điều hướng, chỉ còn nhãn mờ ở góc.
    var immersive: Bool {
        switch self {
        case .finale, .checkpoint1, .checkpoint2, .checkpoint3: true
        default: false
        }
    }

    var next: DemoID? { offset(1) }
    var previous: DemoID? { offset(-1) }

    private func offset(_ step: Int) -> DemoID? {
        let all = Self.allCases
        let i = all.firstIndex(of: self)! + step
        return all.indices.contains(i) ? all[i] : nil
    }

    /// Màn hình mở sẵn khi chạy với `-demo KEY`.
    static var launchPath: [DemoID] {
        guard let key = Launch.demo else { return [] }
        return allCases.first { $0.key == key }.map { [$0] } ?? []
    }
}

struct RootView: View {
    @State private var path = DemoID.launchPath

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
            .navigationTitle("Liquid Glass Advanced")
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
                .font(.system(.footnote, design: .rounded).weight(.bold))
                .frame(width: 46, height: 46)
                .glassEffect(.regular.tint(demo.part.tint.opacity(0.45)), in: .circle)
            VStack(alignment: .leading, spacing: 3) {
                Text(demo.title)
                    .font(.body.weight(.medium))
                Text(demo.file)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

/// Khung chung: tên phần ở tiêu đề, tên màn hình ở subtitle, nút lên/xuống để chuyển nhanh.
private struct DemoContainer: View {
    let demo: DemoID
    @Binding var path: [DemoID]

    var body: some View {
        Group {
            if demo.immersive {
                demo.screen
                    .toolbar(.hidden, for: .navigationBar)
                    .overlay(alignment: .topTrailing) {
                        DemoTag(demo: demo, path: $path).padding(.trailing)
                    }
            } else {
                demo.screen
                    .safeAreaInset(edge: .top) {
                        if let hint = demo.hint { DemoHint(text: hint) }
                    }
                    .navigationTitle(demo.part.rawValue)
                    .navigationSubtitle(demo.title)
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
        }
        .overlay(alignment: .bottomLeading) {
            if Launch.showsMeter {
                FrameTimeOverlay().padding()
            }
        }
    }

    private func go(_ target: DemoID?) {
        guard let target else { return }
        path = [target]
    }
}
