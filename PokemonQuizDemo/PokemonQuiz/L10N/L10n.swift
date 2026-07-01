//
//  L10n.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/26.
//

import SwiftUI

private struct L10nKey: EnvironmentKey {
    static let defaultValue = L10n(bundle: .main)
}

extension EnvironmentValues {
    var l10n: L10n {
        get { self[L10nKey.self] }
        set { self[L10nKey.self] = newValue }
    }
}

struct L10n {
    let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    private func t(_ key: String) -> String {
        NSLocalizedString(key, bundle: bundle, comment: "")
    }

    var splashTitle: String { t("splash.title") }
    var splashTagline: String { t("splash.tagline") }
    var splashWelcome: String { t("splash.welcome") }

    var searchPlaceholder: String { t("search.placeholder") }
    var searching: String { t("search.searching") }
    var emptyPrompt: String { t("search.empty_prompt") }
    var noResults: String { t("search.no_results") }
    var retry: String { t("search.retry") }
    var navTitle: String { t("nav.title") }

    func captureRate(_ rate: Int) -> String {
        String(format: t("species.capture_rate"), rate)
    }

    var abilities: String { t("detail.abilities") }
    var noAbilities: String { t("detail.no_abilities") }
    var height: String { t("detail.height") }
    var weight: String { t("detail.weight") }
    var types: String { t("detail.types") }
    var color: String { t("detail.color") }

    func heightValue(_ decimetres: Int) -> String {
        String(format: t("detail.height_value"), decimetres, Double(decimetres) / 10)
    }

    func weightValue(_ hectograms: Int) -> String {
        String(format: t("detail.weight_value"), hectograms, Double(hectograms) / 10)
    }

    var themeSystem: String { t("theme.system") }
    var themeLight: String { t("theme.light") }
    var themeDark: String { t("theme.dark") }

    func themeLabel(_ name: String) -> String {
        String(format: t("accessibility.theme_label"), name)
    }
    var themeHint: String { t("accessibility.theme_hint") }
    var languageLabel: String { t("accessibility.language_label") }
    var languageHint: String { t("accessibility.language_hint") }

    var errorNetwork: String { t("error.network") }
    var errorParse: String { t("error.parse") }
    var errorUnknown: String { t("error.unknown") }

    func errorMessage(for error: Error) -> String {
        guard let viewError = error as? ViewError else {
            return error.localizedDescription
        }
        switch viewError {
        case .network:
            return errorNetwork
        case .server(_, let msg):
            return msg
        case .parse:
            return errorParse
        case .unknown:
            return errorUnknown
        }
    }
}
