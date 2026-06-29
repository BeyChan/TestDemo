//
//  PokemonDetailView.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/28.
//  宝可梦详情页
//

import SwiftUI

struct PokemonDetailView: View {

    let pokemonName: String
    @State private var vm = DetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.l10n) private var S


    var body: some View {
        Group {
            switch vm.pageState {
            case .loading, .loadingMore:
                ProgressView()
                    .scaleEffect(1.4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .failure(let error):
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 44))
                        .foregroundColor(.orange)
                    Text(S.errorMessage(for: error))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    Button {
                        Task { await vm.load(pokemonName: pokemonName) }
                    } label: {
                        Text(S.retry)
                            .font(.subheadline)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.accent)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .success(let mon):
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text(mon.name.capitalized)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primaryText)
                            Spacer()
                        }

                        Divider()

                        VStack(alignment: .leading, spacing: 10) {
                            Text(S.abilities)
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.primaryText)

                            let abilities = mon.abilities.map { $0.ability.name }

                            if abilities.isEmpty {
                                Text(S.noAbilities)
                                    .foregroundColor(.secondary)
                            } else {
                                FlowLayout(spacing: 8) {
                                    ForEach(abilities, id: \.self) { name in
                                        Text(name?.capitalized ?? "")
                                            .font(.subheadline)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 7)
                                            .background(Color.accentSubtle)
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(Color.accentBorder, lineWidth: 1))
                                            .foregroundColor(.primaryText)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                }

            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(pokemonName.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await vm.load(pokemonName: pokemonName)
        }
    }
}

// 自定义流式布局
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rows: [(CGSize, [Int])] = []
        var currentRow: [Int] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0
        for i in subviews.indices {
            let size = subviews[i].sizeThatFits(.unspecified)
            let itemWidth = size.width + (currentRow.isEmpty ? 0 : spacing)
            if currentWidth + itemWidth > maxWidth && !currentRow.isEmpty {
                rows.append((CGSize(width: currentWidth, height: currentHeight), currentRow))
                currentRow = [i]
                currentWidth = size.width
                currentHeight = size.height
            } else {
                currentRow.append(i)
                currentWidth += itemWidth
                currentHeight = max(currentHeight, size.height)
            }
        }

        if !currentRow.isEmpty {
            rows.append((CGSize(width: currentWidth, height: currentHeight), currentRow))
        }

        let totalHeight = rows.reduce(0) { $0 + $1.0.height } + CGFloat(max(0, rows.count - 1)) * spacing
        let totalWidth = rows.map(\.0.width).max() ?? 0

        return CGSize(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var y = bounds.minY
        var currentRow: [Int] = []
        var currentWidth: CGFloat = 0
        var currentHeight: CGFloat = 0

        func placeRow() {
            var x = bounds.minX
            for i in currentRow {
                let size = subviews[i].sizeThatFits(.unspecified)
                subviews[i].place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += currentHeight + spacing
        }

        for i in subviews.indices {
            let size = subviews[i].sizeThatFits(.unspecified)
            let itemWidth = size.width + (currentRow.isEmpty ? 0 : spacing)

            if currentWidth + itemWidth > maxWidth && !currentRow.isEmpty {
                placeRow()
                currentRow = [i]
                currentWidth = size.width
                currentHeight = size.height
            } else {
                currentRow.append(i)
                currentWidth += itemWidth
                currentHeight = max(currentHeight, size.height)
            }
        }

        if !currentRow.isEmpty {
            placeRow()
        }
    }
}
