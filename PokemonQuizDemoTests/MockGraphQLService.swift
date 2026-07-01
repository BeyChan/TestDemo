//
//  MockGraphQLService.swift
//  PokemonQuizDemoTests
//

import Testing
@testable import PokemonQuizDemo

nonisolated final class MockGraphQLService: GraphQLServicing, @unchecked Sendable {

    var result: Any?
    var error: Error?
    var fetchDelay: Duration = .zero
    var fetchCallCount = 0
    var lastQuery: String?
    var lastVariables: [String: GraphQLVariable]?

    func fetch<T: Decodable>(
        _ type: T.Type,
        query: String,
        variables: [String: GraphQLVariable]?
    ) async throws -> T {
        if fetchDelay > .zero {
            try? await Task.sleep(for: fetchDelay)
        }
        fetchCallCount += 1
        lastQuery = query
        lastVariables = variables
        if let error { throw error }
        guard let result = result as? T else {
            throw MockServiceError.unconfiguredResult
        }
        return result
    }
}

enum MockServiceError: Error {
    case unconfiguredResult
}
