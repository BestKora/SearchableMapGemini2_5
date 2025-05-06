//
//  SheetView.swift
//  MapView Step 2
//
//  Created by Tatiana Kornilova on 16.04.2025.
//

import SwiftUI
import MapKit

struct SheetView: View {
    // Use @Bindable for two-way binding with @Observable service
    @Bindable var locationService: LocationService
    @State private var search: String = ""

    // Environment variable to dismiss the sheet
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) { // Use spacing 0 and add padding manually if needed
            // Search Bar Area
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search for a place or address", text: $search)
                    .autocorrectionDisabled()
                    .onSubmit(performSearch) // Search when return key is pressed
            }
            .modifier(TextFieldGrayBackgroundColor()) // Apply custom style
            .padding()

            Divider()

            // List of Completions
            List {
                // Display suggestions if available
                ForEach(locationService.completions) { completion in
                    Button(action: { didTapOnCompletion(completion) }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(completion.title)
                                .font(.headline)
                                .foregroundColor(.primary) // Ensure text is readable
                            Text(completion.subTitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .listRowBackground(Color.clear) // Optional: Make background transparent
                }

                 // Show message if query entered but no completions
                if !search.isEmpty && locationService.completions.isEmpty && locationService.error == nil {
                     ContentUnavailableView.search(text: search)
                         // .listRowBackground(Color.clear) // Match background if needed
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden) // Hide default list background

        }
        // Update completions live as the user types
        .onChange(of: search) { _, newValue in
            locationService.update(queryFragment: newValue)
        }
        // You might want to add error display within the sheet too
        .alert("Search Error", isPresented: Binding(get: { locationService.error != nil }, set: { _ in locationService.error = nil }), presenting: locationService.error) { _ in
             Button("OK") {}
        } message: { error in
             Text(error.localizedDescription)
        }
    }

    // MARK: - Actions
    private func performSearch() {
        guard !search.isEmpty else { return }
        Task {
            await locationService.search(with: search)
             // Sheet dismissal is now handled by SearchableMap's onChange(of: searchResults)
        }
    }

    private func didTapOnCompletion(_ completion: SearchCompletions) {
        Task {
            await locationService.search(for: completion)
             // Sheet dismissal is now handled by SearchableMap's onChange(of: searchResults)
        }
    }
}

// MARK: - View Modifier for Text Field Style
struct TextFieldGrayBackgroundColor: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(Color(.systemGray6)) // Use semantic colors
            .cornerRadius(10) // Slightly rounder corners
            .foregroundColor(.primary)
    }
}


