//
//  SearchView.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/26.
//  搜索页
//

import SwiftUI
import UIKit

struct SearchView: View {

    @State private var vm = SearchViewModel()
    @State private var selectedPokemon: String?

    @Environment(ThemeManager.self) private var themeManager
    @Environment(LanguageManager.self) private var lang
    @Environment(\.l10n) private var S

    var body: some View {
        NavigationStack {
            ZStack {
                switch vm.pageState {
                case .failure(let error):
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.system(size: 48))
                            .foregroundColor(.orange.opacity(0.7))
                        Text(S.errorMessage(for: error))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button {
                            vm.search()
                        } label: {
                            Text(S.retry)
                                .font(.subheadline)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(Color.accent)
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 32)

                case .loading:
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.4)
                        Text(S.searching)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                case .empty:
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary.opacity(0.4))
                        Text(S.emptyPrompt)
                            .foregroundColor(.secondary)
                    }

                case .success, .loadingMore:
                    resultsList(showLoadingMore: vm.pageState.isLoadingMore)
                }
            }
            .navigationTitle(S.navTitle)
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $vm.query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: S.searchPlaceholder
            )
            .onChange(of: vm.query) { _, _ in
                vm.search()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            lang.toggleLanguage()
                        } label: {
                            Text(lang.currentLanguage.displayName)
                                .font(.system(size: 15, weight: .semibold))
                                .frame(width: 28, height: 28)
                                .background(Color.subtleBg)
                                .clipShape(Circle())
                        }

                        Button {
                            themeManager.cycleTheme()
                        } label: {
                            Image(systemName: themeManager.theme.icon)
                                .font(.system(size: 17))
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                }
            }
            .navigationDestination(item: $selectedPokemon) { name in
                PokemonDetailView(pokemonName: name)
            }
        }
    }

    @ViewBuilder
    private func resultsList(showLoadingMore: Bool) -> some View {
        List {
            ForEach(vm.results) { species in
                SpeciesRowView(species: species) { pokemonName in
                    selectedPokemon = pokemonName
                }
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .onAppear {
                    // 滑动到底部再加载下一页
                    if species == vm.results.last {
                        vm.loadNextPage()
                    }
                }
            }

            if showLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        // 收起键盘
        .simultaneousGesture(
            DragGesture(minimumDistance: 10)
                .onChanged { _ in
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
        )
        .refreshable {
            vm.search()
            try? await Task.sleep(for: .seconds(1))
        }
    }
}
