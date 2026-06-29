//
//  GraphQLService.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/27.
//  网络层，封装一下 PokeAPI GraphQL 请求
//

import SwiftUI

class GraphQLService {

    static let shared = GraphQLService()

    private let endpoint = URL(string: "https://beta.pokeapi.co/graphql/v1beta")!

    private init() {}

    func fetch<T: Decodable>(_ type: T.Type, query: String, variables: [String: GraphQLVariable]? = nil) async throws -> T {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = GraphQLRequest(query: query, variables: variables)
        request.httpBody = try JSONEncoder().encode(body)

        print("[GraphQL] request: \(query.prefix(30))... vars: \(variables ?? [:])")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            print("[GraphQL] bad response: \(response)")
            throw GraphQLServiceError.badServerResponse
        }
        let envelope = try JSONDecoder().decode(GraphQLResponseEnvelope<T>.self, from: data)
        if let errors = envelope.errors, !errors.isEmpty {
            print("[GraphQL] errors: \(errors.map(\.message))")
            throw GraphQLServiceError.graphQLErrors(errors.map(\.message))
        }
        guard let result = envelope.data else {
            throw GraphQLServiceError.cannotParseResponse
        }
        return result
    }
}

private struct GraphQLResponseEnvelope<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLError]?
}
