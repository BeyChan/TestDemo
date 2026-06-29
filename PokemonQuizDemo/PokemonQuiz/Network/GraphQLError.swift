//
//  GraphQLError.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/28.
//

import SwiftUI

struct GraphQLError: Decodable {
    let message: String
}

enum GraphQLServiceError: LocalizedError {
    case badServerResponse
    case graphQLErrors([String])
    case cannotParseResponse

    var errorDescription: String? {
        switch self {
        case .badServerResponse:
            return "Server returned an invalid response."
        case .graphQLErrors(let messages):
            return messages.joined(separator: "; ")
        case .cannotParseResponse:
            return "Unable to parse the server response."
        }
    }
}
