#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// Kiểu dữ liệu: half cho màu (đủ chính xác, nhanh hơn trên GPU Apple),
// float cho tọa độ. half chỉ biểu diễn chính xác số nguyên tới 2048, không đủ cho tọa độ pixel.

// MARK: - Level 4 · Ba modifier, ba signature

// colorEffect: nhận vị trí + màu hiện tại, trả về màu mới của pixel.
[[ stitchable ]]
half4 duotone(float2 position, half4 color, half4 dark, half4 light) {
    half luma = dot(color.rgb, half3(0.299h, 0.587h, 0.114h));
    return half4(mix(dark.rgb, light.rgb, luma) * color.a, color.a); // màu premultiplied
}

// distortionEffect: chỉ nhận vị trí, trả về tọa độ NGUỒN để lấy mẫu (lấy pixel từ đâu),
// không phải đích đến của pixel. Màu không đổi, chỉ hình dạng đổi.
[[ stitchable ]]
float2 wave(float2 position, float amplitude) {
    return position + float2(sin(position.y * 0.08) * amplitude, 0.0);
}

// layerEffect: nhận cả layer, gọi layer.sample() bao nhiêu lần tùy ý, trả về màu.
[[ stitchable ]]
half4 chromatic(float2 position, SwiftUI::Layer layer, float amount) {
    half4 r = layer.sample(position + float2(amount, 0.0));
    half4 g = layer.sample(position);
    half4 b = layer.sample(position - float2(amount, 0.0));
    return half4(r.r, g.g, b.b, max(max(r.a, g.a), b.a));
}

// MARK: - Ví dụ · Shader effects: ripple tại điểm chạm

[[ stitchable ]]
half4 ripple(float2 position, SwiftUI::Layer layer, float2 origin, float time,
             float amplitude, float frequency, float decay) {
    float d = distance(position, origin);
    float wave = sin(d * frequency - time * 12.0);              // sóng sin lan ra ngoài theo thời gian
    float fade = exp(-d * 0.01) * exp(-time * decay);           // suy giảm theo khoảng cách và thời gian
    float front = saturate((time * 600.0 - d) / 80.0);          // mặt sóng lan từ origin với tốc độ 600 pt/s
    float offset = amplitude * wave * fade * front;             // |offset| ≤ amplitude = maxSampleOffset
    float2 dir = d > 0.0 ? (position - origin) / d : float2(0.0); // tránh NaN ngay tại tâm
    half4 color = layer.sample(position + dir * offset);
    color.rgb += half(0.2 * offset / max(amplitude, 1.0)) * color.a; // tăng sáng tại đỉnh sóng
    return color;
}

// MARK: - Ví dụ · Shader effects: Lens, Jelly (biến dạng nền dưới glass)

[[ stitchable ]]
float2 fingerWarp(float2 position, float2 center, float radius, float strength, float time) {
    float2 d = position - center;
    float k = exp(-dot(d, d) / (radius * radius));            // trọng số Gauss theo khoảng cách tới tâm
    float wobble = sin(length(d) * 0.045 - time * 2.5) * 12.0 * k * strength; // strength = 0: không méo gì
    return position - d * k * strength + wobble;               // lấy mẫu gần tâm hơn → phóng to vùng quanh tâm
}

// MARK: - Ví dụ · Shader effects: các hiệu ứng khác
// Ý tưởng từ krispuckett/SwiftUIShaders (MIT), viết lại gọn cho demo.

// Vortex (distortionEffect): xoắn nền quanh ngón tay. Mạnh nhất ở tâm, về 0 ở mép bán kính.
[[ stitchable ]]
float2 vortex(float2 position, float2 center, float radius, float twist) {
    float2 d = position - center;
    float k = saturate(1.0 - length(d) / radius);
    float a = twist * k * k;
    float s = sin(a), c = cos(a);
    return center + float2(c * d.x - s * d.y, s * d.x + c * d.y);
}

// Pixelate (layerEffect): một vòng ô vuông lan ra từ điểm chạm rồi tan dần.
[[ stitchable ]]
half4 pixelBurst(float2 position, SwiftUI::Layer layer, float2 origin, float time, float maxSize) {
    float d = distance(position, origin);
    float ring = saturate(1.0 - abs(d - time * 500.0) / 180.0);                    // vòng lan 500 pt/s, dày 180 pt
    float size = floor(maxSize * ring * (1.0 - saturate(time / 1.2)) / 4.0) * 4.0; // bậc 4 pt cho ô vuông rõ
    if (size < 4.0) { return layer.sample(position); }
    return layer.sample((floor(position / size) + 0.5) * size);                    // lấy màu ở tâm ô: |dời| ≤ maxSize / 2
}

static float glitchHash(float n) { return fract(sin(n) * 43758.5453); }

// Glitch (layerEffect): các dải ngang bị xô lệch, tách kênh màu, tắt dần sau 0,6 s.
[[ stitchable ]]
half4 glitch(float2 position, SwiftUI::Layer layer, float time, float intensity) {
    float strength = intensity * (1.0 - saturate(time / 0.6));
    float row = floor(position.y / 18.0);
    float seed = floor(time * 20.0);                                                // đổi dải bị lệch 20 lần mỗi giây
    float shift = glitchHash(row * 13.1 + seed) > 0.7 ? (glitchHash(row + seed * 7.3) - 0.5) * 80.0 * strength : 0.0;
    float2 p = position + float2(shift, 0.0);
    float split = 8.0 * strength;
    half4 r = layer.sample(p + float2(split, 0.0));
    half4 g = layer.sample(p);
    half4 b = layer.sample(p - float2(split, 0.0));
    return half4(r.r, g.g, b.b, max(max(r.a, g.a), b.a));
}

// Thermal (colorEffect): vùng quanh ngón tay đổi sang bảng màu camera nhiệt.
// Nhiệt = độ sáng của pixel cộng với nhiệt toả ra từ ngón tay: tâm nóng (trắng, vàng), xa dần lạnh (đỏ, tím, xanh).
[[ stitchable ]]
half4 thermal(float2 position, half4 color, float2 touch, float radius, float strength) {
    float luma = dot(float3(color.rgb), float3(0.299, 0.587, 0.114)) / max(float(color.a), 0.001);
    float d = distance(position, touch) / radius;
    float heat = saturate(0.35 * luma + 0.9 * exp(-d * d * 2.5));
    float3 palette = heat < 0.25 ? mix(float3(0.05, 0.0, 0.25), float3(0.35, 0.0, 0.6), heat / 0.25)
                   : heat < 0.5  ? mix(float3(0.35, 0.0, 0.6), float3(0.9, 0.1, 0.2), (heat - 0.25) / 0.25)
                   : heat < 0.75 ? mix(float3(0.9, 0.1, 0.2), float3(1.0, 0.75, 0.0), (heat - 0.5) / 0.25)
                   :               mix(float3(1.0, 0.75, 0.0), float3(1.0, 1.0, 0.9), (heat - 0.75) / 0.25);
    float mask = strength * (1.0 - smoothstep(0.7, 1.3, d));                         // mép vùng mờ dần, không cắt cứng
    return half4(mix(color.rgb, half3(palette) * color.a, half(mask)), color.a);     // màu premultiplied
}
