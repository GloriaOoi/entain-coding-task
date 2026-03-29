//
//  NextToGoView.swift
//  EntainCodingTask
//
//  Created by Gloria on 28/3/2026.
//

import SwiftUI

struct NextToGoView: View {
    @StateObject private var viewModel: NextToGoViewModel

    init() {
        _viewModel = StateObject(wrappedValue: NextToGoViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                categoryFilters

                LazyVStack(spacing: 0) {
                    ForEach(viewModel.rows) { race in
                        RaceListRow(race: race)

                        if race.id != viewModel.rows.last?.id {
                            Divider()
                                .overlay(Color.Entain.divider)
                        }
                    }
                }
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .scrollIndicators(.hidden)
        .padding(24)
        .task {
            await viewModel.loadRaces()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }

    private var categoryFilters: some View {
        HStack(spacing: 12) {
            ForEach(RaceCategory.allCases) { category in
                Button {
                    viewModel.toggleCategory(category)
                } label: {
                    Image(systemName: category.symbolName)
                        .font(.title3)
                        .foregroundStyle(viewModel.selectedCategories.contains(category) ? Color.Entain.filterIconActive : Color.Entain.filterIconInactive)
                        .frame(width: 56, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(viewModel.selectedCategories.contains(category) ? Color.Entain.filterBackgroundActive : Color.Entain.filterBackgroundInactive)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NextToGoView()
}
