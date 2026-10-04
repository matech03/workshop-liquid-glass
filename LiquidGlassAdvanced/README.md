# Liquid Glass Advanced

App demo cho bài **"Trải nghiệm người dùng xuất sắc với Liquid Glass"**. Đi theo bài: 4 level → tích hợp → performance → lưu ý.

- iOS 26.0+, iPhone, Swift 6, SwiftUI thuần
- Xcode 27.1 / iOS SDK 27.1: 0 lỗi, 0 cảnh báo

## Chạy

1. Mở `LiquidGlassAdvanced.xcodeproj`, chọn **Team** ở *Signing & Capabilities*.
2. Cắm iPhone, ⌘R.

Mỗi màn hình có dòng hướng dẫn ở trên cùng. Nút **⌃ / ⌄** góc phải để chuyển màn hình. Màn hình nhiều demo dùng tab.

## Màn hình

Khoá ở cột đầu trùng nhãn **DEMO** trên slide.

| Khoá | Phần | Nội dung | File |
|---|---|---|---|
| `1` | Level 1 | Highlight + haptic | `01-Level1-TouchFeedback/TouchFeedbackDemo.swift` |
| `2a` | Level 2 | Tab: Hòa nhau · Thêm / bớt (**live code**) · Đổi shape | `02-Level2-StateTransition/Level2.swift` |
| `2b` | Level 2 | Tab: Morph hỏng · Không nội suy | `02-Level2-StateTransition/Level2.swift` |
| `3a` | Level 3 | Tab: Spring vs Ease · Decay (**live code**) | `03-Level3-Physics/Level3.swift` |
| `3b` | Level 3 | Menu cung tròn | `03-Level3-Physics/ArcMenu.swift` |
| `4a` | Level 4 | Tab: 3 modifier · Ripple (**live code**) | `04-Level4-Distortion/Level4.swift` |
| `4b` | Level 4 | Méo nền dưới lớp glass | `04-Level4-Distortion/DistortionUnderGlassDemo.swift` |
| `all` | Tích hợp | Đủ 4 level, 53 dòng (**live build**) | `05-Integration/Finale.swift` |
| `cp1`–`cp3` | Tích hợp | Checkpoint 16 / 28 / 42 dòng | `05-Integration/Checkpoint{1,2,3}.swift` |
| `perf` | Performance | 5 / 20 / 50 phần tử × 3 chế độ | `06-Performance/GlassStressDemo.swift` |
| `notes` | Lưu ý | Tab: Glass vs blur · Trợ năng · Quy tắc | `07-Notes/Notes.swift` |

`Shared/`: `GlassCircle`, `Backdrop`, `DemoTabs`, `ControlPanel`, ripple, warmup shader, đồng hồ frame time, `Shaders.metal`.

## Tham số khi chạy

*Edit Scheme → Run → Arguments*. Scheme có sẵn `-demo 2a`, `-autoplay YES`, `-logTransactions YES` (đều tắt).

| Tham số | Tác dụng |
|---|---|
| `-demo 2a` | Mở thẳng màn hình theo khoá |
| `-autoplay YES` | Demo tự chạy, để quay video dự phòng |
| `-meter YES` | Overlay frame time ở mọi màn hình |
| `-warmup NO` | Bỏ `Shader.compile(as:)`, để thấy hitch lần đầu |
| `-logTransactions YES` | In `Transaction` ở tab Không nội suy |
| `-above YES` | Màn `4b` mở sẵn chế độ shader bọc cả cụm glass |

```sh
xcrun simctl launch <UDID> com.example.LiquidGlassAdvanced -demo 4a -autoplay YES
```

## Số dòng live code

| Phần | Dòng |
|---|---|
| `MorphMenu.body` | 20 |
| Shader `ripple()` | 12 |
| `Decay: CustomAnimation` | 13 |
| `ArcLayout` | 23 |
| **`Finale.swift`** | **53** |
| Checkpoint 1 / 2 / 3 | 16 / 28 / 42 |

## Đã kiểm tra (simulator iOS 27.1)

- `layerEffect` trên `List` / `ScrollView` không chạy. Trên `VStack` thuần: chạy đúng.
- Shader bọc cả cụm glass làm glass biến mất. Vì vậy `perf` và `4b` đặt shader trên nền.
- `UIDesignRequiresCompatibility = YES` vẫn có tác dụng. Key này **không** có trong project.

## Cần máy thật

- Haptic, CoreMotion (`4b`), highlight theo chuyển động của glass hệ thống.
- Mọi số đo ở `perf`: lấy từ Instruments trên iPhone.
