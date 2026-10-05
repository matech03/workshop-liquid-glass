import SwiftUI

/// Ví dụ · Thông dụng: chuyển cảnh nối nguồn với đích, để người dùng thấy mình vừa chạm vào đâu.
/// Một cặp API cho cả hai tab: `matchedTransitionSource(id:in:)` đánh dấu nguồn, `.navigationTransition(.zoom(sourceID:in:))` trên đích.
/// Tab Sheet: sheet mọc ra từ chính nút glass vừa chạm, đóng thì thu về nút.
/// Tab Hero: thẻ phóng to thành màn chi tiết (push thật lên NavigationStack), back thì thu về thẻ.
/// `matchedGeometryEffect` chỉ nối được view trong cùng một màn; sang màn khác phải dùng `.zoom`.
struct MatchedTransitionDemo: View {
    enum Tab: String, CaseIterable { case sheet = "Sheet", hero = "Hero" }

    var body: some View {
        DemoTabs(Tab.sheet) { tab in
            switch tab {
            case .sheet: ZoomSheetDemo().safeAreaInset(edge: .top) { CodeHint(code: "matchedTransitionSource · .sheet + .zoom") }
            case .hero: ZoomPushDemo().safeAreaInset(edge: .top) { CodeHint(code: "matchedTransitionSource · push + .zoom") }
            }
        }
    }
}

// MARK: - Sheet

/// Hai nguồn trên cùng một màn: sheet mọc ra từ đúng nút được chạm.
private struct ZoomSheetDemo: View {
    enum Source: Identifiable { case filter, compose; var id: Self { self } }
    @State private var presented: Source?
    @Namespace private var ns

    var body: some View {
        FeedPlaceholder()
            .overlay(alignment: .topTrailing) {
                Button { presented = .filter } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.body.weight(.semibold))
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .matchedTransitionSource(id: Source.filter, in: ns)
                .padding(.top, 8)
                .padding(.trailing, 20)
            }
            .overlay(alignment: .bottomTrailing) {
                Button { presented = .compose } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title2.weight(.semibold))
                        .frame(width: 56, height: 56)
                }
                .buttonStyle(.glass)
                .buttonBorderShape(.circle)
                .matchedTransitionSource(id: Source.compose, in: ns) // đánh dấu nút là nguồn của chuyển cảnh
                .padding(24)
            }
            .sheet(item: $presented) { source in
                DemoSheet(source: source)
                    .navigationTransition(.zoom(sourceID: source, in: ns)) // cùng id, cùng @Namespace với nguồn
            }
            .sensoryFeedback(.impact(weight: .light), trigger: presented)
    }

    private struct DemoSheet: View {
        let source: Source
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            NavigationStack {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach([1, 0.85, 0.55], id: \.self) { w in
                        Capsule().fill(.secondary.opacity(0.35)).frame(height: 10)
                            .containerRelativeFrame(.horizontal) { l, _ in l * w * 0.9 }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .navigationTitle(source == .compose ? "Bài viết mới" : "Bộ lọc")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Đóng", systemImage: "xmark") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button("Xong", systemImage: "checkmark") { dismiss() } }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

/// Nội dung giả của một màn feed: đủ chi tiết phía sau để glass có gì khúc xạ, màu dịu.
private struct FeedPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { i in
                HStack(spacing: 12) {
                    Circle().fill(.white.opacity(0.14)).frame(width: 40, height: 40)
                    VStack(alignment: .leading, spacing: 8) {
                        Capsule().fill(.white.opacity(0.18)).frame(width: 120, height: 9)
                        Capsule().fill(.white.opacity(0.10)).frame(height: 9)
                        Capsule().fill(.white.opacity(0.10)).frame(width: i.isMultiple(of: 2) ? 160 : 200, height: 9)
                    }
                }
                .padding(14)
                .background(.white.opacity(0.05), in: .rect(cornerRadius: 18))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 56)
        .frame(maxHeight: .infinity, alignment: .top)
        .background { Backdrop() }
    }
}

// MARK: - Hero

private struct Place {
    let title: String
    let subtitle: String
    let symbol: String
    let colors: [Color]
}

private let places = [
    Place(title: "Biển", subtitle: "Nha Trang", symbol: "water.waves", colors: [Palette.teal, Palette.slate]),
    Place(title: "Núi", subtitle: "Sa Pa", symbol: "mountain.2.fill", colors: [Palette.teal.opacity(0.85), Palette.navy]),
    Place(title: "Hoàng hôn", subtitle: "Phú Quốc", symbol: "sun.horizon.fill", colors: [Palette.peach, Palette.rose]),
    Place(title: "Thành phố", subtitle: "Hà Nội", symbol: "building.2.fill", colors: [Palette.violet, Palette.navy]),
]

/// Lưới thẻ. Chạm thẻ: push màn chi tiết lên NavigationStack của app, thẻ phóng to thành màn mới.
private struct ZoomPushDemo: View {
    @State private var selected: Int?
    @Namespace private var ns

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            ForEach(places.indices, id: \.self) { i in
                card(places[i])
                    .matchedTransitionSource(id: i, in: ns) { $0.clipShape(.rect(cornerRadius: 22)) }
                    .onTapGesture { selected = i }
            }
        }
        .padding(16)
        .frame(maxHeight: .infinity, alignment: .top)
        .background { Backdrop() }
        .navigationDestination(item: $selected) { i in
            PlaceDetail(place: places[i])
                .navigationTransition(.zoom(sourceID: i, in: ns)) // màn mới mọc ra từ thẻ, back thì thu về thẻ
        }
        .sensoryFeedback(.impact(weight: .light), trigger: selected)
    }

    private func card(_ place: Place) -> some View {
        RoundedRectangle(cornerRadius: 22)
            .fill(LinearGradient(colors: place.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay { Image(systemName: place.symbol).font(.system(size: 40)).foregroundStyle(.white) }
            .overlay(alignment: .bottomLeading) {
                Text(place.title).font(.headline).foregroundStyle(.white).padding(12)
            }
            .frame(height: 150)
            .contentShape(.rect(cornerRadius: 22))
    }
}

/// Màn chi tiết. Nút back và các nút trên thanh điều hướng là glass hệ thống: không có dòng glassEffect nào.
private struct PlaceDetail: View {
    let place: Place
    @State private var liked = false

    var body: some View {
        LinearGradient(colors: place.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .overlay { Image(systemName: place.symbol).font(.system(size: 120)).foregroundStyle(.white) }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.title).font(.largeTitle.bold())
                    Text(place.subtitle).font(.title3)
                }
                .foregroundStyle(.white)
                .padding(24)
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Thích", systemImage: liked ? "heart.fill" : "heart") { liked.toggle() }
                    Button("Chia sẻ", systemImage: "square.and.arrow.up") {}
                }
            }
            .sensoryFeedback(.selection, trigger: liked)
    }
}

#Preview { NavigationStack { MatchedTransitionDemo() } }
