// MapMarkerHelper.swift
// App/View/City/Map

import UIKit

enum MapMarkerHelper {

    // MARK: - Individual shop marker — icon circle + dark pill (1b)

    static func createMarkerImage(with text: String) -> UIImage {
        let font = UIFont.systemFont(ofSize: 11, weight: .semibold)
        let textAttrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(red: 0.95, green: 0.90, blue: 0.82, alpha: 1.0) // #F2E6D0
        ]
        let attrText = NSAttributedString(string: text, attributes: textAttrs)
        let textSize = attrText.size()

        let circleSize: CGFloat = 28
        let overlap: CGFloat = 8
        let textLeadPad: CGFloat = 8
        let textTrailPad: CGFloat = 10
        let height: CGFloat = 28

        let pillBodyWidth = textLeadPad + ceil(textSize.width) + textTrailPad
        let totalWidth = (circleSize - overlap) + pillBodyWidth
        let size = CGSize(width: ceil(totalWidth), height: height)

        let format = UIGraphicsImageRendererFormat()
        format.opaque = false

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            let pillRect = CGRect(x: circleSize - overlap, y: 0,
                                  width: size.width - (circleSize - overlap), height: height)

            // Dark pill
            UIColor(red: 0.18, green: 0.13, blue: 0.09, alpha: 1.0).setFill() // #2E2218
            UIBezierPath(roundedRect: pillRect, cornerRadius: height / 2).fill()

            // Orange circle (drawn on top, overlapping pill)
            let circleRect = CGRect(x: 0, y: 0, width: circleSize, height: height)
            UIColor(red: 0.91, green: 0.36, blue: 0.05, alpha: 1.0).setFill() // #E85C0D
            UIBezierPath(ovalIn: circleRect).fill()

            // Cup icon inside circle
            let iconSize: CGFloat = 13
            let iconX = (circleSize - iconSize) / 2
            let iconY = (height - iconSize) / 2
            let darkColor = UIColor(red: 0.11, green: 0.06, blue: 0.02, alpha: 1.0) // #1B0F06
            if let cupIcon = UIImage(systemName: "cup.and.saucer")?
                .withTintColor(darkColor, renderingMode: .alwaysOriginal) {
                cupIcon.draw(in: CGRect(x: iconX, y: iconY, width: iconSize, height: iconSize))
            }

            // Text
            let textX = (circleSize - overlap) + textLeadPad
            let textY = (height - textSize.height) / 2
            attrText.draw(at: CGPoint(x: textX, y: textY))
        }
    }

    // MARK: - Cluster marker — solid orange pill

    static func createClusterImage(count: Int) -> UIImage {
        let text = "\(count)"
        let font = UIFont.systemFont(ofSize: 12, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(red: 0.11, green: 0.06, blue: 0.02, alpha: 1.0) // #1B0F06
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let textSize = attributedText.size()

        let horizontalPad: CGFloat = 14
        let verticalPad: CGFloat = 7
        let minWidth: CGFloat = 36

        let width = max(minWidth, textSize.width + horizontalPad * 2)
        let height = textSize.height + verticalPad * 2
        let size = CGSize(width: ceil(width), height: ceil(height))

        let format = UIGraphicsImageRendererFormat()
        format.opaque = false

        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            UIColor(red: 0.91, green: 0.36, blue: 0.05, alpha: 1.0).setFill()
            UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: size.height / 2).fill()

            let textX = (size.width - textSize.width) / 2
            let textY = (size.height - textSize.height) / 2
            attributedText.draw(at: CGPoint(x: textX, y: textY))
        }
    }
}
