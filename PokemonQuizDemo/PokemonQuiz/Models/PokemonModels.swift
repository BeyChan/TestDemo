//
//  PokemonModels.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/26.
//  数据模型
//

import SwiftUI

nonisolated struct PokemonSpecies: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let captureRate: Int
    let colorName: String?
    let pokemons: [Pokemon]

    init(id: Int, name: String, captureRate: Int = 0, colorName: String? = nil, pokemons: [Pokemon] = []) {
        self.id = id
        self.name = name
        self.captureRate = captureRate
        self.colorName = colorName
        self.pokemons = pokemons
    }

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

nonisolated struct Pokemon: Identifiable, Decodable, Hashable {
    let id: Int
    let name: String
    let height: Int
    let weight: Int
    let types: [PokemonTypeSlot]
    var colorName: String?
    let abilities: [PokemonAbilitySlot]

    var artworkURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png")
    }

    enum CodingKeys: String, CodingKey {
        case id, name, height, weight
        case types = "pokemon_v2_pokemontypes"
        case abilities = "pokemon_v2_pokemonabilities"
    }

    init(id: Int, name: String, height: Int = 0, weight: Int = 0, types: [PokemonTypeSlot] = [], colorName: String? = nil, abilities: [PokemonAbilitySlot] = []) {
        self.id = id
        self.name = name
        self.height = height
        self.weight = weight
        self.types = types
        self.colorName = colorName
        self.abilities = abilities
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        height = try container.decodeIfPresent(Int.self, forKey: .height) ?? 0
        weight = try container.decodeIfPresent(Int.self, forKey: .weight) ?? 0
        types = try container.decodeIfPresent([PokemonTypeSlot].self, forKey: .types) ?? []
        colorName = nil
        abilities = try container.decodeIfPresent([PokemonAbilitySlot].self, forKey: .abilities) ?? []
    }
}

nonisolated struct PokemonAbilitySlot: Identifiable, Decodable, Hashable {
    let id: Int
    let ability: PokemonAbility

    enum CodingKeys: String, CodingKey {
        case id
        case ability = "pokemon_v2_ability"
    }
}

nonisolated struct PokemonAbility: Decodable, Hashable {
    let name: String?
}

nonisolated struct PokemonTypeSlot: Decodable, Hashable {
    let id: Int?
    let type: PokemonType

    enum CodingKeys: String, CodingKey {
        case id
        case type = "pokemon_v2_type"
    }

    init(id: Int? = nil, type: PokemonType) {
        self.id = id
        self.type = type
    }
}

nonisolated struct PokemonType: Decodable, Hashable {
    let name: String?
}

// GraphQL 请求体，variables 用 enum 包一下是为了支持不同类型
nonisolated struct GraphQLRequest: Encodable {
    let query: String
    let variables: [String: GraphQLVariable]?
}

nonisolated enum GraphQLVariable: Encodable {
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

nonisolated struct SpeciesData: Decodable {
    let species: [PokemonSpecies]?
    let speciesAggregate: SpeciesAggregate?

    init(species: [PokemonSpecies]?, speciesAggregate: SpeciesAggregate?) {
        self.species = species
        self.speciesAggregate = speciesAggregate
    }

    enum CodingKeys: String, CodingKey {
        case species = "pokemon_v2_pokemonspecies"
        case speciesAggregate = "pokemon_v2_pokemonspecies_aggregate"
    }
}

nonisolated struct SpeciesAggregate: Decodable {
    let aggregate: AggregateCount?

    init(aggregate: AggregateCount?) {
        self.aggregate = aggregate
    }
}

nonisolated struct AggregateCount: Decodable {
    let count: Int?

    init(count: Int?) {
        self.count = count
    }
}

nonisolated struct PokemonDetailData: Decodable {
    let pokemons: [Pokemon]?

    enum CodingKeys: String, CodingKey {
        case pokemons = "pokemon_v2_pokemon"
    }
}

nonisolated struct ColorData: Decodable {
    let species: [ColorSpecies]?

    enum CodingKeys: String, CodingKey {
        case species = "pokemon_v2_pokemonspecies"
    }
}

nonisolated struct ColorSpecies: Decodable {
    let color: ColorInfo?

    enum CodingKeys: String, CodingKey {
        case color = "pokemon_v2_pokemoncolor"
    }
}

nonisolated struct ColorInfo: Decodable {
    let name: String?
}
