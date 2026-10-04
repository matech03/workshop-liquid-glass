import SwiftUI

/// Lưu ý · Liquid Glass khác blur + tint. Đổi biến thể trên nền phẳng và nền nhiều màu.
/// `.regular` và `.clear` là hai biến thể glass. `.identity` = không có glass: tắt hiệu ứng mà không đổi cấu trúc view.
/// `.clear` trong hơn nên cần một lớp làm tối nền phía sau thì chữ trên glass mới đọc được.
struct GlassVariantsDemo: View {
    enum Variant: String, CaseIterable, Identifiable {
        case regular, clear, identity
        var id: Self { self }
        var glass: Glass {
            switch self {
            case .regular: .regular
            case .clear: .clear
            case .identity: .identity
            }
        }
    }

    @State private var variant = Variant.regular
    @State private var vivid = true
    @State private var tinted = false
    @State private var interactive = true
    @State private var compareMaterial = false
    @State private var dimming = false

    private var glass: Glass {
        var g = variant.glass
        if tinted { g = g.tint(.orange.opacity(0.55)) }
        return g.interactive(interactive)
    }

    var body: some View {
        ZStack {
            Backdrop(style: vivid ? .vivid : .flat)
            // Lớp làm tối nền: cần khi dùng .clear trên nền sáng/nhiều màu
            Color.black.opacity(dimming ? 0.35 : 0).ignoresSafeArea()

            VStack(spacing: 28) {
                HStack(spacing: 18) {
                    sample(".glassEffect")
                        .glassEffect(glass, in: .rect(cornerRadius: 36))
                    if compareMaterial {
                        // Đối chứng: Material = blur + tint. Không khúc xạ, không có specular highlight thích ứng theo nền.
                        sample(".ultraThinMaterial")
                            .background(.ultraThinMaterial, in: .rect(cornerRadius: 36))
                    }
                }
                GlassCircle(size: 88, glass: glass)
            }
            .animation(.smooth, value: compareMaterial)
        }
        .safeAreaInset(edge: .bottom) {
            ControlPanel {
                Picker("Biến thể", selection: $variant) {
                    ForEach(Variant.allCases) { Text(".\($0.rawValue)").tag($0) }
                }
                .pickerStyle(.segmented)
                Toggle("Nền nhiều màu", isOn: $vivid)
                Toggle("Lớp làm tối nền (cho .clear)", isOn: $dimming)
                Toggle(".tint(.orange)", isOn: $tinted)
                Toggle(".interactive()", isOn: $interactive)
                Toggle("So với Material (blur)", isOn: $compareMaterial)
            }
        }
    }

    private func sample(_ label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: "drop.halffull").font(.largeTitle)
            Text(label).font(.caption.monospaced())
        }
        .frame(width: compareMaterial ? 150 : 220, height: 150)
    }
}

#Preview { GlassVariantsDemo() }
