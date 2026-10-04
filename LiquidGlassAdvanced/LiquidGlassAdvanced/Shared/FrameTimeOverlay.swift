import SwiftUI
import QuartzCore

/// Đo nhịp khung hình bằng CADisplayLink. Đây là nhịp main thread:
/// nếu nghẽn ở GPU/render server, xác nhận lại bằng Instruments (Animation Hitches, Metal System Trace).
@Observable
final class FrameClock: NSObject {
    private(set) var averageMs: Double = 0
    private(set) var worstMs: Double = 0
    private(set) var targetMs: Double = 1000 / 60
    private(set) var dropped = 0

    var fps: Double { averageMs > 0 ? 1000 / averageMs : 0 }

    @ObservationIgnored private var link: CADisplayLink?
    @ObservationIgnored private var last: CFTimeInterval = 0
    @ObservationIgnored private var windowStart: CFTimeInterval = 0
    @ObservationIgnored private var sum: Double = 0
    @ObservationIgnored private var count = 0
    @ObservationIgnored private var worst: Double = 0

    func start() {
        guard link == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 120, preferred: 120)
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    func stop() {
        link?.invalidate()
        link = nil
        last = 0
    }

    func resetDrops() { dropped = 0 }

    @objc private func tick(_ link: CADisplayLink) {
        defer { last = link.timestamp }
        guard last > 0 else { windowStart = link.timestamp; return }

        let ms = (link.timestamp - last) * 1000
        let target = (link.targetTimestamp - link.timestamp) * 1000
        sum += ms
        count += 1
        worst = max(worst, ms)
        if ms > target * 1.5 { dropped += 1 }

        // Chỉ cập nhật giao diện 4 lần/giây để chính đồng hồ không làm tốn frame.
        if link.timestamp - windowStart >= 0.25 {
            averageMs = sum / Double(count)
            worstMs = worst
            targetMs = target
            sum = 0; count = 0; worst = 0
            windowStart = link.timestamp
        }
    }
}

struct FrameTimeOverlay: View {
    @State private var clock: FrameClock

    init(clock: FrameClock? = nil) {
        _clock = State(initialValue: clock ?? FrameClock())
    }

    var body: some View {
        HStack(spacing: 10) {
            Circle().fill(status).frame(width: 8, height: 8)
            Text("\(clock.averageMs, format: .number.precision(.fractionLength(1))) ms")
            Text("\(clock.fps, format: .number.precision(.fractionLength(0))) fps")
                .foregroundStyle(.secondary)
            Text("tệ nhất \(clock.worstMs, format: .number.precision(.fractionLength(0)))")
                .foregroundStyle(.secondary)
            Text("rớt \(clock.dropped)")
                .foregroundStyle(clock.dropped > 0 ? .orange : .secondary)
        }
        .font(.caption.monospacedDigit().weight(.semibold))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.black.opacity(0.7), in: .capsule)
        .onTapGesture { clock.resetDrops() }
        .onAppear { clock.start() }
        .onDisappear { clock.stop() }
    }

    private var status: Color {
        if clock.averageMs == 0 { return .gray }
        if clock.averageMs <= clock.targetMs * 1.1 { return .green }
        if clock.averageMs <= clock.targetMs * 1.6 { return .yellow }
        return .red
    }
}
