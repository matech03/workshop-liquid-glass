// Nội dung deck: nguồn duy nhất cho file pptx (tools/build-pptx.mjs).
// Cú pháp: `code` cho tên API, **đậm** để nhấn mạnh. Viết ngắn: mỗi dòng một ý.
// Slide nội dung: bên trái kicker, title, sum, rồi goodbad / formula / steps / bullets / trap / quote; bên phải 3 card.
// goodbad: [['good' | 'bad', 'code'], ...] khớp nửa trên / nửa dưới của màn hình demo.
// `demo` là khoá màn hình trong danh sách của app LiquidGlassAdvanced, hiện ở góc phải trên.

export const TITLE = 'Trải nghiệm người dùng xuất sắc với Liquid Glass';
export const SECTIONS = ['Giới thiệu', 'Level 1', 'Level 2', 'Level 3', 'Level 4', 'Cấu hình', 'Ví dụ', 'Nguyên tắc'];

export const SLIDES = [
  { id: 'bia', kind: 'cover',
    eyebrow: 'iOS 26+ · SwiftUI · Metal',
    lead: 'Từ component hệ thống đến Metal shader.',
    meta: ['45 phút', 'Dev iOS', 'Demo: LiquidGlassAdvanced'] },

  // ---------- Giới thiệu ----------
  { id: 'intro', sec: 'Giới thiệu', demo: '0', kicker: 'Giới thiệu',
    title: 'Liquid Glass không phải blur',
    sum: 'Glass **khúc xạ** nền và **đổi theo nền**. Blur chỉ làm mờ.',
    goodbad: [['good', '.glassEffect(.regular)'], ['bad', '.background(.ultraThinMaterial)']],
    trap: 'Glass không lấy mẫu glass: không chồng lớp lên nhau.',
    cards: [['.regular', 'Mặc định, tự thích ứng.'], ['.clear', 'Trong hơn, cần nền tối.'], ['.identity', 'Tắt glass có điều kiện.']] },

  { id: 'he-thong', sec: 'Giới thiệu', kicker: 'Giới thiệu · Component hệ thống',
    title: 'Component hệ thống có sẵn glass',
    sum: 'Build bằng SDK 26 là thanh điều hướng, tab bar, sheet **tự có glass**.',
    steps: ['**Tự có**: `TabView`, toolbar, `.sheet`, `Menu`, `.searchable`', '**Tuỳ biến** toolbar: `ToolbarSpacer`, `sharedBackgroundVisibility`', '**Tuỳ biến** tab bar: `tabBarMinimizeBehavior`, `tabViewBottomAccessory`', '**Tự vẽ**: `glassEffect`, `GlassEffectContainer`, `.buttonStyle(.glass)`'],
    trap: 'Không thêm `glassEffect` lên toolbar, tab bar: thành glass chồng glass.',
    cards: [['Tự có', 'Build bằng SDK 26 là có, không cần code.'], ['Tuỳ biến', 'Gom, tách, thu nhỏ. Nền tràn dưới sidebar: `backgroundExtensionEffect`.'], ['Tự vẽ', 'Chỉ cho control riêng của app. UIKit: `UIGlassEffect`.']] },

  // ---------- Level 1 ----------
  { id: 'l1', level: 1, kind: 'level', sec: 'Level 1',
    title: 'Phản hồi chạm',
    sum: 'Chạm là phải **thấy** và **cảm** được.',
    steps: ['Highlight khi nhấn', 'Haptic khi state đổi'],
    cards: [['.interactive()', 'Highlight cho view tự vẽ.'], ['.buttonStyle(.glass)', 'Button có sẵn.'], ['sensoryFeedback', 'Haptic theo state.']] },

  { id: 'l1-demo', level: 1, sec: 'Level 1', demo: '1', kicker: 'Level 1 · Cách làm',
    title: 'Highlight + haptic',
    sum: '**Thị giác**: sáng, co giãn. **Xúc giác**: rung khi state đổi.',
    goodbad: [['good', '`.glassEffect(.regular.interactive())`'], ['bad', '`.glassEffect(.regular)`'], ['good', 'trigger: `count += 1`'], ['bad', 'trigger: `liked = true` lặp lại']],
    cards: [['.glassEffect(.regular.interactive())', 'View tự vẽ.'], ['.buttonStyle(.glass)', 'Không cần thêm gì.'], ['sensoryFeedback(_:trigger:)', 'Phát khi `trigger` đổi.']] },

  // ---------- Level 2 ----------
  { id: 'l2', level: 2, kind: 'level', sec: 'Level 2',
    title: 'Chuyển trạng thái',
    sum: 'Đổi state thì **morph**, không nhảy.',
    steps: ['Hòa nhau', 'Thêm / bớt', 'Đổi shape'],
    cards: [['GlassEffectContainer', 'Nhóm phần tử morph.'], ['glassEffectID', 'Nối cũ với mới.'], ['withAnimation', 'Bọc thay đổi state.']] },

  { id: 'l2-demo', level: 2, sec: 'Level 2', demo: '2a', kicker: 'Level 2 · Cách làm',
    title: 'Ba kiểu morph',
    sum: 'Thêm/bớt cần **container + ID + animation**.',
    goodbad: [['good', 'Hòa nhau: chung `GlassEffectContainer`'], ['good', 'Thêm / bớt: `glassEffectID` + `withAnimation`'], ['good', 'Đổi shape: một view, đổi `frame`'], ['bad', '`if/else` hai view: chỉ fade']],
    cards: [['spacing', 'Khoảng cách bắt đầu hòa.'], ['glassEffectID(_:in:)', 'Chỉ cần khi thêm/bớt view.'], ['frame + cornerRadius', 'SwiftUI tự nội suy.']] },

  { id: 'l2-pitfall', level: 2, sec: 'Level 2', demo: '2b', kicker: 'Level 2 · Lỗi hay gặp',
    title: 'Hai lỗi hay gặp nhất',
    sum: 'Thiếu một điều kiện là **view nhảy thẳng**.',
    goodbad: [['good', 'một container cho cả nhóm'], ['bad', 'mỗi nút tự bọc container'], ['good', '`var animatableData { progress }`'], ['bad', 'Shape thiếu `animatableData`']],
    trap: '`glassEffect` trước `.frame`: sai kích thước, không phải lỗi morph.',
    cards: [['Cùng container', 'Morph trong một container.'], ['@Animatable', 'Khai báo giá trị cần nội suy.'], ['ID ổn định', 'Không đổi theo state.']] },

  // ---------- Level 3 ----------
  { id: 'l3', level: 3, kind: 'level', sec: 'Level 3',
    title: 'Chuyển động vật lý',
    sum: 'Chuyển động **theo tay**, ngắt vẫn mượt.',
    steps: ['Spring khi bị ngắt', 'Decay khi thả tay'],
    cards: [['spring', 'Giữ vận tốc khi bị ngắt.'], ['CustomAnimation', 'Tự viết decay.'], ['Value.velocity', 'Vận tốc lúc thả tay.']] },

  { id: 'l3-demo', level: 3, sec: 'Level 3', demo: '3', kicker: 'Level 3 · Cách làm',
    title: 'Spring khi ngắt, decay khi thả',
    sum: '**Spring** giữ vận tốc. **Decay** trượt theo tay.',
    goodbad: [['good', '`.spring(duration: 0.8, bounce: 0)`'], ['bad', '`.easeInOut(duration: 0.8)`'], ['good', 'thả tay: `Decay(k: 2)`'], ['bad', 'thả tay: dừng tại chỗ']],
    formula: 'đích = p₀ + v₀ / k · k ≈ 2 /s',
    cards: [['shouldMerge', 'Spring đổi đích liền mạch.'], ['DragGesture.Value.velocity', 'Vận tốc lúc thả.'], ['CustomAnimation', '`animate`, `velocity`.']] },

  // ---------- Level 4 ----------
  { id: 'l4', level: 4, kind: 'level', sec: 'Level 4',
    title: 'Biến dạng tại điểm chạm',
    sum: 'Nền **gợn sóng theo ngón tay** bằng Metal.',
    steps: ['3 shader modifier', 'Ripple tại điểm chạm', 'Tắt shader khi không chạy'],
    cards: [['layerEffect', 'Đọc nhiều pixel.'], ['distortionEffect', 'Trả về vị trí nguồn.'], ['keyframeAnimator', 'Đưa thời gian vào shader.']] },

  { id: 'l4-demo', level: 4, sec: 'Level 4', demo: '4', kicker: 'Level 4 · Cách làm',
    title: 'Shader modifier và ripple',
    sum: 'So với ảnh gốc: **đổi màu**, **dời pixel**, **trộn pixel**.',
    goodbad: [['good', 'ripple: `isEnabled: t > 0 && t < 1.5`'], ['bad', 'ripple: `layerEffect` luôn bật']],
    trap: 'Không áp `layerEffect` lên `List`/`ScrollView`.',
    cards: [['colorEffect', 'Đổi màu, hình giữ nguyên.'], ['distortionEffect', 'Dời pixel, màu giữ nguyên.'], ['layerEffect', 'Trộn nhiều pixel.']] },

  // ---------- Cấu hình hệ thống ----------
  { id: 'cfg-user', sec: 'Cấu hình', demo: 'cfg', kicker: 'Cấu hình · Người dùng',
    title: 'Glass theo cài đặt người dùng',
    sum: 'Glass hệ thống **tự thích ứng**. Code tự viết phải **tự đọc** `@Environment`.',
    steps: ['**Giảm độ trong suốt**: glass đục hơn', '**Tăng độ tương phản**: viền rõ hơn', '**Giảm chuyển động**: bỏ nảy, tắt ripple', '**Sáng / Tối**: glass đổi theo giao diện', '**Trong / Nhuộm màu** (iOS 26.1+): không có API'],
    trap: 'Hệ thống chỉ lo glass của hệ thống. Shader, spring tự viết phải tự đọc cài đặt.',
    cards: [['accessibilityReduceTransparency', '`.regular` thành nền đặc.'], ['colorSchemeContrast', 'Tăng viền.'], ['accessibilityReduceMotion', 'Tắt ripple, bỏ nảy.']] },

  { id: 'cfg-app', sec: 'Cấu hình', kicker: 'Cấu hình · App',
    title: 'Cấu hình của app',
    sum: 'App quyết định **có glass hay không** và **chạy ở bao nhiêu Hz**.',
    bullets: ['`UIDesignRequiresCompatibility = YES` (Info.plist): giữ giao diện cũ khi build bằng SDK 26', 'Target dưới iOS 26: gói `#available` trong một `ViewModifier`, fallback `Material`', '`CADisableMinimumFrameDurationOnPhone`: cho phép 120 Hz trên ProMotion'],
    trap: 'Key compatibility chỉ là tạm thời. SDK 27.1 vẫn chạy: kiểm tra lại với mỗi SDK mới.',
    cards: [['UIDesignRequiresCompatibility', 'Tạm hoãn Liquid Glass.'], ['#available(iOS 26, *)', 'Một modifier, không rải khắp nơi.'], ['CADisableMinimumFrameDurationOnPhone', '120 Hz cho animation tự viết.']] },

  // ---------- Ví dụ ----------
  { id: 'vi-du', kind: 'section', sec: 'Ví dụ', title: 'Ví dụ' },

  // ---------- Nguyên tắc ----------
  { id: 'nguyen-tac', sec: 'Nguyên tắc', kicker: 'Nguyên tắc',
    title: 'Nguyên tắc cốt lõi',
    sum: 'Sáu điều kiểm tra **trước khi ship**.',
    steps: ['Glass cho lớp điều khiển nổi. **Không glass trên glass.**', 'Chạm là phản hồi: `.interactive()` + haptic theo state.', 'Cùng nhóm thì chung container. Đổi state: `withAnimation`.', 'Chuyển động theo tay: spring giữ vận tốc.', 'Shader đặt dưới glass, tắt khi không chạy.', 'Code tự viết tự đọc cài đặt. **Đo GPU trên máy thật.**'],
    quote: 'Mỗi phần tử Liquid Glass phải trả lời được: chạm vào thì phản hồi gì?',
    cards: [['Dùng đúng chỗ', 'Glass nổi trên nội dung, không thay nội dung.'], ['Phản hồi cộng dồn', 'Mỗi level thêm một lớp, không bỏ lớp trước.'], ['Đo, không đoán', 'Instruments trên iPhone thật.']] },

  { id: 'performance', sec: 'Nguyên tắc', kicker: 'Nguyên tắc · Đo, không đoán',
    title: 'Đo GPU trên máy thật',
    sum: 'Glass vẽ trên GPU: **dùng Instruments**, không đoán.',
    bullets: ['Ngân sách: 16,7 ms (60 Hz) · 8,3 ms (120 Hz)', 'Nhiều phần tử glass: gom chung `GlassEffectContainer`', 'Shader: `isEnabled: false` khi không chạy, compile trước lúc khởi động', 'Đo trên iPhone thật, ghi rõ model: simulator không phản ánh GPU'],
    cards: [['Metal System Trace', 'GPU mỗi frame.'], ['Shader.compile(as:)', 'Tránh khựng lần đầu.'], ['isEnabled: false', 'Tắt shader khi không cần.']] },

  { id: 'het', kind: 'end',
    title: 'Hỏi & đáp',
    lead: 'Demo **LiquidGlassAdvanced**' },
];

