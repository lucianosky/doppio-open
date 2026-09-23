// ShopTagsView.swift
// App/View/Shop

import SwiftUI

// MARK: - Social display info (View layer — colors live here, not in Ring 1)

private struct SocialDisplay {
    let id: SocialTagID
    let color: Color

    static let all: [SocialTagID: SocialDisplay] = [
        .lgbtq: SocialDisplay(id: .lgbtq, color: Color(hex: "#FF6B35")),
        .womenOwned: SocialDisplay(id: .womenOwned, color: Color(hex: "#9B59B6")),
        .womenOnly: SocialDisplay(id: .womenOnly, color: Color(hex: "#8E44AD")),
        .transSafe: SocialDisplay(id: .transSafe, color: Color(hex: "#55A3D5")),
        .genderNeutral: SocialDisplay(id: .genderNeutral, color: Color(hex: "#5D6D7E"))
    ]

    static func color(for id: SocialTagID) -> Color {
        all[id]?.color ?? Color.gray
    }
}

// MARK: - ShopTagsView

private let maxVisible = 6

struct ShopTagsView: View {
    let shop: ShopEntity
    @Environment(BrewTheme.self) private var theme

    @State private var expanded: Set<String> = []
    @State private var showAll: Set<String> = []

    var body: some View {
        let result = ShopTagCategory.categorize(tags: shop.tags)
        let hasContent = !result.regular.isEmpty || !result.socialIDs.isEmpty

        if hasContent {
            VStack(spacing: 0) {
                ForEach(Array(result.regular.enumerated()), id: \.offset) { index, item in
                    regularSection(category: item.category, tags: item.tags, showDivider: index > 0)
                }
                ForEach(Array(result.socialIDs.enumerated()), id: \.offset) { index, socialID in
                    socialSection(
                        socialID: socialID,
                        showDivider: !result.regular.isEmpty || index > 0
                    )
                }
            }
            .background(theme.tokens.colors.backgroundCard)
            .cornerRadius(theme.tokens.radius.radiusCard)
            .onAppear {
                if let first = result.regular.first {
                    expanded.insert(first.category.rawValue)
                }
            }
        }
    }

    // MARK: - Regular section (accordion)

    // swiftlint:disable:next function_body_length
    private func regularSection(
        category: ShopTagCategory,
        tags: [String],
        showDivider: Bool
    ) -> some View {
        let id = category.rawValue
        let isExpanded = expanded.contains(id)
        let visible = showAll.contains(id) ? tags : Array(tags.prefix(maxVisible))

        return VStack(spacing: 0) {
            if showDivider {
                Divider().background(theme.tokens.colors.borderDefault)
            }

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    if isExpanded { expanded.remove(id) } else { expanded.insert(id) }
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: category.icon)
                        .font(.caption)
                        .foregroundColor(theme.tokens.colors.successMain)
                        .frame(width: 16)
                    Text(category.rawValue)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(theme.tokens.colors.textPrimary)
                    Spacer()
                    Text("· \(tags.count)")
                        .font(.caption2)
                        .foregroundColor(theme.tokens.colors.textSecondary)
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption2)
                        .foregroundColor(theme.tokens.colors.textSecondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            }
            .buttonStyle(.plain)

            if isExpanded {
                FlowLayout(spacing: 6) {
                    ForEach(visible, id: \.self) { tag in
                        regularChip(tag)
                    }
                    if !showAll.contains(id) && tags.count > maxVisible {
                        Button {
                            withAnimation { showAll.insert(id); () }
                        } label: {
                            Text("+\(tags.count - maxVisible) mais")
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .foregroundColor(theme.tokens.colors.textSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(theme.tokens.colors.borderDefault, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
    }

    // MARK: - Social section (always visible, no accordion)

    private func socialSection(socialID: SocialTagID, showDivider: Bool) -> some View {
        let color = SocialDisplay.color(for: socialID)
        return VStack(spacing: 0) {
            if showDivider {
                Divider().background(theme.tokens.colors.borderDefault)
            }
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundColor(color)
                    .frame(width: 16)
                socialChip(label: socialID.rawValue, color: color)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
    }

    // MARK: - Chips

    private func regularChip(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(theme.tokens.colors.successMain)
            .foregroundColor(theme.tokens.colors.textOnDark)
            .cornerRadius(6)
    }

    private func socialChip(label: String, color: Color) -> some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(color.opacity(0.4), lineWidth: 1)
            )
    }
}
