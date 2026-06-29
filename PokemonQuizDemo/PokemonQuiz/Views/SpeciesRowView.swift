//
//  SpeciesRowView.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/26.
//

import SwiftUI

struct SpeciesRowView: View {

    let species: PokemonSpecies
    let onSelectPokemon: (String) -> Void

    @Environment(\.l10n) private var S

    var body: some View {
        let bg = Color.pokemon(species.colorName)

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(species.name.capitalized)
                        .font(.headline)
                        .foregroundColor(.primaryText)

                    Text(S.captureRate(species.captureRate))
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }

                Spacer()

                if let color = species.colorName {
                    Text(color.capitalized)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.badgeBg)
                        .clipShape(Capsule())
                        .foregroundColor(.primaryText)
                }
            }

            if !species.pokemons.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(species.pokemons) { mon in
                            Button {
                                onSelectPokemon(mon.name)
                            } label: {
                                Text(mon.name.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.pillBg)
                                    .clipShape(Capsule())
                                    .foregroundColor(.pillText)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(bg.opacity(0.55))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(bg.opacity(0.3), lineWidth: 1)
        )
    }
}
