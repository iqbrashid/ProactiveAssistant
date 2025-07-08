//
//  StoreSearchManager.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/25/25.
//
import Foundation
import MapKit
import Combine

class StoreSearchManager: ObservableObject {
    @Published var searchResults: [MKMapItem] = []
    @Published var searchQuery: String = ""
    @Published var isSearching: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Live search as query changes
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] query in
                guard let self = self else { return }
                self.search(for: query)
            }
            .store(in: &cancellables)
    }
    
    func search(for query: String) {
        guard !query.isEmpty else {
            self.searchResults = []
            return
        }
        isSearching = true
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.resultTypes = .pointOfInterest
        let search = MKLocalSearch(request: request)
        search.start { [weak self] (response, error) in
            DispatchQueue.main.async {
                self?.isSearching = false
                self?.searchResults = response?.mapItems ?? []
            }
        }
    }
}

