// Nội dung deck: nguồn duy nhất cho file pptx (tools/build-pptx.mjs).
// Cú pháp: `code` cho tên API, **đậm** để nhấn mạnh. Viết ngắn: mỗi dòng một ý.
// Slide nội dung: bên trái kicker, title, sum, rồi formula / steps / bullets / trap / quote; bên phải 3 card.
// `demo` là khoá màn hình trong app LiquidGlassAdvanced (`-demo KEY`), hiện ở góc phải trên.

export const TITLE = 'Trải nghiệm người dùng xuất sắc với Liquid Glass';
export const SECTIONS = ['Level 1', 'Level 2', 'Level 3', 'Level 4', 'Tích hợp', 'Performance', 'Lưu ý'];

export const SLIDES = [
  { id: 'bia', kind: 'cover',
    eyebrow: 'iOS 26+ · SwiftUI · Metal',
    lead: '4 level từ phản hồi chạm đến Metal shader.',
    meta: ['45 phút', 'Dev iOS', 'Demo: LiquidGlassAdvanced'] },

  { id: 'lo-trinh', kicker: 'Lộ trình',
    title: '4 level, rồi ghép lại',
    sum: 'Mỗi level thêm **một lớp phản hồi**.',
    steps: ['**Level 1** · Phản hồi chạm', '**Level 2** · Chuyển trạng thái', '**Level 3** · Chuyển động vật lý', '**Level 4** · Biến dạng tại điểm chạm'],
    cards: [['Tích hợp', 'Đủ 4 level trong 53 dòng.'], ['Performance', 'Đo GPU trên máy thật.'], ['Lưu ý', 'Glass vs blur, trợ năng, quy tắc ship.']] },

  // ---------- Level 1 ----------
  { id: 'l1', level: 1, kind: 'level', sec: 'Level 1',
    title: 'Phản hồi chạm',
    sum: 'Chạm là phải **thấy** và **cảm** được.',
    steps: ['Highlight khi nhấn', 'Haptic khi state đổi'],
    cards: [['.interactive()', 'Highlight cho view tự vẽ.'], ['.buttonStyle(.glass)', 'Button có sẵn.'], ['sensoryFeedback', 'Haptic theo state.']] },

  { id: 'l1-demo', level: 1, sec: 'Level 1', demo: '1', kicker: 'Level 1 · Cách làm',
    title: 'Highlight + haptic',
    sum: '**Thị giác**: sáng, co giãn. **Xúc giác**: rung khi state đổi.',
    bullets: ['Haptic theo nghĩa: `.selection`, `.impact`, `.success`'],
    trap: '`trigger` không đổi giá trị thì không rung.',
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
    steps: ['**Hòa nhau**: gap < `spacing`', '**Thêm / bớt**: `glassEffectID` cùng `@Namespace`', '**Đổi shape**: giữ identity, đổi `frame`'],
    cards: [['spacing', 'Khoảng cách bắt đầu hòa.'], ['glassEffectID(_:in:)', 'Chỉ cần khi thêm/bớt view.'], ['frame + cornerRadius', 'SwiftUI tự nội suy.']] },

  { id: 'l2-pitfall', level: 2, sec: 'Level 2', demo: '2b', kicker: 'Level 2 · Lỗi hay gặp',
    title: 'Morph hỏng, view không nội suy',
    sum: 'Thiếu một điều kiện là **view nhảy thẳng**.',
    steps: ['Khác container', 'Thiếu `withAnimation`', 'ID đổi theo state', '`if/else` đổi identity'],
    trap: '`glassEffect` trước `.frame`: sai kích thước, không phải lỗi morph.',
    cards: [['Cùng container', 'Morph trong một container.'], ['ID ổn định', 'Không đổi theo state.'], ['.transaction { print($0) }', 'Xem animation thực tế.']] },

  // ---------- Level 3 ----------
  { id: 'l3', level: 3, kind: 'level', sec: 'Level 3',
    title: 'Chuyển động vật lý',
    sum: 'Chuyển động **theo tay**, ngắt vẫn mượt.',
    steps: ['Spring khi bị ngắt', 'Decay khi thả tay', 'Animate theo cung'],
    cards: [['spring', 'Giữ vận tốc.'], ['CustomAnimation', 'Tự viết decay.'], ['Animatable Layout', 'Vị trí theo frame.']] },

  { id: 'l3-demo', level: 3, sec: 'Level 3', demo: '3a', kicker: 'Level 3 · Cách làm',
    title: 'Spring khi ngắt, decay khi thả',
    sum: '**Spring** giữ vận tốc. **Decay** trượt theo tay.',
    formula: 'đích = p₀ + v₀ / k · k ≈ 2 /s',
    bullets: ['Có đích: spring. Không đích: decay'],
    cards: [['shouldMerge', 'Spring đổi đích liền mạch.'], ['DragGesture.Value.velocity', 'Vận tốc lúc thả.'], ['CustomAnimation', '`animate`, `velocity`.']] },

  { id: 'l3-arc', level: 3, sec: 'Level 3', demo: '3b', kicker: 'Level 3 · Nâng cao',
    title: 'Menu cung tròn bằng Layout',
    sum: '`offset` đi **đường thẳng**. `Layout` đi **theo cung**.',
    bullets: ['Spring chạy trên `progress`'],
    cards: [['animatableData', 'Đưa `progress` vào đây.'], ['placeSubviews', 'Tính vị trí mỗi frame.'], ['KeyframeAnimator', 'Timeline cố định, không vận tốc.']] },

  // ---------- Level 4 ----------
  { id: 'l4', level: 4, kind: 'level', sec: 'Level 4',
    title: 'Biến dạng tại điểm chạm',
    sum: 'Nền **gợn sóng theo ngón tay** bằng Metal.',
    steps: ['3 shader modifier', 'Ripple tại điểm chạm', 'Méo nền dưới lớp glass'],
    cards: [['layerEffect', 'Đọc nhiều pixel.'], ['distortionEffect', 'Trả về vị trí nguồn.'], ['keyframeAnimator', 'Đưa thời gian vào shader.']] },

  { id: 'l4-demo', level: 4, sec: 'Level 4', demo: '4a', kicker: 'Level 4 · Cách làm',
    title: 'Shader modifier và ripple',
    sum: 'Shader là **hàm thuần**. Animation nằm ở Swift.',
    bullets: ['Input ripple: `origin`, `time`, amplitude', '`time` chạy 0 → 1,5 s'],
    trap: 'Không áp `layerEffect` lên `List`/`ScrollView`.',
    cards: [['colorEffect', 'Trả về màu mới.'], ['distortionEffect', 'Trả về vị trí nguồn.'], ['layerEffect', 'Gọi `layer.sample()`.']] },

  { id: 'l4-under', level: 4, sec: 'Level 4', demo: '4b', kicker: 'Level 4 · Lỗi hay gặp',
    title: 'Méo nền dưới lớp glass',
    sum: 'Đặt shader **dưới**: giữ highlight hệ thống.',
    bullets: ['Tâm méo đưa vào `animatableData`'],
    trap: 'Shader bọc cả nhóm glass: hiệu ứng biến mất.',
    cards: [['Dưới lớp glass', 'Viền, highlight vẫn đúng.'], ['animatableData', 'Tâm méo theo spring.'], ['TimelineView', '`time` liên tục.']] },

  // ---------- Tích hợp · Performance · Lưu ý ----------
  { id: 'integration', sec: 'Tích hợp', demo: 'all', kicker: 'Tích hợp',
    title: 'Đủ 4 level trong 53 dòng',
    sum: 'Mỗi level chỉ thêm **vài modifier**.',
    steps: ['Nền `MeshGradient`: 16 dòng', '+ kéo thả, spring: 28 dòng', '+ morph: 42 dòng', '+ highlight, haptic, ripple: **53 dòng**'],
    cards: [['Level 1 + 2', '`.interactive()`, `glassEffectID`.'], ['Level 3', '`DragGesture` + spring.'], ['Level 4', '`layerEffect` ripple.']] },

  { id: 'performance', sec: 'Performance', demo: 'perf', kicker: 'Performance',
    title: 'Đo GPU trên máy thật',
    sum: 'Glass vẽ trên GPU: **dùng Instruments**.',
    table: { head: ['Số phần tử', 'Riêng lẻ', 'Container', '+ layerEffect'], rows: [['5', '… ms', '… ms', '… ms'], ['20', '… ms', '… ms', '… ms'], ['50', '… ms', '… ms', '… ms']] },
    bullets: ['Ngân sách: 16,7 ms (60 Hz) · 8,3 ms (120 Hz)'],
    cards: [['Metal System Trace', 'GPU mỗi frame.'], ['Shader.compile(as:)', 'Tránh khựng lần đầu.'], ['isEnabled: false', 'Tắt shader khi không cần.']] },

  { id: 'notes', sec: 'Lưu ý', demo: 'notes', kicker: 'Lưu ý',
    title: '3 lưu ý trước khi ship',
    sum: 'Mỗi phần tử phải trả lời: **chạm vào thì phản hồi gì?**',
    trap: 'Glass không lấy mẫu glass: không chồng lớp lên nhau.',
    cards: [['Glass ≠ blur', 'Khúc xạ, highlight, đổi theo nền.'], ['Trợ năng', 'Shader tự viết phải tự tắt.'], ['Quy tắc ship', 'Container + ID + animation. Đo GPU.']] },

  { id: 'het', kind: 'end',
    title: 'Hỏi & đáp',
    lead: 'Demo **LiquidGlassAdvanced** · mở thẳng bằng `-demo KEY`' },
];

