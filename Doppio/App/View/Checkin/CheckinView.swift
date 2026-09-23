// CheckinView.swift
// App/View/Checkin

import SwiftUI

struct CheckinView: View {
    @Environment(BrewTheme.self) private var theme
    @EnvironmentObject private var coordinator: CityCoordinator
    @StateObject private var vm: CheckinViewModel
    @FocusState private var focusedField: Field?

    private enum Field { case note, bill }

    private static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.dateFormat = "dd 'de' MMMM 'de' yyyy, HH:mm"
        return fmt
    }()

    private var formattedDate: String {
        Self.dateFormatter.string(from: Date())
    }

    init(vm: CheckinViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            theme.tokens.colors.backgroundPrimary.ignoresSafeArea()
            if vm.isSuccess { successState } else { formState }
        }
        .navigationTitle("Check-in")
        .navigationBarTitleDisplayMode(.inline)
        .doppioBackButton()
        .alert("Não foi possível registrar", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Pronto") { focusedField = nil }
            }
        }
    }

    // MARK: - Form

    private var formState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Shop info card
                VStack(alignment: .leading, spacing: 4) {
                    Text(vm.shopName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(theme.tokens.colors.textPrimary)
                    Text(vm.district)
                        .font(.subheadline)
                        .foregroundColor(theme.tokens.colors.textSecondary)
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(theme.tokens.colors.textSecondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(theme.tokens.colors.backgroundCard)
                .cornerRadius(theme.tokens.radius.radiusCard)

                // Primeira visita
                VStack(alignment: .leading, spacing: 10) {
                    Text("É a sua primeira visita aqui?")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(theme.tokens.colors.textSecondary)
                    HStack(spacing: 10) {
                        ForEach([true, false], id: \.self) { value in
                            Button {
                                vm.isFirstVisit = value
                            } label: {
                                Text(value ? "Sim" : "Não")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(vm.isFirstVisit == value
                                        ? theme.tokens.colors.backgroundPrimary
                                        : theme.tokens.colors.textPrimary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(vm.isFirstVisit == value
                                        ? theme.tokens.colors.primaryMain
                                        : theme.tokens.colors.backgroundCard)
                                    .cornerRadius(theme.tokens.radius.radiusChip)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: theme.tokens.radius.radiusChip)
                                            .stroke(theme.tokens.colors.primaryMain.opacity(0.3), lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier(value ? "checkin_first_visit_yes" : "checkin_first_visit_no")
                        }
                    }
                }

                // Acompanhamento
                VStack(alignment: .leading, spacing: 10) {
                    Text("Você veio...")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(theme.tokens.colors.textSecondary)
                    HStack(spacing: 8) {
                        ForEach(CheckinGroupSize.allCases, id: \.self) { size in
                            Button {
                                vm.groupSize = size
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: size.icon)
                                        .font(.system(size: 13))
                                    Text(size.label)
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .foregroundColor(vm.groupSize == size
                                    ? theme.tokens.colors.backgroundPrimary
                                    : theme.tokens.colors.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(vm.groupSize == size
                                    ? theme.tokens.colors.primaryMain
                                    : theme.tokens.colors.backgroundCard)
                                .cornerRadius(theme.tokens.radius.radiusChip)
                                .overlay(
                                    RoundedRectangle(cornerRadius: theme.tokens.radius.radiusChip)
                                        .stroke(theme.tokens.colors.primaryMain.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Valor da conta
                VStack(alignment: .leading, spacing: 6) {
                    Text("Valor total da conta (opcional)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(theme.tokens.colors.textSecondary)
                    HStack(spacing: 6) {
                        Text("R$")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(theme.tokens.colors.textSecondary)
                        TextField("0,00", text: $vm.billAmountText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 15))
                            .foregroundColor(theme.tokens.colors.textPrimary)
                            .focused($focusedField, equals: .bill)
                    }
                    .padding(12)
                    .background(theme.tokens.colors.backgroundCard)
                    .cornerRadius(theme.tokens.radius.radiusControl)
                    if let billError = vm.billAmountError {
                        Text(billError)
                            .font(.caption)
                            .foregroundColor(theme.tokens.colors.errorMain)
                    }
                }

                // Nota
                VStack(alignment: .leading, spacing: 6) {
                    Text("Nota (opcional)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(theme.tokens.colors.textSecondary)
                    TextField("Como foi sua visita?", text: $vm.note, axis: .vertical)
                        .lineLimit(5...)
                        .font(.subheadline)
                        .foregroundColor(theme.tokens.colors.textPrimary)
                        .focused($focusedField, equals: .note)
                        .padding(12)
                        .background(theme.tokens.colors.backgroundCard)
                        .cornerRadius(theme.tokens.radius.radiusControl)
                    HStack {
                        Spacer()
                        Text("\(vm.note.count)/140")
                            .font(.caption)
                            .foregroundColor(vm.note.count >= 140
                                ? theme.tokens.colors.errorMain
                                : theme.tokens.colors.textSecondary)
                    }
                }

                VStack(spacing: 10) {
                    Button(action: {
                        focusedField = nil
                        Task { await vm.submit() }
                    }, label: {
                        Group {
                            if vm.isLoading {
                                ProgressView()
                                    .tint(theme.tokens.colors.backgroundPrimary)
                            } else {
                                Text("Fazer check-in")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundColor(theme.tokens.colors.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.tokens.colors.primaryMain)
                        .cornerRadius(theme.tokens.radius.radiusControl)
                    })
                    .disabled(vm.isLoading || vm.isFirstVisit == nil || vm.billAmountError != nil)
                    .accessibilityIdentifier("checkin_submit_button")

                    if vm.isLoading {
                        Button {
                            coordinator.pop()
                        } label: {
                            Text("Cancelar")
                                .font(.system(size: 15))
                                .foregroundColor(theme.tokens.colors.textSecondary)
                        }
                    }
                }
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
    }

    // MARK: - Success

    private var successState: some View {
        CheckinSuccessView(
            shopName: vm.shopName,
            shopId: vm.shopId,
            branchId: vm.branchId,
            checkinId: vm.checkinId,
            formattedDate: Self.dateFormatter.string(from: Date())
        )
    }
}

// MARK: - CheckinSuccessView

private struct CheckinSuccessView: View {
    @Environment(BrewTheme.self) private var theme
    @EnvironmentObject private var coordinator: CityCoordinator

    let shopName: String
    let shopId: Int
    let branchId: Int?
    let checkinId: Int?
    let formattedDate: String

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("icon-cup")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(theme.tokens.colors.successMain)
                .padding(.bottom, 16)

            Text("Check-in realizado!")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(theme.tokens.colors.textPrimary)
                .padding(.bottom, 8)
                .accessibilityIdentifier("checkin_success_title")

            Text(shopName)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(theme.tokens.colors.textSecondary)

            Text(formattedDate)
                .font(.caption)
                .foregroundColor(theme.tokens.colors.textSecondary)
                .padding(.top, 2)

            Spacer()

            VStack(spacing: 10) {
                Button {
                    coordinator.push(.rating(
                        shopId: shopId,
                        branchId: branchId,
                        shopName: shopName,
                        checkinId: checkinId
                    ))
                } label: {
                    Text("Avaliar agora")
                        .accessibilityIdentifier("checkin_rate_now_button")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.tokens.colors.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(theme.tokens.colors.primaryMain)
                        .cornerRadius(10)
                }

                Button { coordinator.pop() } label: {
                    Text("Fechar")
                        .accessibilityIdentifier("checkin_close_button")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(theme.tokens.colors.primaryMain)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .overlay(
                            RoundedRectangle(cornerRadius: theme.tokens.radius.radiusControl)
                                .stroke(theme.tokens.colors.primaryMain, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}
