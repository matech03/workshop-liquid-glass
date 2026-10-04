import SwiftUI

/// Level 2 · Lỗi: 4 lý do view không nội suy. Mỗi ô có công tắc "Sửa" để so sánh.
struct NoInterpolationDemo: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                BugCase(number: 1, title: "if/else đổi identity → transition") { fixed, on in IdentityCase(fixed: fixed, on: on) }
                BugCase(number: 2, title: "Thuộc tính không nằm trong animatableData") { fixed, on in AnimatableDataCase(fixed: fixed, on: on) }
                BugCase(number: 3, title: ".animation(_:value:) đặt trước modifier", explicit: false) { fixed, on in PlacementCase(fixed: fixed, on: on) }
                BugCase(number: 4, title: "Transaction bị ghi đè ở view con") { fixed, on in TransactionCase(fixed: fixed, on: on) }
            }
            .padding()
        }
        .background(Color(white: 0.07))
    }
}

/// Khung một ô: chạm để đổi state, công tắc "Sửa" để so sánh.
/// `explicit`: bọc thay đổi trong withAnimation. Ô 3 thì không: withAnimation sẽ animate luôn offset và che mất lỗi.
private struct BugCase<Demo: View>: View {
    let number: Int
    let title: String
    var explicit = true
    @ViewBuilder var demo: (_ fixed: Bool, _ on: Bool) -> Demo

    @State private var fixed = false
    @State private var on = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(number)").font(.headline.monospacedDigit()).foregroundStyle(.secondary)
                Text(title).font(.headline)
                Spacer()
                Toggle("Sửa", isOn: $fixed).fixedSize()
            }
            demo(fixed, on)
                .frame(maxWidth: .infinity)
                .frame(height: 110)
                .contentShape(.rect)
                .onTapGesture(perform: flip)
        }
        .padding(16)
        .background(Color(white: 0.13), in: .rect(cornerRadius: 22))
        .autoplay(every: 1.3, flip)
    }

    private func flip() {
        if explicit {
            withAnimation(.bouncy(duration: 0.6)) { on.toggle() }
        } else {
            on.toggle()
        }
    }
}

// 1. Hai nhánh if/else là hai view khác identity: SwiftUI chạy transition (mặc định là fade), không nội suy frame.
private struct IdentityCase: View {
    let fixed: Bool
    let on: Bool

    var body: some View {
        if fixed {
            Circle().fill(.orange).frame(width: on ? 100 : 44)
        } else if on {
            Circle().fill(.orange).frame(width: 100)
        } else {
            Circle().fill(.orange).frame(width: 44)
        }
    }
}

// 2. Shape tự viết không khai báo animatableData: SwiftUI không nội suy `progress`, path nhảy thẳng tới giá trị cuối.
private struct AnimatableDataCase: View {
    let fixed: Bool
    let on: Bool

    var body: some View {
        let progress = on ? 1.0 : 0.15
        Group {
            if fixed {
                ArcFixed(progress: progress).stroke(.orange, style: .init(lineWidth: 14, lineCap: .round))
            } else {
                ArcBroken(progress: progress).stroke(.orange, style: .init(lineWidth: 14, lineCap: .round))
            }
        }
        .frame(width: 96, height: 96)
    }
}

nonisolated private struct ArcBroken: Shape {
    var progress: Double

    func path(in rect: CGRect) -> Path {
        Path { $0.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2,
                         startAngle: .degrees(-90), endAngle: .degrees(-90 + 360 * progress), clockwise: false) }
    }
}

nonisolated private struct ArcFixed: Shape {
    var progress: Double
    var animatableData: Double { // iOS 26+: có thể thay bằng macro @Animatable
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        ArcBroken(progress: progress).path(in: rect)
    }
}

// 3. .animation(_:value:) chỉ áp cho các modifier đứng TRƯỚC nó trong chuỗi. Lỗi chỉ lộ khi không có withAnimation.
private struct PlacementCase: View {
    let fixed: Bool
    let on: Bool

    var body: some View {
        if fixed {
            GlassCircle(size: 56)
                .offset(x: on ? 100 : -100)
                .animation(.bouncy, value: on)
        } else {
            GlassCircle(size: 56)
                .animation(.bouncy, value: on) // .offset đứng sau .animation nên không được animate
                .offset(x: on ? 100 : -100)
        }
    }
}

// 4. View con ghi đè Transaction (t.animation = nil, hoặc withTransaction với disablesAnimations) → withAnimation của cha mất tác dụng.
private struct TransactionCase: View {
    let fixed: Bool
    let on: Bool

    var body: some View {
        GlassCircle(size: 56)
            .scaleEffect(on ? 1.5 : 0.8)
            .transaction { t in
                if !fixed { t.animation = nil }
                // Chỉ in khi chạy với -logTransactions YES, để -autoplay không làm đầy console
                guard Launch.logsTransactions else { return }
                print("[S09] Transaction:", t.animation.map(String.init(describing:)) ?? "nil",
                      "| disablesAnimations:", t.disablesAnimations)
            }
    }
}

#Preview { NoInterpolationDemo() }
