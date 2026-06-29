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

    @ObservationIgnored private let service = GraphQLService.shared

    func load(pokemonName: String) async {
        pageState = .loading

        let vars: [String: GraphQLVariable] = ["name": .string(pokemonName)]

        do {
            let data = try await service.fetch(PokemonDetailData.self, query: GraphQLQueries.getPokemon, variables: vars)
            if let pokemon = data.pokemons?.first {
                pageState = .success(pokemon)
            } else {
                pageState = .empty
            }
        } catch {
            pageState = .failure(ViewError.unknown)
        }
    }
}
