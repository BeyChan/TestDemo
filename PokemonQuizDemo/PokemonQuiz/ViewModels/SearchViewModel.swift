//
//  SearchViewModel.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/26.
//  搜索页 ViewModel，负责防抖、分页、状态管理
//

import SwiftUI
import os.log

private let logger = Logger(subsystem: "tech.jixun.PokemonQuizDemo", category: "Search")

@MainActor
@Observable
final class SearchViewModel {

    var query: String = ""
    var pageState: ViewState<[PokemonSpecies]> = .empty
    var totalCount: Int = 0

    let pageSize = 20

    @ObservationIgnored private var currentPage: Int = 0
    @ObservationIgnored private var searchTask: Task<Void, Never>?
    @ObservationIgnored private let service = GraphQLService.shared

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
            // 防抖：等待 300ms，试过 500ms 感觉有点慢
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            await performSearch(name: trimmed, page: 0)
        }
    }

    func loadNextPage() {
        guard !pageState.isLoadingMore, results.count < totalCount else { return }
        let next = currentPage + 1
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
            logger.info("Searching for: \(name)")
            print("[Search] page: \(page), pattern: \(pattern)")
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
            logger.info("Found \(species.count) species, total: \(count)")
        } catch {
            logger.error("Search error: \(error.localizedDescription)")
            print("[Search] error: \(error)")
            if !Task.isCancelled, page == 0 {
                // FIXME: 现在所有错误都显示 unknown，应该区分网络超时和解析错误
                pageState = .failure(ViewError.unknown)
            }
        }
    }
}
