//
//  DetailViewModel.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/28.
//  宝可梦详情页 ViewModel
//

import Foundation

@MainActor
@Observable
final class DetailViewModel {

    var pageState: ViewState<Pokemon> = .loading

    // 移除警告
    @ObservationIgnored private let service: GraphQLServicing

    init(service: GraphQLServicing = GraphQLService.shared) {
        self.service = service
    }

    func load(pokemonName: String) async {
        pageState = .loading

        let vars: [String: GraphQLVariable] = ["name": .string(pokemonName)]

        do {
            let data = try await service.fetch(PokemonDetailData.self, query: GraphQLQueries.getPokemon, variables: vars)
            guard let pokemon = data.pokemons?.first else {
                pageState = .empty
                return
            }

            var mutablePokemon = pokemon
            do {
                let colorData = try await service.fetch(ColorData.self, query: GraphQLQueries.getColor, variables: vars)
                mutablePokemon.colorName = colorData.species?.first?.color?.name
            } catch {
                Log.error("colorData fetch failed: \(error)")
            }

            pageState = .success(mutablePokemon)
        } catch {
            Log.error("fetch failed: \(error)")
            pageState = .failure(ViewError.unknown)
        }
    }
}
