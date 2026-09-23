// RatingView.swift
// App/View/Rating

import SwiftUI

struct RatingView: View {
    @Environment(BrewTheme.self) private var theme
    @EnvironmentObject private var coordinator: CityCoordinator
    @StateObject private var vm: RatingViewModel
    @FocusState private var commentIsFocused: Bool

    init(vm: RatingViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            theme.tokens.colors.backgroundPrimary.ignoresSafeArea()

            if vm.isSuccess {
                successState
            } else {
                formState
            }
        }
        .navigationTitle("Avaliação")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Não foi possível enviar", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Form

    private var formState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // Shop name card
                Text(vm.shopName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(theme.tokens.colors.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(theme.tokens.colors.backgroundCard)
                    .cornerRadius(theme.tokens.radius.radiusCard)

                // Stars
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sua avaliação")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(theme.tokens.colors.textSecondary)

                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= vm.rating ? "star.fill" : "star")
                                .font(.system(size: 32))
                                .foregroundColor(
                                    star <= vm.rating
                                        ? theme.tokens.colors.primaryMain
                                        : theme.tokens.colors.textSecondary.opacity(0.4)
                                )
                                .onTapGesture {
                                    vm.rating = star
                                }
                                .accessibilityIdentifier("rating_star_\(star)")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                }

                // Comment
                VStack(alignment: .leading, spacing: 6) {
                    Text("Comentário (opcional)")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(theme.tokens.colors.textSecondary)

                    TextField("Conta como foi sua experiência...", text: $vm.comment, axis: .vertical)
                        .lineLimit(5...)
                        .font(.subheadline)
                        .foregroundColor(theme.tokens.colors.textPrimary)
                        .focused($commentIsFocused)
                        .disabled(vm.comment.count >= 240)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("Pronto") { commentIsFocused = false }
                            }
                        }
                        .padding(12)
                        .background(vm.comment.count >= 240
                            ? theme.tokens.colors.errorMain.opacity(0.07)
                            : theme.tokens.colors.backgroundCard)
                        .cornerRadius(theme.tokens.radius.radiusControl)

                    HStack {
                        Spacer()
                        Text("\(vm.comment.count)/240")
                            .font(.caption)
                            .foregroundColor(
                                vm.comment.count >= 240
                                    ? theme.tokens.colors.errorMain
                                    : theme.tokens.colors.textSecondary
                            )
                    }
                }

                VStack(spacing: 10) {
                    Button(action: {
                        commentIsFocused = false
                        Task { await vm.submit() }
                    }, label: {
                        Group {
                            if vm.isLoading {
                                ProgressView()
                                    .tint(theme.tokens.colors.backgroundPrimary)
                            } else {
                                Text("Enviar avaliação")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                        .foregroundColor(theme.tokens.colors.backgroundPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(vm.canSubmit
                            ? theme.tokens.colors.primaryMain
                            : theme.tokens.colors.primaryMain.opacity(0.4))
                        .cornerRadius(theme.tokens.radius.radiusControl)
                    })
                    .disabled(!vm.canSubmit || vm.isLoading)
                    .accessibilityIdentifier("rating_submit_button")

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
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "star.fill")
                .font(.system(size: 56))
                .foregroundColor(theme.tokens.colors.primaryMain)

            Text("Avaliação enviada!")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(theme.tokens.colors.textPrimary)
                .accessibilityIdentifier("rating_success_title")

            Text(vm.shopName)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(theme.tokens.colors.textSecondary)

            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= vm.rating ? "star.fill" : "star")
                        .font(.system(size: 22))
                        .foregroundColor(star <= vm.rating
                            ? theme.tokens.colors.primaryMain
                            : theme.tokens.colors.textSecondary.opacity(0.3))
                }
            }

            Spacer()

            Button {
                // If rating came from a check-in flow, close both screens at once
                coordinator.pop(count: vm.checkinId != nil ? 2 : 1)
            } label: {
                Text("Fechar")
                    .accessibilityIdentifier("rating_close_button")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(theme.tokens.colors.primaryMain)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.tokens.radius.radiusControl)
                            .stroke(theme.tokens.colors.primaryMain, lineWidth: 1)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
}
