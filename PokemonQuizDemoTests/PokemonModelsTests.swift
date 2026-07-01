//
//  PokemonModelsTests.swift
//  PokemonQuizDemoTests
//

import Foundation
import Testing
@testable import PokemonQuizDemo

struct PokemonModelsTests {

    private let decoder = JSONDecoder()

    @Test func testDecodePokemonSpecies() throws {
        let json = """
        {
            "id": 25,
            "name": "pikachu",
            "capture_rate": 45,
            "pokemon_v2_pokemoncolor": { "name": "yellow" },
            "pokemon_v2_pokemons": [
                { "id": 25, "name": "pikachu", "pokemon_v2_pokemonabilities": [] }
            ]
        }
        """.data(using: .utf8)!

        let s = try decoder.decode(PokemonSpecies.self, from: json)
        #expect(s.id == 25)
        #expect(s.name == "pikachu")
        #expect(s.captureRate == 45)
        #expect(s.colorName == "yellow")
        #expect(s.pokemons.count == 1)
    }


    @Test func testDecodePokemonAbilities() throws {
        let json = """
        {
            "id": 25,
            "name": "pikachu",
            "pokemon_v2_pokemonabilities": [
                { "id": 1, "pokemon_v2_ability": { "name": "static" } },
                { "id": 2, "pokemon_v2_ability": { "name": "lightning-rod" } }
            ]
        }
        """.data(using: .utf8)!

        let p = try decoder.decode(Pokemon.self, from: json)
        #expect(p.abilities.count == 2)
        #expect(p.abilities[0].ability.name == "static")
        #expect(p.abilities[1].ability.name == "lightning-rod")
    }

    @Test func testDecodeSpeciesData() throws {
        let full = """
        {
            "pokemon_v2_pokemonspecies": [
                { "id": 1, "name": "bulbasaur", "capture_rate": 45 }
            ],
            "pokemon_v2_pokemonspecies_aggregate": {
                "aggregate": { "count": 151 }
            }
        }
        """.data(using: .utf8)!

        let d = try decoder.decode(SpeciesData.self, from: full)
        #expect(d.species?.count == 1)
        #expect(d.species?.first?.name == "bulbasaur")
        #expect(d.speciesAggregate?.aggregate?.count == 151)
    }

    @Test func testDecodeDetailData() throws {
        let json = """
        {
            "pokemon_v2_pokemon": [
                {
                    "id": 25,
                    "name": "pikachu",
                    "pokemon_v2_pokemonabilities": [
                        { "id": 1, "pokemon_v2_ability": { "name": "static" } }
                    ]
                }
            ]
        }
        """.data(using: .utf8)!

        let d = try decoder.decode(PokemonDetailData.self, from: json)
        #expect(d.pokemons?.count == 1)
        #expect(d.pokemons?.first?.name == "pikachu")
    }

    @Test func destGraphQLVariableEncoding() throws {
        let str = try JSONEncoder().encode(GraphQLVariable.string("test"))
        #expect(try JSONDecoder().decode(String.self, from: str) == "test")

        let num = try JSONEncoder().encode(GraphQLVariable.int(42))
        #expect(try JSONDecoder().decode(Int.self, from: num) == 42)
    }

    @Test func testGraphQLRequestEncoding() throws {
        let req = GraphQLRequest(
            query: "query { pokemons }",
            variables: ["name": .string("pika"), "limit": .int(20)]
        )
        let encoded = try JSONEncoder().encode(req)
        let dict = try JSONSerialization.jsonObject(with: encoded) as? [String: Any]

        #expect(dict?["query"] as? String == "query { pokemons }")
        let vars = dict?["variables"] as? [String: Any]
        #expect(vars?["name"] as? String == "pika")
        #expect(vars?["limit"] as? Int == 20)
    }
}
