import SwiftUI

/// Khung so sánh cho mọi demo trong level: nửa trên GOOD, nửa dưới BAD.
/// `good` / `bad`: keyword hoặc dòng code khác nhau giữa hai bản, để nhớ nhanh.
struct GoodBad<Good: View, Bad: View>: View {
    var good: String
    var bad: String
    @ViewBuilder var goodContent: Good
    @ViewBuilder var badContent: Bad

    var body: some View {
        Compare(top: .good, topCode: good, bottom: .bad, bottomCode: bad) {
            goodContent
        } bottomContent: {
            badContent
        }
    }
}

/// Hai nửa màn hình xếp dọc, mỗi nửa có nhãn và state riêng.
struct Compare<Top: View, Bottom: View>: View {
    var top: PaneLabel
    var topCode: String
    var bottom: PaneLabel
    var bottomCode: String
    @ViewBuilder var topContent: Top
    @ViewBuilder var bottomContent: Bottom

    var body: some View {
        VStack(spacing: 12) {
            Pane(label: top, code: topCode) { topContent }
            Pane(label: bottom, code: bottomCode) { bottomContent }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background { Backdrop() }
    }
}

struct PaneLabel {
    var text: String
    var color: Color

    static let good = PaneLabel(text: "GOOD", color: Palette.good)
    static let bad = PaneLabel(text: "BAD", color: Palette.bad)
}

/// Một nửa màn hình: thẻ bo góc, viền mảnh, nhãn nhỏ ở góc kèm keyword / code.
struct Pane<Content: View>: View {
    let label: PaneLabel
    let code: String
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Palette.surface)
            .clipShape(.rect(cornerRadius: 28))
            .overlay { RoundedRectangle(cornerRadius: 28).strokeBorder(Palette.hairline) }
            .overlay(alignment: .topLeading) {
                HStack(spacing: 8) {
                    Circle().fill(label.color).frame(width: 7, height: 7)
                    Text(label.text).font(.caption.weight(.semibold))
                    Text(code)
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .foregroundStyle(Palette.label)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(.black.opacity(0.35), in: .capsule)
                .padding(12)
            }
    }
}
