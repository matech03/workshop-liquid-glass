# Liquid Glass Advanced

App demo cho bài **"Trải nghiệm người dùng xuất sắc với Liquid Glass"**. Đi theo bài: giới thiệu → 4 level → cấu hình hệ thống → ví dụ. Phần nguyên tắc và performance chỉ có trên slide.

Mỗi demo so sánh chia đôi màn hình: **GOOD** ở trên, **BAD** ở dưới (hoặc hai style). Màn hình ít chữ: dòng code và hướng dẫn thao tác nằm trên slide và speaker notes.

Màu lấy từ `Shared/Theme.swift` (`Palette`). Nền mặc định tối, dịu (`Backdrop()`); demo cần nền nhiều màu dùng `Backdrop(style: .vivid)`.

- iOS 26.0+, iPhone, Swift 6, SwiftUI thuần
- Xcode 27.1 / iOS SDK 27.1: 0 lỗi, 0 cảnh báo

## Chạy

1. Mở `LiquidGlassAdvanced.xcodeproj`, chọn **Team** ở *Signing & Capabilities*.
2. Cắm iPhone, ⌘R.

Nút **⌃ / ⌄** góc phải để chuyển màn hình. Màn hình nhiều demo dùng tab.

Thanh điều hướng và nút ⌃ / ⌄ là glass của hệ thống, không có dòng `glassEffect` nào: dùng cho slide component hệ thống.

## Màn hình

Khoá ở cột đầu hiện trong danh sách của app, trùng nhãn **DEMO** trên slide.

| Khoá | Phần | Nội dung | File |
|---|---|---|---|
| `0` | Giới thiệu | Liquid Glass vs blur | `00-Intro/GlassVsBlurDemo.swift` |
| `1` | Level 1 | Tab: Highlight · Haptic | `01-Level1-TouchFeedback/TouchFeedbackDemo.swift` |
| `2a` | Level 2 | Tab: Hòa nhau · Thêm / bớt (**live code**) · Đổi shape | `02-Level2-StateTransition/Level2.swift` |
| `2b` | Level 2 | Tab: Khác container · Thiếu animatableData | `02-Level2-StateTransition/Level2.swift` |
| `3` | Level 3 | Tab: Bị ngắt (spring vs ease) · Thả tay (decay) | `03-Level3-Physics/Level3.swift` |
| `4` | Level 4 | Tab: 3 modifier (so với ảnh gốc) · Ripple | `04-Level4-Distortion/Level4.swift` |
| `cfg` | Cấu hình hệ thống | Trợ năng, sáng / tối | `05-SystemSettings/SystemSettingsDemo.swift` |
| `photo` | Ví dụ · thông dụng | Điều khiển trên ảnh, video: `.clear` + lớp làm tối | `06-Examples/PhotoControlsDemo.swift` |
| `arc` | Ví dụ · thông dụng | Menu cung tròn, hai style: quạt (`Layout`) · toả thẳng (`offset`) | `06-Examples/ArcMenu.swift` |
| `match` | Ví dụ · thông dụng | Tab: Sheet mọc ra từ nút · Hero (push màn chi tiết bằng `.zoom`) | `06-Examples/MatchedTransitionDemo.swift` |
| `lens` | Ví dụ · độc đáo | Hai style biến dạng: thấu kính (bọc nền) · dẻo (bọc cả nút) | `06-Examples/DistortionUnderGlassDemo.swift` |

`Shared/`: `Theme` (bảng màu), `GoodBad` / `Compare`, `DemoTabs`, `GlassCircle`, `Backdrop`, `ControlPanel`, ripple, warmup shader, `Shaders.metal`.

## Code trình bày

| Phần | Dòng | Cách trình bày |
|---|---|---|
| `MorphMenu.body` | 22 (gồm 2 dòng cho bản BAD) | **live code** |
| Shader `ripple()` | 12 | đọc code |
| `Decay: CustomAnimation` | 13 | đọc code |
| `ArcLayout` | 23 | đọc code |

## Đã kiểm tra (simulator iOS 27.1)

- `layerEffect` trên `List` / `ScrollView` không chạy. Trên `VStack` thuần: chạy đúng.
- `layerEffect` bọc cả cụm glass làm glass biến mất. `distortionEffect` bọc nút glass thì nút và chữ cong theo (`lens`, style dẻo).
- `matchedTransitionSource` + `.navigationTransition(.zoom)` chạy cho cả `.sheet` lẫn push trên `NavigationStack` (`match`).
- `.environment(\.colorScheme, …)` đổi được giao diện glass cho một phần màn hình (`cfg`).
- `UIDesignRequiresCompatibility = YES` vẫn có tác dụng. Key này **không** có trong project.

## Cần máy thật

- Haptic (`1`, `photo`, `match`, `lens`), highlight theo chuyển động của glass hệ thống.
- Cài đặt Liquid Glass Trong / Nhuộm màu (iOS 26.1+): không có API, đổi trong Cài đặt rồi xem lại `photo`, `cfg`.
