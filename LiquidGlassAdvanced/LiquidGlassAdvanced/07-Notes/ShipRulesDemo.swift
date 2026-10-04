import SwiftUI

/// Lưu ý · 3 quy tắc trước khi ship. Chạm để hiện lần lượt.
struct ShipRulesDemo: View {
    @State private var step = 0

    private let rules = [
        "Liquid Glass dành cho lớp điều hướng và điều khiển nổi trên nội dung. Không chồng lớp glass lên nhau.",
        "Các phần tử liên quan nằm chung GlassEffectContainer; mọi thay đổi state bọc trong withAnimation.",
        "Liquid Glass và shader cùng chạy trên GPU: đo bằng Instruments trên máy thật trước khi ship.",
        "Mỗi phần tử Liquid Glass phải có phản hồi khi chạm.",
    ]

    var body: some View {
        ZStack {
            Backdrop()
            VStack(alignment: .leading, spacing: 18) {
                ForEach(rules.indices, id: \.self) { i in
                    if i < step {
                        HStack(alignment: .firstTextBaseline, spacing: 14) {
                            Text(i < 3 ? "\(i + 1)" : "+")
                                .font(.title2.weight(.black).monospacedDigit())
                                .frame(width: 28)
                            Text(rules[i]).font(.title3.weight(.semibold))
                        }
                        .transition(.blurReplace)
                    }
                }
            }
            .padding(.horizontal, 28)
            .frame(maxHeight: .infinity, alignment: .center)

            GlassCircle(size: step == 0 ? 120 : 28)
                .frame(maxHeight: .infinity, alignment: step == 0 ? .center : .bottom)
                .padding(.bottom, 60)
        }
        .contentShape(.rect)
        .onTapGesture { withAnimation(.bouncy(duration: 0.7)) { step = step < rules.count ? step + 1 : 0 } }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: step)
        .autoplay(every: 1.2) { withAnimation(.bouncy(duration: 0.7)) { step = step < rules.count ? step + 1 : 0 } }
    }
}

#Preview { ShipRulesDemo() }
