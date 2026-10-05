import SwiftUI

/// Level 2 · Đổi shape: một view, ba trạng thái `.circle` → `.card` → `.menu`.
/// GOOD: giữ một view, chỉ đổi frame + corner radius → SwiftUI nội suy shape, glass morph theo.
/// BAD (`splitViews`): mỗi trạng thái là một nhánh if/else riêng → identity đổi, SwiftUI chỉ fade, không morph.
enum ShapeState: CaseIterable { case circle, card, menu }

struct MorphingGlass: View {
    var splitViews = false
    @State private var state = ShapeState.circle

    var body: some View {
        Group {
            if splitViews {
                // Mỗi nhánh là một view khác: glassEffect gắn vào từng nhánh
                switch state {
                case .circle: shaped(.circle)
                case .card: shaped(.card)
                case .menu: shaped(.menu)
                }
            } else {
                shaped(state)
            }
        }
        .onTapGesture { go(state.next) }
        .sensoryFeedback(.impact, trigger: state)
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1.6))
                go(state.next)
            }
        }
    }

    private func shaped(_ s: ShapeState) -> some View {
        ZStack {
            // Transition gắn vào TỪNG nhánh của switch: đó là các view được thêm/bớt.
            switch s {
            case .circle:
                Image(systemName: "sparkles").font(.title2).transition(content)
            case .card:
                Text("Chạm để mở menu").font(.headline).transition(content)
            case .menu:
                VStack(alignment: .leading, spacing: 10) {
                    Label("Ảnh", systemImage: "photo")
                    Label("Tệp", systemImage: "doc")
                }
                .font(.headline)
                .transition(content)
            }
        }
        .frame(width: s.size.width, height: s.size.height)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: s.radius))
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
    var size: CGSize {
        switch self {
        case .circle: CGSize(width: 64, height: 64)
        case .card: CGSize(width: 240, height: 90)
        case .menu: CGSize(width: 170, height: 120)
        }
    }

    var radius: CGFloat { self == .circle ? 32 : 26 } // .circle: 64 / 2 nên ra hình tròn

    var next: ShapeState {
        let all = Self.allCases
        return all[(all.firstIndex(of: self)! + 1) % all.count]
    }
}

#Preview { MorphingGlass() }
