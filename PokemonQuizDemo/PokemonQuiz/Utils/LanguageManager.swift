//
//  LanguageManager.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/26.
//  语言切换，需求没要求，但为了展示国际化顺手加了
//

import SwiftUI


enum AppLanguage: String, CaseIterable {
    case en
    case zh

    var displayName: String {
        switch self {
        case .en: return "EN"
        case .zh: return "中"
        }
    }

    var lprojName: String {
        switch self {
        case .en: return "en"
        case .zh: return "zh-Hans"
        }
    }

    func next() -> AppLanguage {
        switch self {
        case .en: return .zh
        case .zh: return .en
        }
    }
}


@Observable
final class LanguageManager {
    private let key = "appLanguage"

    static var currentBundle: Bundle = .main

    var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: key)
            Self.currentBundle = resolveBundle()
        }
    }

    var bundle: Bundle {
        resolveBundle()
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: key) ?? ""
        self.currentLanguage = AppLanguage(rawValue: stored) ?? .en
        Self.currentBundle = resolveBundle()
    }

    func toggleLanguage() {
        withAnimation(.easeInOut(duration: 0.2)) {
            currentLanguage = currentLanguage.next()
        }
    }

    private func resolveBundle() -> Bundle {
        guard let path = Bundle.main.path(forResource: currentLanguage.lprojName, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }
}
