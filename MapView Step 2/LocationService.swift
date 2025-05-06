//
//  LocationService.swift
//  MapView Step 2
//
//  Created by Tatiana Kornilova on 16.04.2025.
//

import MapKit
import CoreLocation // Ensure CoreLocation is imported

// Represents a search suggestion
struct SearchCompletions: Identifiable {
    let id = UUID()
    let title: String
    let subTitle: String
    // We can store the original MKLocalSearchCompletion if needed for more complex actions later
    // let mapKitCompletion: MKLocalSearchCompletion
}

// Represents a pin/marker on the map
struct SearchResult: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let location: CLLocationCoordinate2D
    let mapItem: MKMapItem // Store the original map item

    // Conformance for Map selection and comparison
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@Observable // Use @Observable for modern Swift concurrency state management
class LocationService: NSObject, MKLocalSearchCompleterDelegate {
    private let completer: MKLocalSearchCompleter
    private var currentSearch: MKLocalSearch?

    // --- Published Properties (Observable updates views) ---
    var completions = [SearchCompletions]()
    var searchResults = [SearchResult]()
    var error: Error?
    var region: MKCoordinateRegion? // Optional region to focus the map

    // --- Initialization ---
    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        self.completer.delegate = self
        // Configure completer (optional: filter results, etc.)
        self.completer.resultTypes = [ .pointOfInterest]//[.address, .pointOfInterest]
        // Optionally filter by region if needed
        // self.completer.region = MKCoordinateRegion(.world)
    }

    // --- Public Methods ---
    func update(queryFragment: String) {
        // Reset previous results and errors on new query
        self.completions = []
        self.error = nil
        completer.queryFragment = queryFragment
    }

    // --- MKLocalSearchCompleterDelegate ---
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Map completer results to our SearchCompletions struct
        self.completions = completer.results.map { completion in
            // Extracting title parts can be useful if subtitle is long
            // let title = completion.title
            // let subTitle = completion.subtitle
            .init(title: completion.title, subTitle: completion.subtitle /*, mapKitCompletion: completion */)
        }
        self.error = nil
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("❌ Completer failed with error: \(error.localizedDescription)")
        self.error = error
        self.completions = []
    }

    // --- Search Execution ---
    func search ( with query: String) async {
        // Ensure query isn't empty
        guard !query.isEmpty else {
             self.searchResults = []
             self.region = nil
             return
        }

        // Cancel any ongoing search
        currentSearch?.cancel()

        // Prepare the search request
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
       // request.resultTypes = [.address, .pointOfInterest]
        request.resultTypes = [ .pointOfInterest]
         // You could bias search results towards the current map view region if desired
         // if let mapRegion = self.currentMapRegion { // Assuming you have a way to get the current map region
         //     request.region = mapRegion
         // }

        let search = MKLocalSearch(request: request)
        self.currentSearch = search
        self.error = nil // Reset error before search

        print("➡️ Performing search for: \(query)")

        do {
            let response = try await search.start()
            self.currentSearch = nil // Clear current search reference

            // Map MKMapItems to our SearchResult struct
            self.searchResults = response.mapItems.compactMap { mapItem in
                guard let location = mapItem.placemark.location?.coordinate else { return nil }
                return SearchResult(name: mapItem.name ?? "Unknown Place", location: location, mapItem: mapItem)
            }

            // Calculate a region encompassing all results
            self.region = calculateRegion(for: self.searchResults)

            print("✅ Search successful, found \(self.searchResults.count) results.")

        } catch {
            self.currentSearch = nil // Clear current search reference
            // Handle errors, including cancellation
            if let nsError = error as NSError?, nsError.code == NSUserCancelledError {
                 print(" Canceled search.")
                 // Don't necessarily clear results if cancelled due to new search starting
            } else if let mkError = error as? MKError, mkError.code == .placemarkNotFound {
                print("ℹ️ No results found for '\(query)'.")
                self.searchResults = []
                self.region = nil
                 // Optionally set a specific "not found" error state instead of generic error
            } else {
                print("❌ Search failed with error: \(error.localizedDescription)")
                self.error = error
                self.searchResults = []
                self.region = nil
            }
        }
    }

    // Helper function to search based on a completion item
    func search(for completion: SearchCompletions) async {
        // Create a more specific query from the completion
        let query = "\(completion.title), \(completion.subTitle)"
        await search(with: query)
    }


    // --- Helper for calculating region ---
    private func calculateRegion(for results: [SearchResult]) -> MKCoordinateRegion? {
        guard !results.isEmpty else { return nil }

        if results.count == 1, let firstResult = results.first {
            // For a single result, center on it with a reasonable span
             return MKCoordinateRegion(center: firstResult.location, latitudinalMeters: 1000, longitudinalMeters: 1000) // 1km span
        } else {
            // For multiple results, calculate bounding box
            var minLat = 90.0
            var maxLat = -90.0
            var minLon = 180.0
            var maxLon = -180.0

            for result in results {
                let coord = result.location
                minLat = min(minLat, coord.latitude)
                maxLat = max(maxLat, coord.latitude)
                minLon = min(minLon, coord.longitude)
                maxLon = max(maxLon, coord.longitude)
            }

            let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2.0, longitude: (minLon + maxLon) / 2.0)
            let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.4, longitudeDelta: (maxLon - minLon) * 1.4) // Add padding (* 1.4)

            return MKCoordinateRegion(center: center, span: span)
        }
    }
}
