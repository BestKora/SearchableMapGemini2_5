//
//  SearchableMap.swift
//  MapView Step 2
//
//  Created by Tatiana Kornilova on 16.04.2025.
//

import SwiftUI
import MapKit

struct SearchableMap: View {
    // --- State Variables ---
    @State private var locationService = LocationService()
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedResult: SearchResult?
    @State private var isSheetPresented: Bool = true
    @State private var showSearchButton: Bool = false
    @State private var lookAroundScene: MKLookAroundScene?
   
    // Computed property
    var searchResults: [SearchResult] { locationService.searchResults }

    var body: some View {
        Map(position: $position, selection: $selectedResult) {
            // Map content: Markers for search results
            ForEach(searchResults) { result in
                Marker(result.name, coordinate: result.location)
                    .tag(result)
            }
        }
        // --- Apply Modifiers Directly to Map ---
        .mapStyle(.standard(elevation: .realistic))
        
        // --- State Change Handlers ---
        .onChange(of: searchResults) { _, newResults in handleSearchResultsChange(newResults) }
        .onChange(of: selectedResult) { _, newValue in handleSelectionChange(newValue) }
        .task(id: selectedResult?.id) { await fetchLookAroundScene(for: selectedResult) } // Robust fetch

        // --- Search Button Overlay ---
        .overlay(alignment: .topTrailing) {
             // Use computed property for the button content
             searchButtonOverlay
        }
        // Apply animation specifically for the button's appearance/disappearance
        .animation(.easeInOut, value: showSearchButton)
        
        // --- Look Around Panel using safeAreaInset ---
        .safeAreaInset(edge: .bottom) {
            // Conditionally display the panel using the computed property
            lookAroundPanel // Ensures animation applies correctly
        }

        // --- Bottom Sheet Presentation ---
        .sheet(isPresented: $isSheetPresented, onDismiss: handleSheetDismiss) {
            // Use computed property for sheet content
            sheetContent
        }

        // --- Optional: Error Alert ---
        .alert("Location Service Error", isPresented: locationService.isErrorPresented, presenting: locationService.error) { _ in Button("OK") {} } message: { error in Text(error.localizedDescription) }

    } // End of body


    // MARK: - Computed Properties for Sub-Views (Helps Compiler)

    // Computed property for the Look Around Panel content
    @ViewBuilder
    private var lookAroundPanel: some View {
        if selectedResult != nil { // Condition checked here
            LookAroundPanelView(scene: $lookAroundScene, resultName: selectedResult?.name)
                .frame(height: 150) // Define size here
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .background(.thinMaterial)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(.horizontal) // Add horizontal padding
                .padding(.bottom, 10) // Add some padding from the absolute bottom edge
                .transition(.move(edge: .bottom).combined(with: .opacity)) // Animation transition
        }
    }

    // Computed property for the search button overlay content
    @ViewBuilder
    private var searchButtonOverlay: some View {
        if showSearchButton {
            Button {
                selectedResult = nil
                showSearchButton = false
                isSheetPresented = true
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .padding(12)
                    .background(.thinMaterial, in: Circle())
                    .shadow(radius: 3)
            }
            .padding() // Padding from screen edges
            .transition(.scale.combined(with: .opacity))
        } else {
            EmptyView()
        }
    }

    // Computed property for the sheet's content view
    private var sheetContent: some View {
        SheetView(locationService: locationService)
            .presentationDetents([.height(250), .medium, .large])
            .presentationBackground(.regularMaterial)
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .presentationCornerRadius(15)
            // Optional: .interactiveDismissDisabled()
    }


    // MARK: - Helper Functions / Handlers (Keep As Is)

    private func handleSearchResultsChange(_ newResults: [SearchResult]) {
        if !newResults.isEmpty {
            isSheetPresented = false
            showSearchButton = true
            
            if newResults.count == 1 { selectedResult = newResults.first }
            if let region = locationService.region {
                 withAnimation(.smooth(duration: 0.7)) { position = .region(region) }
             }
        } else {
             showSearchButton = false
        }
    }

    private func handleSelectionChange(_ newValue: SearchResult?) {
        print("Selected result changed to: \(newValue?.name ?? "None")")
         if newValue == nil && !isSheetPresented && !searchResults.isEmpty { showSearchButton = true }
     
         // Fetching handled by .task
    }

    private func handleSheetDismiss() {
        print("Sheet dismissed manually.")
        if !locationService.searchResults.isEmpty { showSearchButton = true }
    }

    private func fetchLookAroundScene(for result: SearchResult?) async {
        guard let result = result else {
                 self.lookAroundScene = nil
            return
        }
        print("Fetching Look Around scene for \(result.name)...")
        let request = MKLookAroundSceneRequest(coordinate: result.location)
        do {
            let scene = try await request.scene
            self.lookAroundScene = scene
            //----
            isSheetPresented = false
            //----
            print("Look Around scene fetched successfully: \(scene != nil)")
        } catch {
            print("❌ Failed to fetch Look Around scene: \(error.localizedDescription)")
            self.lookAroundScene = nil
        }
    }
}

// MARK: - Extracted Look Around Panel View (Keep As Is)
struct LookAroundPanelView: View {
    @Binding var scene: MKLookAroundScene?
    var resultName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
             if let name = resultName {
                 Text(name)
                     .font(.caption.weight(.semibold))
                     .padding(.horizontal, 8)
                     .padding(.top, 8)
             }
            LookAroundPreview(scene: $scene, allowsNavigation: true, badgePosition: .bottomTrailing)
        }
    }
}

// MARK: - Preview
#Preview { SearchableMap() }

// MARK: - Observable Extension for Alert Binding (Keep As Is)
extension LocationService {
    var isErrorPresented: Binding<Bool> {
        Binding(get: { self.error != nil }, set: { if !$0 { self.error = nil } })
    }
}

// MARK: - Preview
#Preview {
    SearchableMap()
}

