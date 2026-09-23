// ShopScheduleView.swift
// App/View/Shop

import SwiftUI

struct ShopScheduleView: View {
    let branch: BranchEntity
    @Environment(BrewTheme.self) private var theme

    private var isOpen: Bool? { OpeningHoursParser.isOpenNow(hours: branch.openingHours) }
    private var isClosingSoon: Bool { OpeningHoursParser.isClosingSoon(hours: branch.openingHours) }

    private var nextChangeText: String? {
        guard let next = OpeningHoursParser.nextChange(hours: branch.openingHours) else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let time = formatter.string(from: next)
        return isOpen == true ? "Fecha às \(time)" : "Abre às \(time)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Horários")
                    .font(.headline)
                    .foregroundColor(theme.tokens.colors.textPrimary)

                Spacer()

                if let open = isOpen {
                    let closingSoon = open && isClosingSoon
                    let color: Color = closingSoon
                        ? theme.tokens.colors.warningMain
                        : (open ? theme.tokens.colors.successMain : theme.tokens.colors.errorMain)
                    HStack(spacing: 4) {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(color)
                        Text(closingSoon ? "Fecha em breve" : (open ? "Aberto" : "Fechado"))
                            .font(.caption.weight(.semibold))
                            .foregroundColor(color)
                    }
                }
            }

            Text(branch.openingHours.map { OpeningHoursParser.formatForDisplay($0) } ?? "Não disponível")
                .font(.subheadline)
                .foregroundColor(theme.tokens.colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let hint = nextChangeText {
                Text(hint)
                    .font(.caption)
                    .foregroundColor(theme.tokens.colors.textSecondary)
            }
        }
        .padding()
        .background(theme.tokens.colors.backgroundCard)
        .cornerRadius(theme.tokens.radius.radiusCard)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel({
            var label = "Horários de funcionamento: \(branch.openingHours ?? "não disponível")"
            if let open = isOpen { label += ". \(open ? "Aberto agora" : "Fechado agora")" }
            return label
        }())
    }
}
