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
                        if let url = mon.artworkURL {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                case .failure:
                                    Image(systemName: "photo")
                                        .font(.system(size: 60))
                                        .foregroundColor(.secondary)
                                default:
                                    ProgressView()
                                }
                            }
                            .frame(maxWidth: 240)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                        }

                        Text(mon.name.capitalized)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryText)

                        Divider()

                        HStack(spacing: 16) {
                            infoCard(title: S.height, value: S.heightValue(mon.height))
                            infoCard(title: S.weight, value: S.weightValue(mon.weight))
                            if let color = mon.colorName {
                                infoCard(title: S.color, value: color.capitalized)
                            }
                        }

                        let typeNames = mon.types.compactMap { $0.type.name }
                        if !typeNames.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text(S.types)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primaryText)

                                FlowLayout(spacing: 8) {
                                    ForEach(typeNames, id: \.self) { name in
                                        Text(name.capitalized)
                                            .font(.subheadline)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 7)
                                            .background(Color.accent.opacity(0.15))
                                            .clipShape(Capsule())
                                            .overlay(Capsule().stroke(Color.accent, lineWidth: 1))
                                            .foregroundColor(.primaryText)
                                    }
                                }
                            }
                        }

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

    private func infoCard(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.subtleBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
