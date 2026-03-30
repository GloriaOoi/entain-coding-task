//
//  NextToGoView.swift
//  EntainCodingTask
//
//  Created by Gloria on 28/3/2026.
//

import SwiftUI

struct NextToGoView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var viewModel = NextToGoViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                categoryFilters

                if viewModel.viewState.hasAPIError {
                    Text(Strings.apiErrorMessage)
                    .font(.body)
                    .foregroundStyle(Color.Entain.primaryText)
                }
                
                if viewModel.viewState.isInitialLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.viewState.rows) { race in
                            RaceListRow(race: race)

                            if race.id != viewModel.viewState.rows.last?.id {
                                Divider()
                                    .overlay(Color.Entain.divider)
                            }
                        }
                    }

                    if viewModel.shouldShowBackgroundSpinner {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 24)
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
                let isSelected = viewModel.viewState.selectedCategories.contains(category)

                Button {
                    viewModel.toggleCategory(category)
                } label: {
                    Image(systemName: category.symbolName)
                        .font(dynamicTypeSize.isAccessibilitySize ? .title2 : .title3)
                        .foregroundStyle(isSelected ? Color.Entain.filterIconActive : Color.Entain.filterIconInactive)
                        .frame(
                            minWidth: dynamicTypeSize.isAccessibilitySize ? 72 : 56,
                            minHeight: dynamicTypeSize.isAccessibilitySize ? 72 : 56
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(isSelected ? Color.Entain.filterBackgroundActive : Color.Entain.filterBackgroundInactive)
                        )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(category.accessibilityName))
                .accessibilityValue(
                    Text(
                        isSelected
                        ? Strings.filterStateSelected
                        : Strings.filterStateUnselected
                    )
                )
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}

#Preview {
    NextToGoView()
}
