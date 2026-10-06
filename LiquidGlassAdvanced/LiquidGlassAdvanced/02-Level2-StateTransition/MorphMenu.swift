import SwiftUI

// Level 2 · LIVE CODE: nút "+" thêm/bớt các nút con. Morph bằng glassEffectID + @Namespace,
// thay đổi state bọc trong withAnimation. Phần cốt lõi là struct MorphMenu: body 20 dòng.
// `broken`: bản BAD, bỏ glassEffectID và withAnimation → nút con hiện ra tức thì, không morph.

struct MorphMenu: View {
    var broken = false
    @State private var open = false
    @Namespace private var ns

    var body: some View {
        GlassEffectContainer(spacing: 12) {
            HStack(spacing: 20) { // lớn hơn spacing của container: lúc nghỉ các nút không dính vào nhau
                Button { toggle() } label: {
                    Image(systemName: open ? "xmark" : "plus").frame(width: 44, height: 44)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .glassEffectID("toggle", in: ns)
                if open {
                    Button("Photo", systemImage: "photo") {}
                        .buttonStyle(.glass)
                        .glassEffectID(broken ? "photo-\(open)" : "photo", in: ns)
                    Button("File", systemImage: "doc") {}
                        .buttonStyle(.glass)
                        .glassEffectID(broken ? "file-\(open)" : "file", in: ns)
                }
            }
        }
        .controlSize(.large)
        .sensoryFeedback(.selection, trigger: open)
    }

    private func toggle() {
        if broken { open.toggle() } else { withAnimation(.bouncy) { open.toggle() } }
    }
}

#Preview { MorphMenu() }
