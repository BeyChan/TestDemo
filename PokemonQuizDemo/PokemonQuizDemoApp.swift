//
//  PokemonQuizDemoApp.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/26.
//  入口，先显示 splash，之后进搜索页
//

import SwiftUI

@main
struct PokemonQuizDemoApp: App {
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    @State private var themeManager = ThemeManager()
    @State private var languageManager = LanguageManager()
    @State private var showSplash: Bool

    init() {
        let launched = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        _showSplash = State(initialValue: !launched)
        Log.info("App init, hasLaunchedBefore: \(launched)")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashView {
                        withAnimation(.easeOut(duration: 0.35)) {
                            showSplash = false
                            hasLaunchedBefore = true
                        }
                    }
                } else {
                    SearchView()
                }
            }
            // TODO: 这里其实可以不要 themeManager，直接用系统主题更简单
            .environment(themeManager)
            .environment(languageManager)
            .environment(\.l10n, L10n(bundle: languageManager.bundle))
            .preferredColorScheme(themeManager.theme.colorScheme)
        }
    }
}
