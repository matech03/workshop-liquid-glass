# Trải nghiệm người dùng xuất sắc với Liquid Glass

Workshop 45 phút cho dev iOS. App demo: `LiquidGlassAdvanced/` (iOS 26.0+, iPhone, Swift 6, SwiftUI thuần).

## Slide outline

Mỗi slide: tiêu đề, một câu tóm tắt, 3 keyword, code (nếu có). Demo chạy trên app, không có slide riêng.

Nguồn: [HIG › Materials › Liquid Glass](https://developer.apple.com/design/human-interface-guidelines/materials#Liquid-Glass) · [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass).

### 0. Welcome

#### Trải nghiệm người dùng xuất sắc với Liquid Glass
Từ component hệ thống đến Metal shader.
- iOS 26+ · SwiftUI · Metal

### 1. Introduction

#### 1.1 Liquid Glass không phải blur
Glass **khúc xạ** nền và **đổi theo nền**. Blur chỉ làm mờ.
- Vai trò: glass là **lớp chức năng** (control, navigation) nổi trên nội dung; blur (standard materials) phân tách **bên trong lớp nội dung**.
- Khúc xạ: glass bẻ cong nội dung ở mép; blur chỉ làm nhoè.
- Thích ứng: glass tự sáng / tối theo nền bên dưới; blur là một mảng xám cố định.
- Highlight: glass có viền sáng và phản hồi khi chạm; blur phẳng.
- Scroll edge: nội dung mờ dần dưới thanh glass; blur cắt ngang.

#### 1.2 Component hệ thống có sẵn glass
Build bằng SDK mới là component chuẩn **tự có glass**: không cần `glassEffect`.

| Nhóm | Component (SwiftUI) |
|---|---|
| Navigation | `NavigationStack`, `NavigationSplitView`, `TabView` |
| Toolbar | `toolbar(content:)`, `ToolbarSpacer` |
| Menu | `Menu` |
| Sheet, popover | `.sheet`, `.popover`, `confirmationDialog` |
| Control | `Button`, `Toggle`, `Slider`, `Stepper`, `Picker`, `TextField` |
| Button style | `.glass`, `.glassProminent` |
| List, form | `List`, `Form` |
| Scroll edge | `safeAreaBar` |

- Bỏ nền tuỳ biến ở tab bar, toolbar, split view: nền tự vẽ che mất glass và scroll edge effect.
- Không hard-code kích thước control: để hệ thống áp dáng mới.

### 2. Implement Levels

#### 2.1 Level 1 · Interactive glass
Chạm là phải **thấy** và **cảm** được.
- `.regular` · `.clear`: regular cho nền bất kỳ và nhiều chữ (alert, sidebar, popover); clear chỉ trên nền nhiều hình ảnh (ảnh, video), nền sáng thì thêm lớp tối 35%.
- `.interactive()`: sáng lên, co giãn khi nhấn.
- `sensoryFeedback`: rung khi `trigger` đổi.
- `symbolEffect`: icon phản hồi theo chạm.

#### 2.2 Level 2 · Chuyển trạng thái
Đổi state thì **morph**, không nhảy.
- `GlassEffectContainer`: nhóm các glass morph với nhau.
- `glassEffectID(_:in:)`: nối glass cũ với glass mới.
- `withAnimation`: bọc thay đổi state.

#### 2.3 Level 3 · Chuyển động vật lý
Chuyển động **theo tay**, ngắt vẫn mượt.
- `spring`: giữ vận tốc khi bị ngắt.
- `predictedEndLocation`: điểm dừng dự đoán theo vận tốc.
- `.smooth` · `.snappy` · `.bouncy`: chọn spring theo tình huống.

#### 2.4 Level 4 · Metal shader
Một hàm nhỏ chạy trên GPU **cho từng pixel**, mỗi frame.
- Viết bằng Metal (`.metal`), đánh dấu `[[ stitchable ]]` để SwiftUI gọi được.
- Gọi từ SwiftUI qua `ShaderLibrary.tênHàm(tham số)`: không cần setup Metal.
- Chạy song song cho mọi pixel: hiệu ứng nặng vẫn mượt ở 120 Hz.

#### 2.5 Performance & lưu ý
Glass và shader vẽ trên GPU: **ít lớp, đúng chỗ, chỉ bật khi cần**.

Glass
- **Use Equatable Views**: SwiftUI bỏ qua `body` khi input không đổi.
- **Limit Glass Layers**: dùng `GlassEffectContainer` cho nhiều glass effect.
- **Strategic Interactive Effects**: `.interactive()` tăng CPU, chỉ bật cho phần tử nhận chạm.

Shader
- `isEnabled:`: bỏ shader khỏi pipeline khi không chạy.
- `Shader.compile(as:)`: compile lúc khởi động, tránh khựng lần đầu.
- `accessibilityReduceMotion`: tắt hiệu ứng chuyển động.

Dùng glass đúng chỗ
- Glass cho **lớp điều khiển nổi**, không dùng trong lớp nội dung. Ngoại lệ: slider, toggle chỉ thành glass khi đang được kéo.
- **Dùng tiết kiệm**: component hệ thống tự có glass; custom control chỉ áp cho phần tử chức năng quan trọng nhất.
- **Không glass trên glass**: glass không lấy mẫu glass khác, trông phẳng, đục.
```swift
GlassEffectContainer {
    ForEach(items) { item in
        ItemView(item: item).equatable()
            .glassEffect(item.isTappable ? .regular.interactive() : .regular)
    }
}

.layerEffect(shader, maxSampleOffset: offset, isEnabled: isActive && !reduceMotion)
```

### 3. Examples

### 4. Summary

#### 4.1 Nguyên tắc cốt lõi
Sáu điều kiểm tra **trước khi ship**.
1. Glass cho lớp điều khiển nổi, dùng tiết kiệm. **Không glass trên glass.**
2. Chạm là phản hồi: `.interactive()` + haptic, chỉ cho phần tử nhận chạm.
3. Cùng nhóm thì chung container. Đổi state trong `withAnimation`.
4. Chuyển động theo tay: spring giữ vận tốc, nhắm theo `predictedEndLocation`.
5. Shader dưới glass, tắt khi không chạy. Ít lớp glass, view nặng dùng `Equatable`.
6. Code tự viết tự đọc cài đặt người dùng. Kiểm tra glass với Clear / Tinted, Reduce Transparency, Increase Contrast.

> Mỗi phần tử Liquid Glass phải trả lời được: chạm vào thì phản hồi gì?

#### 4.2 Hỏi & đáp
Demo: LiquidGlassAdvanced

## Code trong app

| Màn | File |
|---|---|
| `0` | `00-Intro/GlassVsBlurDemo.swift` |
| `1` | `01-Level1-TouchFeedback/TouchFeedbackDemo.swift` |
| `2` | `02-Level2-StateTransition/Level2.swift`, `MorphMenu.swift` (live code), `ShapeMorphDemo.swift` |
| `3` | `03-Level3-Physics/Level3.swift`, `DragReleaseDemo.swift`, `SpringPresetsDemo.swift` |
| `4` | `04-Level4-Distortion/Level4.swift`, `ThreeModifiersDemo.swift` |
| `cfg` | `05-SystemSettings/SystemSettingsDemo.swift` |
| `photo` `arc` `match` `fx` | `06-Examples/` (`fx`: `ShaderEffectsDemo.swift`, `DistortionUnderGlassDemo.swift`, `Shared/Shaders.metal`) |

- **`Shared/`:** bảng màu (`Theme`), khung GOOD / BAD (`GoodBad`, `Compare`), menu chọn demo (`DemoTabs`), `ControlPanel`, `Backdrop`.
- **Thanh điều hướng và nút ⓘ:** đều là glass của hệ thống, không có dòng `glassEffect` nào.
