//
//  NextToGoView.swift
//  EntainCodingTask
//
//  Created by Gloria on 28/3/2026.
//

import SwiftUI

struct NextToGoView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @StateObject private var viewModel: NextToGoViewModel

    init() {
        _viewModel = StateObject(wrappedValue: NextToGoViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                categoryFilters
                
                if viewModel.isInitialLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 24)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.rows) { race in
                            RaceListRow(race: race)

                            if race.id != viewModel.rows.last?.id {
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
                let isSelected = viewModel.selectedCategories.contains(category)

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
                        ? NSLocalizedString("filter_state_selected", comment: "Accessibility value for a selected filter")
                        : NSLocalizedString("filter_state_unselected", comment: "Accessibility value for an unselected filter")
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
