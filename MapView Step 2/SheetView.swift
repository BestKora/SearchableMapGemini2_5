//
//  SheetView.swift
//  MapView Step 2
//

import SwiftUI

struct SheetView: View {
    @Bindable var locationService: LocationService
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search for a place or address", text: $searchText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                    .submitLabel(.search)
                    .onSubmit(performSearch)
                if !searchText.isEmpty {
                    Button("Clear", systemImage: "xmark.circle.fill") {
                        searchText = ""
                        locationService.update(queryFragment: "")
                    }
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("Clear search")
                }
            }
            .padding(12)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
            .padding()

            Divider()

            List {
                if locationService.isSearching {
                    HStack {
                        ProgressView()
                        Text("Searching…")
                    }
                    .foregroundStyle(.secondary)
                }

                ForEach(locationService.completions) { completion in
                    Button { performSearch(for: completion) } label: {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(completion.title).font(.headline)
                            if !completion.subtitle.isEmpty {
                                Text(completion.subtitle).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                }

                if !searchText.isEmpty && locationService.completions.isEmpty && !locationService.isSearching {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            .listStyle(.plain)
        }
        .onChange(of: searchText) { _, query in
            locationService.update(queryFragment: query)
        }
    }

    private func performSearch() {
        Task { await locationService.search(with: searchText) }
    }

    private func performSearch(for completion: SearchCompletion) {
        searchText = completion.title
        Task { await locationService.search(for: completion) }
    }
}
