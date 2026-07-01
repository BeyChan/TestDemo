//
//  ViewStateTests.swift
//  PokemonQuizDemoTests
//

import Foundation
import Testing
@testable import PokemonQuizDemo

struct ViewStateTests {

    @Test func dataAccessor() {
        #expect(ViewState<[Int]>.success([1, 2, 3]).data == [1, 2, 3])
        #expect(ViewState<[Int]>.loadingMore([4, 5]).data == [4, 5])
        #expect(ViewState<[Int]>.loading.data == nil)
        #expect(ViewState<[Int]>.empty.data == nil)
        #expect(ViewState<[Int]>.failure(NSError(domain: "", code: 0)).data == nil)
    }

    @Test func isLoadingMore() {
        #expect(ViewState<[Int]>.loadingMore([1]).isLoadingMore)
        #expect(!ViewState<[Int]>.loading.isLoadingMore)
        #expect(!ViewState<[Int]>.success([]).isLoadingMore)
        #expect(!ViewState<[Int]>.empty.isLoadingMore)
        #expect(!ViewState<[Int]>.failure(NSError(domain: "", code: 0)).isLoadingMore)
    }

    @Test func viewErrorDescriptions() {
        #expect(ViewError.network.errorDescription?.isEmpty == false)
        #expect(ViewError.parse.errorDescription?.isEmpty == false)
        #expect(ViewError.unknown.errorDescription?.isEmpty == false)
        #expect(ViewError.server(code: 500, msg: "Internal Server Error").errorDescription == "Internal Server Error")
    }

    @Test func graphQLServiceErrorDescriptions() {
        #expect(GraphQLServiceError.badServerResponse.errorDescription?.isEmpty == false)
        #expect(GraphQLServiceError.cannotParseResponse.errorDescription?.isEmpty == false)
        #expect(GraphQLServiceError.graphQLErrors(["err1", "err2"]).errorDescription == "err1; err2")
    }
}
