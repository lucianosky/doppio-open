// SelectDistrictView.swift
// App/View/City

import SwiftUI

struct SelectDistrictView: View {
    let allDistricts: [String]
    @Binding var selectedDistricts: [String]
    @Environment(\.dismiss) private var dismiss
    @Environment(BrewTheme.self) private var theme

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(allDistricts, id: \.self) { district in
                    districtRow(district)
                    if district != allDistricts.last {
                        Divider()
                            .background(theme.tokens.colors.backgroundPrimary)
                            .padding(.leading, 16)
                    }
                }
            }
            .background(theme.tokens.colors.backgroundCard)
            .cornerRadius(theme.tokens.radius.radiusCard)
            .padding()
        }
        .background(theme.tokens.colors.backgroundPrimary.ignoresSafeArea())
        .navigationBarTitle("Bairros", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }, label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(theme.tokens.colors.primaryMain)
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { toggleAll() }, label: {
                    Image(systemName: "checklist.checked")
                        .foregroundColor(theme.tokens.colors.primaryMain)
                })
                .accessibilityLabel(accessibilityLabel)
                .accessibilityHint(accessibilityHint)
            }
        }
    }

    // MARK: - Row

    private func districtRow(_ district: String) -> some View {
        let isSelected = selectedDistricts.contains(district)
        return Button(action: { toggle(district) }, label: {
            HStack {
                Text(district)
                    .font(.body)
                    .foregroundColor(isSelected
                        ? theme.tokens.colors.primaryMain
                        : theme.tokens.colors.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(theme.tokens.colors.primaryMain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected
                ? theme.tokens.colors.primaryMain.opacity(0.12)
                : theme.tokens.colors.backgroundCard)
        })
        .buttonStyle(.plain)
        .accessibilityLabel(district)
        .accessibilityValue(isSelected ? "selecionado" : "não selecionado")
        .accessibilityHint("Toque para \(isSelected ? "remover" : "adicionar") este bairro")
    }

    // MARK: - Helpers

    private func toggle(_ district: String) {
        if selectedDistricts.contains(district) {
            selectedDistricts.removeAll { $0 == district }
        } else {
            selectedDistricts.append(district)
        }
    }

    private func toggleAll() {
        if selectedDistricts.count == allDistricts.count {
            selectedDistricts.removeAll()
        } else {
            selectedDistricts = allDistricts
        }
    }

    private var accessibilityLabel: String {
        switch selectedDistricts.count {
        case 0: return "nenhum bairro selecionado"
        case 1: return "um bairro selecionado"
        default: return "\(selectedDistricts.count) bairros selecionados"
        }
    }

    private var accessibilityHint: String {
        selectedDistricts.count == allDistricts.count
            ? "Toque para desmarcar todos os bairros"
            : "Toque para selecionar todos os bairros"
    }
}