// Speaker notes: NÓI = nội dung trình bày, LÀM = thao tác demo, BẪY = lỗi hay gặp, XCODE = file mở trên màn hình.
export const NOTES = {
  bia: { do: ['Cắm iPhone, bật mirroring và Focus.', 'Mở LiquidGlassAdvanced, Xcode chia đôi màn hình.'] },
  'lo-trinh': { time: '0:00', say: ['Bài đi lần lượt 4 level, mỗi level thêm một lớp phản hồi.', 'Mỗi slide có khoá demo ở góc phải: mở app bằng `-demo KEY`.'] },

  l1: { time: '0:30', say: ['Level 1: mỗi lần chạm phải có phản hồi nhìn thấy và cảm nhận được.'] },
  'l1-demo': { time: '1:00–5:00', mode: 'Demo 1',
    say: ['`.buttonStyle(.glass)` có sẵn highlight. View tự vẽ cần `.glassEffect(.regular.interactive())`.', '`sensoryFeedback` phát khi giá trị `trigger` đổi, không phát theo cử chỉ.'],
    do: ['Bật/tắt `.interactive()`, đổi loại haptic.', 'Tắt “Chạm thì đổi trigger”: vẫn highlight nhưng mất haptic.'],
    trap: ['Haptic không chạy trên simulator.'], files: ['TouchFeedbackDemo'] },

  l2: { time: '5:00', say: ['Level 2: đổi state thì morph liền mạch, không nhảy thẳng.'] },
  'l2-demo': { time: '5:30–12:00', mode: 'Demo 2a · Live code tab Thêm / bớt',
    say: ['Hòa nhau: chung `GlassEffectContainer`, khoảng cách hai mép nhỏ hơn `spacing`.', 'Thêm/bớt: chung container, `glassEffectID` cùng `@Namespace`, state đổi trong `withAnimation`.', 'Đổi shape: cùng một view thì SwiftUI nội suy `frame` và `cornerRadius`, không cần ID.'],
    do: ['Tab Hòa nhau: kéo nút phải lại gần, chỉnh `spacing`.', 'Tab Thêm / bớt: live code body `MorphMenu` (20 dòng).', 'Tab Đổi shape: chạm qua `.circle` → `.card` → `.menu`.'],
    files: ['Level2', 'MorphMenu', 'BlendingDemo', 'ShapeMorphDemo'] },
  'l2-pitfall': { time: '12:00–17:00', mode: 'Demo 2b · Điểm nhấn',
    say: ['Morph hỏng: khác container, thiếu `withAnimation`, ID đổi theo state, khác `@Namespace`.', 'Không nội suy: `if/else` đổi identity, thiếu `animatableData`, `.animation` đặt sai chỗ, `Transaction` bị ghi đè.'],
    do: ['Tab Morph hỏng: bật lần lượt từng lỗi, chạm nút. Hỏi: “Ai từng gặp lỗi này?”', 'Tab Không nội suy: chạm từng ô, bật “Sửa”. Chạy `-logTransactions YES` để in transaction.'],
    files: ['BrokenMorphDemo', 'NoInterpolationDemo'] },

  l3: { time: '17:00', say: ['Level 3: chuyển động theo tay người dùng, bị ngắt giữa chừng vẫn mượt.'] },
  'l3-demo': { time: '17:30–23:00', mode: 'Demo 3a · Bỏ phiếu',
    say: ['Spring nhận vị trí và vận tốc hiện tại khi bị ngắt (`shouldMerge`). Timing curve cộng dồn nên chững lại.', 'Decay: Δ = v₀ / k để vận tốc đầu bằng vận tốc tay. k ≈ 2 /s như `UIScrollView`.'],
    do: ['Tab Spring vs Ease: bấm A, B liên tục, bỏ phiếu, rồi bật “Hiện nhãn”.', 'Tab Decay: kéo và thả với nhiều tốc độ. Chỉ vào struct `Decay` (13 dòng).'],
    files: ['Level3', 'SpringVsEaseDemo', 'Decay'] },
  'l3-arc': { time: '23:00–25:00', mode: 'Demo 3b · Đọc code',
    say: ['Đổi `offset`: nội suy x, y tuyến tính nên đi đường thẳng.', '`Layout` + `animatableData`: `placeSubviews` tính vị trí theo cung mỗi frame.'],
    do: ['Đổi Layout + spring với KeyframeAnimator, chạm + giữa chừng.'], files: ['ArcMenu'] },

  l4: { time: '25:00', say: ['Level 4: nền gợn sóng, méo theo ngón tay bằng Metal shader.'] },
  'l4-demo': { time: '25:30–31:00', mode: 'Demo 4a · Live code tab Ripple',
    say: ['`colorEffect` trả màu, `distortionEffect` trả vị trí nguồn, `layerEffect` đọc nhiều pixel.', 'Ripple: shader là hàm thuần; `keyframeAnimator` đưa `time` 0 → 1,5 s.', '`isEnabled` tắt shader khi sóng đã tắt.'],
    do: ['Tab 3 modifier: kéo slider.', 'Tab Ripple: live code `.metal` + `.layerEffect`, chạm nền.'],
    trap: ['Closure `keyframeAnimator` là `@Sendable`: capture `[origin]` trước.'], files: ['Level4', 'ThreeModifiersDemo', 'Ripple', 'Shaders.metal'] },
  'l4-under': { time: '31:00–33:00', mode: 'Demo 4b · Chạy thử trên máy thật trước',
    say: ['Đặt `distortionEffect` trên nền: glass khúc xạ nền đã méo, giữ viền và highlight.', 'Bọc cả nhóm glass: glass bị rasterize và biến mất (simulator iOS 27.1).'],
    do: ['Kéo vùng méo, đổi dưới/trên, nghiêng máy.'], files: ['DistortionUnderGlassDemo'] },

  integration: { time: '33:00–39:00', mode: 'Live build · Điểm nhấn',
    say: ['Chiếu số dòng: “Cả màn hình: 53 dòng.”'],
    do: ['Viết từ file trống. Lỗi thì mở `-demo cp1`, `cp2`, `cp3`.'], files: ['Checkpoint1', 'Checkpoint2', 'Checkpoint3', 'Finale'] },
  performance: { time: '39:00–42:00', mode: 'Instruments',
    say: ['Overlay chỉ đo main thread, không đo GPU.', 'Chỉ dùng số trên máy thật, ghi rõ model.'],
    do: ['Chọn 5, 20, 50 ở 3 chế độ. Mở Metal System Trace, Animation Hitches. Điền bảng.'], files: ['GlassStressDemo'] },
  notes: { time: '42:00–45:00', mode: 'Demo notes',
    say: ['Glass khúc xạ và đổi theo nền; Material chỉ blur + tint.', 'Glass hệ thống tự thích ứng trợ năng; shader tự viết phải đọc `@Environment` để tắt.', 'Câu chốt: “Mỗi phần tử Liquid Glass phải trả lời được: chạm vào thì phản hồi gì?”'],
    do: ['Tab Glass vs blur: bật “So với Material”.', 'Tab Trợ năng: bật Reduce Motion trong Cài đặt.', 'Tab Quy tắc: chạm để hiện từng quy tắc.'],
    files: ['Notes', 'GlassVariantsDemo', 'AccessibilityDemo', 'ShipRulesDemo'] },
  het: { time: '45:00', do: ['Mở link repo LiquidGlassAdvanced.'] },
};
