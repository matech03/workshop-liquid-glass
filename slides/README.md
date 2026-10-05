# Slide: Trải nghiệm người dùng xuất sắc với Liquid Glass

Bài có 5 phần: giới thiệu và component hệ thống, 4 level, cấu hình hệ thống, ví dụ, nguyên tắc.

| File | Dùng cho |
|---|---|
| `Trai-nghiem-Liquid-Glass.pptx` | Bản trình chiếu, theme sáng, 18 slide. Speaker notes có phần nói, thao tác demo, bẫy và file Xcode. |
| `src/content.mjs` | Nguồn duy nhất của nội dung slide và speaker notes. Sửa ở đây rồi build lại. |
| `fonts/` | Font của bản PowerPoint. Cài trên máy trình chiếu trước khi mở file. |
| `tools/` | Script build và xem trước. |

## Build lại

```sh
cd tools
npm install                                               # lần đầu
node build-pptx.mjs                                       # tạo ../Trai-nghiem-Liquid-Glass.pptx
node preview.mjs ../Trai-nghiem-Liquid-Glass.pptx /tmp/preview   # xuất PNG từng slide để kiểm tra
```

- `build-pptx.mjs` dựng slide bằng shape và text box gốc của PowerPoint, nên chữ tự xuống dòng và sửa được trực tiếp trong PowerPoint hoặc Keynote. Riêng nền bìa (`tools/cover-art.html`) được chụp bằng Google Chrome, vì PowerPoint không dựng được hiệu ứng glass.
- `preview.mjs` dùng Quick Look của macOS, không cần cài PowerPoint.

## Cấu trúc slide (18 slide)

Bìa · **Giới thiệu** (glass vs blur, component hệ thống) · **Level 1 → 4** · **Cấu hình** (người dùng, app) · **Ví dụ** (một trang tiêu đề, demo trong app) · **Nguyên tắc** (nguyên tắc cốt lõi, đo GPU) · Hỏi đáp.

- Mỗi level: 1 slide mở đầu (mục tiêu + 3 API), rồi 1–2 slide **Cách làm** / **Lỗi hay gặp**.
- Slide nội dung: trái là tiêu đề, một câu tóm tắt, các bước, hộp **Bẫy**; phải là 3 card keyword.
- Nhãn **DEMO** góc phải là khoá màn hình trong danh sách của app.
- Màu theo level: xanh dương (1), xanh lục (2), cam (3), hồng (4). Slide ngoài level dùng xanh dương.

Viết ngắn: tiêu đề ≤ 6 từ, tóm tắt một câu, card một câu. Trong `src/content.mjs`: `` `code` `` cho tên API, `**đậm**` để nhấn mạnh.
