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

// MARK: - Level 4 · Ripple tại điểm chạm

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

// MARK: - Ví dụ · Biến dạng nền dưới glass

[[ stitchable ]]
float2 fingerWarp(float2 position, float2 center, float radius, float strength, float time) {
    float2 d = position - center;
    float k = exp(-dot(d, d) / (radius * radius));            // trọng số Gauss theo khoảng cách tới tâm
    float wobble = sin(length(d) * 0.045 - time * 2.5) * 12.0 * k * strength; // strength = 0: không méo gì
    return position - d * k * strength + wobble;               // lấy mẫu gần tâm hơn → phóng to vùng quanh tâm
}
