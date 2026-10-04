import SwiftUI

// Level 2 · LIVE CODE: nút "+" thêm/bớt các nút con. Morph bằng glassEffectID + @Namespace,
// thay đổi state bọc trong withAnimation. Phần cốt lõi là struct MorphMenu: body 20 dòng.

struct MorphMenu: View {
    @State private var open = false
    @Namespace private var ns

    var body: some View {
        GlassEffectContainer(spacing: 24) {
            VStack(spacing: 12) {
                if open {
                    Button("Ảnh", systemImage: "photo") {}
                        .buttonStyle(.glass)
                        .glassEffectID("photo", in: ns)
                    Button("Tệp", systemImage: "doc") {}
                        .buttonStyle(.glass)
                        .glassEffectID("file", in: ns)
                }
                Button { withAnimation(.bouncy) { open.toggle() } } label: {
                    Image(systemName: open ? "xmark" : "plus").frame(width: 44, height: 44)
                }
                .buttonStyle(.glass)
                .glassEffectID("toggle", in: ns)
            }
        }
        .sensoryFeedback(.selection, trigger: open)
    }
}

/// Khung trình chiếu: nền nhiều màu để thấy khúc xạ. Thanh trượt spacing nằm ở tab Hòa nhau.
struct MorphMenuDemo: View {
    var body: some View {
        ZStack {
            Backdrop()
            MorphMenu()
                .controlSize(.large)
        }
    }
}

#Preview { MorphMenuDemo() }
