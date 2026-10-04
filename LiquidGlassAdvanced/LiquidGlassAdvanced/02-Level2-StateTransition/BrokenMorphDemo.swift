import SwiftUI

/// Level 2 · Lỗi: 4 nguyên nhân morph không chạy. Bật từng nguyên nhân, chạm nút "+", xem morph mất, rồi tắt đi.
/// Lỗi "glassEffect đặt trước frame/padding" tách riêng: nó làm sai KÍCH THƯỚC glass, không làm hỏng morph.
struct BrokenMorphDemo: View {
    var body: some View {
        ZStack {
            Backdrop()
            CauseLab()
        }
    }
}

private struct CauseLab: View {
    @State private var separateContainers = false
    @State private var noAnimation = false
    @State private var mismatchedID = false
    @State private var otherNamespace = false
    @State private var glassBeforeFrame = false
    @State private var open = false
    @Namespace private var ns
    @Namespace private var otherNS

    var body: some View {
        VStack {
            Spacer()
            menu
            Spacer()
            ControlPanel {
                Toggle("1 · Khác container", isOn: $separateContainers)
                Toggle("2 · Thiếu withAnimation", isOn: $noAnimation)
                Toggle("3 · ID lệch giữa 2 state", isOn: $mismatchedID)
                Toggle("4 · Khác @Namespace", isOn: $otherNamespace)
                Divider()
                Toggle("Lỗi kích thước (không phải lỗi morph)", isOn: $glassBeforeFrame)
                    .foregroundStyle(.orange)
            }
        }
        .sensoryFeedback(.selection, trigger: open)
    }

    @ViewBuilder private var menu: some View {
        if separateContainers {
            stack // nguyên nhân 1: mỗi phần tử tự bọc container riêng, xem item()
        } else {
            GlassEffectContainer(spacing: 24) { stack }
        }
    }

    private var stack: some View {
        VStack(spacing: 12) {
            if open {
                item("photo", id: "photo")
                item("doc", id: "file")
            }
            // nguyên nhân 3: ID tính theo state → SwiftUI coi là hai khối glass khác nhau, không morph
            item(open ? "xmark" : "plus", id: mismatchedID ? (open ? "close" : "open") : "toggle", size: 64)
                .onTapGesture(perform: toggle)
        }
    }

    @ViewBuilder
    private func item(_ symbol: String, id: String, size: CGFloat = 52) -> some View {
        let glyph = Image(systemName: symbol).font(.title2.weight(.semibold))
        let shaped = Group {
            if glassBeforeFrame {
                // lỗi kích thước: glass ôm sát icon, .frame chỉ thêm khoảng trống bên ngoài glass
                glyph.glassEffect(.regular.interactive(), in: .circle)
                    .frame(width: size, height: size)
            } else {
                glyph.frame(width: size, height: size)
                    .glassEffect(.regular.interactive(), in: .circle)
            }
        }
        // nguyên nhân 4: các nút con dùng namespace khác với nút chính → ID không khớp được với nhau
        .glassEffectID(id, in: otherNamespace && id != "toggle" && id != "open" && id != "close" ? otherNS : ns)

        if separateContainers {
            GlassEffectContainer { shaped }
        } else {
            shaped
        }
    }

    private func toggle() {
        if noAnimation {
            open.toggle() // nguyên nhân 2: không có animation bao quanh thay đổi state
        } else {
            withAnimation(.bouncy) { open.toggle() }
        }
    }
}

#Preview { BrokenMorphDemo() }
