//
//  ThemeManager.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/26.
//

import SwiftUI

enum AppTheme: String, CaseIterable {
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .light:  return .light
        case .dark:   return .dark
        }
    }

    var icon: String {
        switch self {
        case .light:  return "sun.max.fill"
        case .dark:   return "moon.fill"
        }
    }

    var label: String {
        switch self {
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    func localizedLabel(l10n: L10n) -> String {
        switch self {
        case .light:  return l10n.themeLight
        case .dark:   return l10n.themeDark
        }
    }

    func next() -> AppTheme {
        let all = AppTheme.allCases
        let idx = all.firstIndex(of: self) ?? 0
        return all[(idx + 1) % all.count]
    }
}

@Observable
final class ThemeManager {
    private let key = "appTheme"

    var theme: AppTheme {
        didSet {
            UserDefaults.standard.set(theme.rawValue, forKey: key)
        }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: key) ?? ""
        self.theme = AppTheme(rawValue: stored) ?? .light
    }

    func cycleTheme() {
        withAnimation(.easeInOut(duration: 0.25)) {
            theme = theme.next()
        }
    }
}
