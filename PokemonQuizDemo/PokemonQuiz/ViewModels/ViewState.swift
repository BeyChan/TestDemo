//
//  ViewState.swift
//  PokemonQuizDemo
//
//  Created by Marvin Cheng on 2026/6/27.
//  页面状态枚举，loading / success / empty / failure 几个常见状态
//

import Foundation

enum ViewState<T> {
    case loading
    case success(T)
    case loadingMore(T)
    case empty
    case failure(Error)

    var isLoadingMore: Bool {
        if case .loadingMore = self { return true }
        return false
    }

    var data: T? {
        switch self {
        case .success(let data), .loadingMore(let data):
            return data
        default:
            return nil
        }
    }
}

// 错误类型
enum ViewError: LocalizedError {
    case network
    case server(code: Int, msg: String)
    case parse
    case unknown

    var errorDescription: String? {
        let bundle = LanguageManager.currentBundle
        switch self {
        case .network:
            return NSLocalizedString("error.network", bundle: bundle, comment: "")
        case .server(_, let msg):
            return msg
        case .parse:
            return NSLocalizedString("error.parse", bundle: bundle, comment: "")
        case .unknown:
            return NSLocalizedString("error.unknown", bundle: bundle, comment: "")
        }
    }
}
