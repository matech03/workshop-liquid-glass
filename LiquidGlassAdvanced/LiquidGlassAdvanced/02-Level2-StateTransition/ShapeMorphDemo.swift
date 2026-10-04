import SwiftUI

/// Level 2 · Đổi shape: một view, ba trạng thái `.circle` → `.card` → `.menu`.
/// View giữ nguyên identity, chỉ đổi frame + corner radius → SwiftUI nội suy shape của glass, không cần glassEffectID.
/// glassEffectID dùng khi view được THÊM hoặc BỚT (identity thay đổi), như tab Thêm / bớt.
enum ShapeState: CaseIterable { case circle, card, menu }

struct MorphingGlass: View {
    @Binding var state: ShapeState

    private var size: CGSize {
        switch state {
        case .circle:  CGSize(width: 64, height: 64)
        case .card: CGSize(width: 300, height: 150)
        case .menu: CGSize(width: 240, height: 250)
        }
    }
    private var radius: CGFloat { state == .menu ? 28 : 32 } // .circle: radius = 64 / 2 nên ra hình tròn

    var body: some View {
        ZStack {
            // Transition gắn vào TỪNG nhánh của switch: đó là các view được thêm/bớt.
            // Đặt .transition trên ZStack không có tác dụng vì ZStack không bị thêm/bớt.
            switch state {
            case .circle:
                Image(systemName: "sparkles").font(.title2)
                    .transition(content)
            case .card:
                Text("Chạm để mở menu").font(.headline)
                    .transition(content)
            case .menu:
                VStack(alignment: .leading, spacing: 14) {
                    Label("Ảnh", systemImage: "photo")
                    Label("Tệp", systemImage: "doc")
                    Label("Thu gọn", systemImage: "xmark")
                        .onTapGesture { go(.circle) }
                }
                .font(.title3)
                .padding(20)
                .transition(content)
            }
        }
        .frame(width: size.width, height: size.height)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: radius))
        .onTapGesture {
            if state == .circle { go(.card) }
            else if state == .card { go(.menu) }
        }
        .sensoryFeedback(.impact, trigger: state)
        .autoplay(every: 1.6) { go(state.next) }
    }

    /// Nội dung hiện sau khung glass 0.15 s (chờ shape gần xong), ẩn nhanh khi rời đi.
    private var content: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.92))
                .animation(.smooth(duration: 0.3).delay(0.15)),
            removal: .opacity.animation(.easeOut(duration: 0.1))
        )
    }

    private func go(_ s: ShapeState) {
        withAnimation(.bouncy(duration: 0.6)) { state = s }
    }
}

private extension ShapeState {
    var next: ShapeState {
        let all = Self.allCases
        return all[(all.firstIndex(of: self)! + 1) % all.count]
    }
}

struct ShapeMorphDemo: View {
    @State private var state: ShapeState = .circle

    var body: some View {
        ZStack {
            Backdrop()
            MorphingGlass(state: $state)
        }
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 8) {
                ForEach(ShapeState.allCases, id: \.self) { s in
                    Text(".\(String(describing: s))")
                        .font(.callout.monospaced().weight(s == state ? .bold : .regular))
                        .foregroundStyle(s == state ? .primary : .secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.black.opacity(s == state ? 0.6 : 0.3), in: .capsule)
                }
            }
            .padding(.bottom, 8)
        }
    }
}

#Preview { ShapeMorphDemo() }
