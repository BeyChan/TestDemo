//
//  PokemonModels.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/26.
//  数据模型
//

import SwiftUI

struct PokemonSpecies: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let captureRate: Int
    let colorName: String?
    let pokemons: [Pokemon]

    enum CodingKeys: String, CodingKey {
        case id, name
        case captureRate = "capture_rate"
        case color = "pokemon_v2_pokemoncolor"
        case pokemons = "pokemon_v2_pokemons"
    }

    enum ColorKeys: String, CodingKey {
        case name
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        captureRate = try container.decodeIfPresent(Int.self, forKey: .captureRate) ?? 0

        // color 可能为空，所以用 try? 包一下，避免整段解析挂掉
        if let colorContainer = try? container.nestedContainer(keyedBy: ColorKeys.self, forKey: .color) {
            colorName = try colorContainer.decodeIfPresent(String.self, forKey: .name)
        } else {
            colorName = nil
        }

        pokemons = try container.decodeIfPresent([Pokemon].self, forKey: .pokemons) ?? []
    }
}

struct Pokemon: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let abilities: [PokemonAbilitySlot]

    enum CodingKeys: String, CodingKey {
        case id, name
        case abilities = "pokemon_v2_pokemonabilities"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        abilities = try container.decodeIfPresent([PokemonAbilitySlot].self, forKey: .abilities) ?? []
    }
}

struct PokemonAbilitySlot: Identifiable, Decodable, Hashable {
    let id: Int
    let ability: PokemonAbility

    enum CodingKeys: String, CodingKey {
        case id
        case ability = "pokemon_v2_ability"
    }
}

struct PokemonAbility: Decodable, Hashable {
    let name: String?
}

// GraphQL 请求体，variables 用 enum 包一下是为了支持不同类型
struct GraphQLRequest: Encodable {
    let query: String
    let variables: [String: GraphQLVariable]?
}

enum GraphQLVariable: Encodable {
    case string(String)
    case int(Int)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let v): try container.encode(v)
        case .int(let v): try container.encode(v)
        }
    }
}

struct SpeciesData: Decodable {
    let species: [PokemonSpecies]?
    let speciesAggregate: SpeciesAggregate?

    enum CodingKeys: String, CodingKey {
        case species = "pokemon_v2_pokemonspecies"
        case speciesAggregate = "pokemon_v2_pokemonspecies_aggregate"
    }
}

struct SpeciesAggregate: Decodable {
    let aggregate: AggregateCount?
}

struct AggregateCount: Decodable {
    let count: Int?
}

struct PokemonDetailData: Decodable {
    let pokemons: [Pokemon]?

    enum CodingKeys: String, CodingKey {
        case pokemons = "pokemon_v2_pokemon"
    }
}
