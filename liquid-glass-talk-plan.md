# Trải nghiệm người dùng xuất sắc với Liquid Glass

**45 phút** · dev iOS · Demo: `LiquidGlassAdvanced` · Slide: `slides/Trai-nghiem-Liquid-Glass.pptx`

Phần nói chi tiết cho từng slide nằm trong speaker notes (`slides/src/content.mjs`).

## Luận điểm

Nhiều app có `glassEffect()` nhưng chạm vào không phản hồi gì. Bài đi qua **4 level** để thêm phản hồi, rồi ghép lại.

| Level | Nội dung | API chính |
|---|---|---|
| 1 | Phản hồi chạm | `.interactive()`, `sensoryFeedback` |
| 2 | Chuyển trạng thái | `GlassEffectContainer`, `glassEffectID` |
| 3 | Chuyển động vật lý | spring, `CustomAnimation` decay |
| 4 | Biến dạng tại điểm chạm | `layerEffect`, `distortionEffect` |

## Dòng thời gian

| Phút | Phần | Demo |
|---|---|---|
| 0:00–5:00 | Lộ trình · Level 1 | `1` |
| 5:00–17:00 | Level 2 | `2a` (live code) · `2b` |
| 17:00–25:00 | Level 3 | `3a` (bỏ phiếu) · `3b` |
| 25:00–33:00 | Level 4 | `4a` (live code) · `4b` |
| 33:00–39:00 | Tích hợp | `all` (live build) · `cp1`–`cp3` |
| 39:00–42:00 | Performance | `perf` |
| 42:00–45:00 | Lưu ý | `notes` |

## Điểm nhấn

- `2b`: bật từng lỗi cho morph mất. Hỏi: “Ai từng gặp lỗi này?”
- `3a`: bỏ phiếu spring hay ease.
- `all`: chiếu số dòng, “53 dòng”.
- `perf`: 50 phần tử trên Instruments.

---

## Phụ lục A. Một view, ba trạng thái (nội suy shape)

Cùng một view, đổi `frame` và `cornerRadius` theo state. Identity không đổi nên SwiftUI nội suy shape và glass morph theo. Nội dung đổi bằng `switch` thì **mỗi nhánh** cần `.transition` riêng; đặt `.transition` trên container chứa `switch` không có tác dụng. Code đầy đủ: `ShapeMorphDemo.swift` (demo `2a`, tab Đổi shape).

```swift
enum ShapeState { case circle, card, menu }

ZStack {
    switch state {
    case .circle: Image(systemName: "sparkles").transition(.opacity)
    case .card: Text("Chạm để mở menu").transition(.opacity)
    case .menu: MenuList().transition(.opacity)
    }
}
.frame(width: size.width, height: size.height)
.glassEffect(.regular.interactive(), in: .rect(cornerRadius: radius))
.sensoryFeedback(.impact, trigger: state)
```

## Phụ lục B. Nút "+" thêm và bớt nút (glassEffectID)

Code đầy đủ: struct `MorphMenu` trong `MorphMenu.swift` (demo `2a`, tab Thêm / bớt).

```swift
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
```

## Phụ lục C. Ripple shader tại điểm chạm

Code đầy đủ: hàm `ripple` trong `Shared/Shaders.metal` và `Ripple.swift` (demo `4a`, tab Ripple). Hai điểm khác bản phác thảo ban đầu:
- Chặn `normalize(0)` (ra NaN) khi chạm đúng tâm.
- Có wavefront lan ra từ điểm chạm, thay vì cả vùng gợn cùng lúc.

```swift
.layerEffect(
    ShaderLibrary.ripple(.float2(origin), .float(t), .float(amplitude), .float(frequency), .float(decay)),
    maxSampleOffset: CGSize(width: amplitude, height: amplitude),
    isEnabled: t > 0 && t < 1.5 // tắt shader khi sóng đã tắt
)
```

**Bẫy shader:**
- `layerEffect` trên `List` hiện biểu tượng cấm màu vàng; trên `ScrollView` nội dung trống (đã thử, simulator iOS 27.1). Chỉ áp lên view SwiftUI thuần.
- `position` tính bằng point, không phải pixel.
- `half` cho màu, `float` cho tọa độ.
- Shader compile lần đầu bị khựng. Gọi `Shader.compile(as:)` (iOS 18+) khi khởi động.
- Closure của `keyframeAnimator` là `@Sendable`: capture giá trị trước khi dùng.

---

## Phụ lục D. Checklist trước buổi nói

**Kiểm tra trên iPhone thật:**
- [ ] Haptic (`1`, `all`)
- [ ] Morph mượt (`2a`)
- [ ] `CoreMotion` và shader dưới glass (`4b`)
- [ ] Số đo Instruments cho `perf`, ghi rõ model máy

**Chuẩn bị:**
- [ ] iPhone qua cáp, không dùng simulator
- [ ] Video dự phòng cho `2a`, `4a`, `4b`, `all` (chạy `-autoplay YES`)
- [ ] Cài font trong `slides/fonts/` trên máy trình chiếu
- [ ] Chừa 2–3 phút đệm cho 3 đoạn live code (`2a`, `4a`, `all`)