// Speaker notes: NÓI = nội dung trình bày, LÀM = thao tác demo, BẪY = lỗi hay gặp, XCODE = file mở trên màn hình.
export const NOTES = {
  bia: { do: ['Cắm iPhone, bật mirroring và Focus.', 'Mở LiquidGlassAdvanced, Xcode chia đôi màn hình.'] },
  intro: { time: '0:00–3:00', mode: 'Demo 0',
    say: ['Liquid Glass khúc xạ nội dung bên dưới, có highlight và tự đổi độ sáng theo nền.', 'Material (blur + tint) chỉ làm mờ và phủ màu.', 'Glass không lấy mẫu glass khác: không chồng lớp lên nhau.'],
    do: ['Thanh nằm sẵn trên chữ “Aa” và dải màu ở nền sáng: so mép thanh glass (chữ và dải màu bị bẻ cong) với blur (chỉ nhoè).', 'Kéo thanh sang nền tối ở cả hai nửa: glass tự tối lại theo nền, blur vẫn là mảng xám.'], files: ['GlassVsBlurDemo'] },
  'he-thong': { time: '3:00–5:00', mode: 'Chỉ vào thanh điều hướng của app',
    say: ['Build bằng SDK 26: `TabView`, toolbar, sheet, `Menu`, thanh tìm kiếm tự đổi sang Liquid Glass, không sửa code.', 'Phần lớn app chỉ cần tuỳ biến: tách nhóm nút bằng `ToolbarSpacer`, thu nhỏ tab bar khi cuộn, mini player bằng `tabViewBottomAccessory`.', 'Chỉ tự vẽ `glassEffect` cho control riêng của app. Phần còn lại của bài nói về phần này.'],
    do: ['Chỉ vào nút back và ⌃ ⌄ của app demo: glass hệ thống, không có dòng `glassEffect` nào.'],
    trap: ['Thêm `glassEffect` lên toolbar có sẵn là glass chồng glass.'], files: ['DemoCatalog'] },

  l1: { time: '5:00', say: ['Level 1: mỗi lần chạm phải có phản hồi nhìn thấy và cảm nhận được.'] },
  'l1-demo': { time: '5:30–8:00', mode: 'Demo 1',
    say: ['`.buttonStyle(.glass)` có sẵn highlight. View tự vẽ cần `.glassEffect(.regular.interactive())`.', '`sensoryFeedback` phát khi giá trị `trigger` đổi, không phát theo cử chỉ.'],
    do: ['Tab Highlight: chạm nút trên (GOOD) rồi nút dưới (BAD).', 'Tab Haptic: chạm liên tục. Số dưới nút là “số lần chạm · giá trị trigger”: BAD đứng yên ở true nên chỉ rung lần đầu.'],
    trap: ['Haptic không chạy trên simulator.'], files: ['TouchFeedbackDemo'] },

  l2: { time: '8:00', say: ['Level 2: đổi state thì morph liền mạch, không nhảy thẳng.'] },
  'l2-demo': { time: '8:30–12:30', mode: 'Demo 2a · Live code tab Thêm / bớt',
    say: ['Hòa nhau: chung `GlassEffectContainer`, khoảng cách hai mép nhỏ hơn `spacing`.', 'Thêm/bớt: chung container, `glassEffectID` cùng `@Namespace`, state đổi trong `withAnimation`.', 'Đổi shape: cùng một view thì SwiftUI nội suy `frame` và `cornerRadius`, không cần ID.'],
    do: ['Tab Hòa nhau: BAD hai container, không bao giờ hòa.', 'Tab Thêm / bớt: live code `MorphMenu`; BAD bỏ ID và `withAnimation`.', 'Tab Đổi shape: BAD dùng `if/else`, chỉ fade.'],
    files: ['Level2', 'MorphMenu', 'ShapeMorphDemo'] },
  'l2-pitfall': { time: '12:30–15:00', mode: 'Demo 2b · Điểm nhấn',
    say: ['Morph hỏng hay gặp nhất: mỗi nút tự bọc container riêng. Các lỗi khác: thiếu `withAnimation`, ID đổi theo state, khác `@Namespace`.', 'Shape tự viết thiếu `animatableData`: SwiftUI không có giá trị trung gian, path nhảy thẳng.'],
    do: ['Tab Khác container: hỏi “Ai từng gặp lỗi này?”', 'Tab Thiếu animatableData: so cung tròn trên và dưới.'],
    files: ['Level2'] },

  l3: { time: '15:00', say: ['Level 3: chuyển động theo tay người dùng, bị ngắt giữa chừng vẫn mượt.'] },
  'l3-demo': { time: '15:30–19:00', mode: 'Demo 3 · Đọc code Decay',
    say: ['Spring nhận vị trí và vận tốc hiện tại khi bị ngắt (`shouldMerge`), nên quay đầu ngay theo lệnh mới. Timing curve không merge: animation cũ vẫn chạy nốt và cộng dồn với animation mới, nên nút trôi tiếp về phía cũ rồi mới quay.', 'Decay: Δ = v₀ / k để vận tốc đầu bằng vận tốc tay. k ≈ 2 /s như `UIScrollView`.'],
    do: ['Tab Bị ngắt: mỗi chu kỳ nút chạy sang phải, 0,35 s sau bị gọi về. Vệt bên dưới là đường đi, chấm trắng là lúc bị ngắt. GOOD quay đầu ngay tại chấm; BAD còn trôi tiếp một đoạn rồi mới quay. Chạm vào làn để tự ngắt.', 'Tab Thả tay: kéo thả mạnh; BAD dừng tại chỗ. Chỉ vào struct `Decay` (13 dòng).'],
    files: ['Level3', 'Decay'] },

  l4: { time: '19:00', say: ['Level 4: nền gợn sóng, méo theo ngón tay bằng Metal shader.'] },
  'l4-demo': { time: '19:30–23:00', mode: 'Demo 4 · Đọc code tab Ripple',
    say: ['So với ảnh gốc: `colorEffect` chỉ đổi màu (lưới vẫn thẳng), `distortionEffect` chỉ dời pixel (lưới lượn sóng, màu giữ nguyên), `layerEffect` trộn nhiều pixel (tách kênh màu ở mép chữ).', 'Ripple: shader là hàm thuần; `keyframeAnimator` đưa `time` 0 → 1,5 s.', 'GOOD: `isEnabled` tắt shader khi sóng xong. BAD: shader chạy mãi.'],
    do: ['Tab 3 modifier: kéo slider cường độ về 0 rồi lên 100%.', 'Tab Ripple: đọc `ripple()` trong `.metal` và `.layerEffect`; nhìn icon tia sét ở góc: sáng khi shader đang chạy, mờ khi đã tắt.'],
    trap: ['Closure `keyframeAnimator` là `@Sendable`: capture `[origin]` trước.'], files: ['Level4', 'ThreeModifiersDemo', 'Ripple', 'Shaders.metal'] },

  'cfg-user': { time: '23:00–26:00', mode: 'Demo cfg',
    say: ['Glass hệ thống tự đổi theo Giảm độ trong suốt, Tăng độ tương phản, sáng / tối. Không cần code.', 'Shader và spring tự viết thì không: đọc `@Environment` rồi tự tắt. `RippleOnTap` tắt `layerEffect` khi bật Giảm chuyển động.', 'iOS 26.1 có thêm lựa chọn Trong / Nhuộm màu. Không có API đọc lựa chọn này: kiểm tra giao diện ở cả hai.'],
    do: ['Đổi icon trăng / mặt trời ở cuối màn hình để so glass sáng và tối.', 'Bật Giảm độ trong suốt và Giảm chuyển động trong Cài đặt, quay lại app, chạm nền.'],
    files: ['SystemSettingsDemo', 'RippleModifier'] },
  'cfg-app': { time: '26:00–28:00', mode: 'Đọc Info.plist',
    say: ['`UIDesignRequiresCompatibility = YES`: build bằng SDK 26 mà vẫn giữ giao diện cũ. Đã thử trên SDK 27.1: vẫn có tác dụng.', 'App còn hỗ trợ iOS cũ: gói `#available` trong một `ViewModifier`, fallback `Material`.', 'Không có `CADisableMinimumFrameDurationOnPhone` thì `CADisplayLink` và animation tự viết tối đa 60 Hz trên iPhone.'],
    trap: ['Apple nói key compatibility chỉ là tạm thời: không dựa vào lâu dài.'], files: ['Info.plist', 'SystemSettingsDemo'] },

  'vi-du': { time: '28:00–38:00', mode: 'Demo photo → arc → match → lens (nút ⌄ để chuyển)',
    say: ['photo: `.clear` cho nền nhiều hình ảnh, luôn kèm lớp `LinearGradient` làm tối phía sau nút.',
      'arc: hai style cùng vị trí cuối. Quạt: `Layout` + `animatableData`, nút quét theo cung. Toả thẳng: `offset` + delay lần lượt, nút bắn thẳng ra từ tâm.',
      'match: `matchedTransitionSource` + `.navigationTransition(.zoom)`, dùng cho cả sheet lẫn push. `matchedGeometryEffect` chỉ trong cùng một màn.',
      'lens: cùng shader, hai style. Thấu kính bọc nền, glass giữ hình. Dẻo bọc cả nút, chỉ biến dạng lúc kéo.'],
    do: ['photo: chờ mây trôi qua nút ở nửa BAD.', 'arc: chạm nút + ở hai nửa, so đường đi: cung tròn và đường thẳng.', 'match: tab Sheet chạm nút soạn bài rồi nút lọc; tab Hero chạm thẻ rồi vuốt back.', 'lens: kéo thấu kính; kéo ở mép nút dẻo rồi thả.'],
    files: ['PhotoControlsDemo', 'ArcMenu', 'MatchedTransitionDemo', 'DistortionUnderGlassDemo'] },

  'nguyen-tac': { time: '38:00–40:30',
    say: ['Mỗi nguyên tắc gắn với một phần đã demo: 1 → `0`, `photo` · 2 → Level 1 · 3 → Level 2 · 4 → Level 3 · 5 → Level 4, `lens` · 6 → `cfg`, slide tiếp theo.', 'Câu chốt: “Mỗi phần tử Liquid Glass phải trả lời được: chạm vào thì phản hồi gì?”'] },
  performance: { time: '40:30–43:00', mode: 'Chỉ nói, không demo',
    say: ['Glass do render server vẽ trên GPU. Time Profiler và các đồng hồ đo trên main thread không thấy được phần này.', 'Instruments: Metal System Trace cho thời gian GPU mỗi frame, Animation Hitches cho các frame trễ.', 'Hai việc rẻ nhất: gom glass vào chung `GlassEffectContainer`, tắt shader bằng `isEnabled` khi không chạy. `Shader.compile(as:)` lúc khởi động để tránh khựng lần đầu.', 'Chỉ dùng số đo trên máy thật, ghi rõ model.'] },
  het: { time: '43:00–45:00', do: ['Mở link repo LiquidGlassAdvanced.'] },
};
