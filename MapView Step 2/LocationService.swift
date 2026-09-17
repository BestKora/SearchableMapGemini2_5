//
//  LocationService.swift
//  MapView Step 2
//

import CoreLocation
import MapKit
import Observation

struct SearchCompletion: Identifiable {
    let completion: MKLocalSearchCompletion

    var id: String { "\(completion.title)|\(completion.subtitle)" }
    var title: String { completion.title }
    var subtitle: String { completion.subtitle }
}

struct SearchResult: Identifiable, Hashable {
    let mapItem: MKMapItem

    var id: String {
        let coordinate = mapItem.placemark.coordinate
        return "\(mapItem.name ?? "Unknown Place")|\(coordinate.latitude)|\(coordinate.longitude)"
    }

    var name: String { mapItem.name ?? "Unknown Place" }
    var location: CLLocationCoordinate2D { mapItem.placemark.coordinate }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

@MainActor
@Observable
final class LocationService: NSObject, MKLocalSearchCompleterDelegate {
    private let completer = MKLocalSearchCompleter()
    private var currentSearch: MKLocalSearch?
    private var searchGeneration = 0

    var completions: [SearchCompletion] = []
    var searchResults: [SearchResult] = []
    var error: Error?
    var region: MKCoordinateRegion?
    var isSearching = false

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }

    func update(queryFragment: String) {
        error = nil
        completions = []
        completer.queryFragment = queryFragment.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results.map(SearchCompletion.init)
        error = nil
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        self.error = error
        completions = []
    }

    func search(with query: String) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmedQuery
        request.resultTypes = [.address, .pointOfInterest]
        await startSearch(request)
    }

    func search(for completion: SearchCompletion) async {
        await startSearch(MKLocalSearch.Request(completion: completion.completion))
    }

    func clearSearch() {
        currentSearch?.cancel()
        currentSearch = nil
        searchGeneration += 1
        completions = []
        searchResults = []
        region = nil
        error = nil
        isSearching = false
    }

    private func startSearch(_ request: MKLocalSearch.Request) async {
        currentSearch?.cancel()
        searchGeneration += 1
        let generation = searchGeneration
        let search = MKLocalSearch(request: request)
        currentSearch = search
        isSearching = true
        error = nil

        do {
            let response = try await search.start()
            guard generation == searchGeneration else { return }

            let results = response.mapItems.compactMap { mapItem -> SearchResult? in
                guard CLLocationCoordinate2DIsValid(mapItem.placemark.coordinate) else { return nil }
                return SearchResult(mapItem: mapItem)
            }
            searchResults = results
            region = region(enclosing: results)
            completions = []
        } catch is CancellationError {
            // A newer request has replaced this one; preserve its state.
        } catch {
            guard generation == searchGeneration else { return }
            error = error
            searchResults = []
            region = nil
        }

        guard generation == searchGeneration else { return }
        currentSearch = nil
        isSearching = false
    }

    private func region(enclosing results: [SearchResult]) -> MKCoordinateRegion? {
        guard let first = results.first else { return nil }
        guard results.count > 1 else {
            return MKCoordinateRegion(center: first.location, latitudinalMeters: 1_000, longitudinalMeters: 1_000)
        }

        let mapRect = results.reduce(MKMapRect.null) { rect, result in
            rect.union(MKMapRect(origin: MKMapPoint(result.location), size: .init(width: 0, height: 0)))
        }
        return MKCoordinateRegion(mapRect).expanded(by: 1.25)
    }
}

private extension MKCoordinateRegion {
    func expanded(by factor: CLLocationDegrees) -> Self {
        .init(
            center: center,
            span: .init(
                latitudeDelta: max(span.latitudeDelta * factor, 0.01),
                longitudeDelta: max(span.longitudeDelta * factor, 0.01)
            )
        )
    }
}
