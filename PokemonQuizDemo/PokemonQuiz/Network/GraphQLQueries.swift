//
//  GraphQLQueries.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/27.
//  PokeAPI GraphQL 查询语句
//

import SwiftUI

enum GraphQLQueries {
    static let searchSpecies = """
    query SearchSpecies($name: String!, $limit: Int!, $offset: Int!) {
      pokemon_v2_pokemonspecies(
        where: { name: { _ilike: $name } }
        limit: $limit
        offset: $offset
        order_by: { id: asc }
      ) {
        id
        name
        capture_rate
        pokemon_v2_pokemoncolor {
          name
        }
        pokemon_v2_pokemons(limit: 10) {
          id
          name
        }
      }
      pokemon_v2_pokemonspecies_aggregate(where: { name: { _ilike: $name } }) {
        aggregate {
          count
        }
      }
    }
    """

    static let getPokemon = """
    query GetPokemon($name: String!) {
      pokemon_v2_pokemon(where: { name: { _eq: $name } }, limit: 1) {
        id
        name
        pokemon_v2_pokemonabilities {
          id
          pokemon_v2_ability {
            name
          }
        }
      }
    }
    """
}
