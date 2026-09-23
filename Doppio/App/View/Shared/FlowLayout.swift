// FlowLayout.swift
// App/View/Shared

import SwiftUI

/// A layout that wraps its children horizontally, starting a new row when they no longer fit.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, rowWidth > 0 {
                height += rowHeight + spacing
                rowWidth = 0
                rowHeight = 0
            }
            rowWidth += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        height += rowHeight
        return CGSize(width: maxWidth, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var xPos = bounds.minX
        var yPos = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if xPos + size.width > bounds.maxX, xPos > bounds.minX {
                yPos += rowHeight + spacing
                xPos = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: xPos, y: yPos), proposal: .unspecified)
            xPos += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
