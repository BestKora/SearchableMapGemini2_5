//
//  SearchableMap.swift
//  MapView Step 2
//

import MapKit
import SwiftUI

struct SearchableMap: View {
    @State private var locationService = LocationService()
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedResult: SearchResult?
    @State private var isSheetPresented = true
    @State private var showSearchButton = false
    @State private var lookAroundScene: MKLookAroundScene?

    var body: some View {
        Map(position: $position, selection: $selectedResult) {
            ForEach(locationService.searchResults) { result in
                Marker(result.name, coordinate: result.location)
                    .tag(result)
            }
        }
        .mapStyle(.standard(elevation: .realistic))
        .onChange(of: locationService.searchResults) { _, results in
            handleSearchResultsChange(results)
        }
        .onChange(of: selectedResult) { _, result in
            if result == nil, !isSheetPresented, !locationService.searchResults.isEmpty {
                showSearchButton = true
            }
        }
        .task(id: selectedResult?.id) {
            await fetchLookAroundScene(for: selectedResult)
        }
        .overlay(alignment: .topTrailing) {
            if showSearchButton {
                Button {
                    selectedResult = nil
                    lookAroundScene = nil
                    isSheetPresented = true
                    showSearchButton = false
                } label: {
                    Label("New search", systemImage: "magnifyingglass")
                        .labelStyle(.iconOnly)
                        .font(.title2)
                        .padding(12)
                        .background(.thinMaterial, in: Circle())
                        .shadow(radius: 3)
                }
                .accessibilityLabel("Start a new search")
                .padding()
                .transition(.scale.combined(with: .opacity))
            }
        }
        .safeAreaInset(edge: .bottom) {
            if selectedResult != nil {
                LookAroundPanelView(scene: $lookAroundScene, resultName: selectedResult?.name)
                    .frame(height: 170)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: showSearchButton)
        .animation(.easeInOut, value: selectedResult?.id)
        .sheet(isPresented: $isSheetPresented, onDismiss: handleSheetDismiss) {
            SheetView(locationService: locationService)
                .presentationDetents([.height(250), .medium, .large])
                .presentationBackground(.regularMaterial)
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationCornerRadius(16)
        }
        .alert("Location Service Error", isPresented: locationService.isErrorPresented, presenting: locationService.error) { _ in
            Button("OK") {}
        } message: { error in
            Text(error.localizedDescription)
        }
    }

    private func handleSearchResultsChange(_ results: [SearchResult]) {
        guard !results.isEmpty else { return }

        isSheetPresented = false
        showSearchButton = true
        selectedResult = results.count == 1 ? results[0] : nil
        if let region = locationService.region {
            withAnimation(.smooth(duration: 0.7)) {
                position = .region(region)
            }
        }
    }

    private func handleSheetDismiss() {
        showSearchButton = !locationService.searchResults.isEmpty
    }

    private func fetchLookAroundScene(for result: SearchResult?) async {
        guard let result else {
            lookAroundScene = nil
            return
        }

        let resultID = result.id
        do {
            let scene = try await MKLookAroundSceneRequest(coordinate: result.location).scene
            guard !Task.isCancelled, selectedResult?.id == resultID else { return }
            lookAroundScene = scene
        } catch {
            guard !Task.isCancelled, selectedResult?.id == resultID else { return }
            lookAroundScene = nil
        }
    }
}

struct LookAroundPanelView: View {
    @Binding var scene: MKLookAroundScene?
    let resultName: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let resultName {
                Text(resultName)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.top, 8)
            }
            LookAroundPreview(scene: $scene, allowsNavigation: true, badgePosition: .bottomTrailing)
        }
        .background(.thinMaterial)
    }
}

extension LocationService {
    var isErrorPresented: Binding<Bool> {
        Binding(get: { error != nil }, set: { if !$0 { error = nil } })
    }
}

#Preview {
    SearchableMap()
}
