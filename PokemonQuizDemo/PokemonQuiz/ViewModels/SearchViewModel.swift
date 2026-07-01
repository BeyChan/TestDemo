//
//  SearchViewModel.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/26.
//  搜索页 ViewModel，负责防抖、分页、状态管理
//

import SwiftUI

@MainActor
@Observable
final class SearchViewModel {

    var query: String = ""
    var pageState: ViewState<[PokemonSpecies]> = .empty
    var totalCount: Int = 0

    let pageSize = 20
    let debounceInterval: Duration

    @ObservationIgnored private var currentPage: Int = 0
    @ObservationIgnored private var searchTask: Task<Void, Never>?
    @ObservationIgnored private let service: GraphQLServicing

    init(service: GraphQLServicing = GraphQLService.shared, debounceInterval: Duration = .milliseconds(300)) {
        self.service = service
        self.debounceInterval = debounceInterval
    }

    var results: [PokemonSpecies] {
        pageState.data ?? []
    }

    func search() {
        searchTask?.cancel()

        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            totalCount = 0
            pageState = .empty
            return
        }

        currentPage = 0
        pageState = .loading

        searchTask = Task {
            try? await Task.sleep(for: debounceInterval)
            guard !Task.isCancelled else { return }

            await performSearch(name: trimmed, page: 0)
        }
    }

    func loadNextPage() {
        guard !pageState.isLoadingMore, results.count < totalCount else { return }
        let next = currentPage + 1
        let current = results
        pageState = .loadingMore(current)
        Task {
            await performSearch(name: query, page: next)
        }
    }

    private func performSearch(name: String, page: Int) async {
        if page == 0 {
            pageState = .loading
        } else {
            pageState = .loadingMore(results)
        }

        // PokeAPI 用 % 做 ilike 模糊匹配
        let pattern = "%\(name)%"
        let vars: [String: GraphQLVariable] = [
            "name": .string(pattern),
            "limit": .int(pageSize),
            "offset": .int(page * pageSize)
        ]

        do {
            Log.info("Search for: \(name)")
            let data = try await service.fetch(SpeciesData.self, query: GraphQLQueries.searchSpecies, variables: vars)
            let species = data.species ?? []
            let count = data.speciesAggregate?.aggregate?.count ?? 0

            guard !Task.isCancelled else { return }

            if page == 0 {
                pageState = species.isEmpty ? .empty : .success(species)
            } else {
                pageState = .success(results + species)
                currentPage = page
            }
            totalCount = count
            Log.info("Found \(species.count) species, total: \(count)")
        } catch {
            Log.error("Search error: \(error.localizedDescription)")
            if !Task.isCancelled, page == 0 {
                pageState = .failure(ViewError.unknown)
            }
        }
    }
}
