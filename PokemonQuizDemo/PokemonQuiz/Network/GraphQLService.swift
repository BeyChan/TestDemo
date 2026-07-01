//
//  GraphQLService.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/27.
//  网络层，封装一下 PokeAPI GraphQL 请求
//

import SwiftUI
// 加nonisolated消除警告
nonisolated protocol GraphQLServicing: AnyObject {
    func fetch<T: Decodable>(_ type: T.Type, query: String, variables: [String: GraphQLVariable]?) async throws -> T
}

nonisolated class GraphQLService: GraphQLServicing {

    nonisolated static let shared = GraphQLService()

    private let endpoint = URL(string: "https://beta.pokeapi.co/graphql/v1beta")!

    private init() {}

    func fetch<T: Decodable>(_ type: T.Type, query: String, variables: [String: GraphQLVariable]? = nil) async throws -> T {
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = GraphQLRequest(query: query, variables: variables)
        request.httpBody = try JSONEncoder().encode(body)

        Log.info("request: \(query.prefix(30))... vars: \(variables ?? [:])")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            Log.error("badServerResponse")
            throw GraphQLServiceError.badServerResponse
        }
        Log.info("\(http.statusCode) | \(data.count) bytes")

        guard http.statusCode == 200 else {
            Log.error("badServerResponse http statusCode: \(http.statusCode)")
            throw GraphQLServiceError.badServerResponse
        }

        let rawJSON = String(data: data, encoding: .utf8) ?? ""
        Log.debug("response: \(rawJSON)")

        let envelope = try JSONDecoder().decode(GraphQLResponseEnvelope<T>.self, from: data)
        if let errors = envelope.errors, !errors.isEmpty {
            Log.error("errors: \(errors.map(\.message))")
            throw GraphQLServiceError.graphQLErrors(errors.map(\.message))
        }
        guard envelope.data != nil else {
            let raw = String(String(data: data, encoding: .utf8)?.prefix(300) ?? "")
            Log.error("no data, raw: \(raw)")
            throw GraphQLServiceError.cannotParseResponse
        }
        return envelope.data!
    }
}

private nonisolated struct GraphQLResponseEnvelope<T: Decodable>: Decodable {
    let data: T?
    let errors: [GraphQLError]?
}
