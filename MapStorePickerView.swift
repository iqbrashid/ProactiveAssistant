//
//  MapStorePickerView.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 7/1/25.
//

import SwiftUI
import MapKit

// For Xcode 15+/iOS 17+, this Identifiable extension avoids the "conform to Identifiable" error for Map annotations.
extension MKMapItem: Identifiable {
    public var id: String {
        let c = placemark.coordinate
        return "\(name ?? "Unknown")-\(c.latitude)-\(c.longitude)"
    }
}

struct MapStorePickerView: View {
    @EnvironmentObject var appData: AppData
    @Binding var isPresented: Bool
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.3352, longitude: -122.0096), // Cupertino, as example
        span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
    )
    @State private var searchText: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var selectedStores: [Store] = []

    var body: some View {
        NavigationView {
            VStack {
                Text("Search & Add Stores")
                    .font(.headline)

                HStack {
                    TextField("Search grocery...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.search)
                        .onSubmit { search() }
                    Button("Search") { search() }
                        .disabled(searchText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)

                Map(coordinateRegion: $region, annotationItems: searchResults) { item in
                    MapAnnotation(coordinate: item.placemark.coordinate) {
                        Button(action: {
                            let placeName = item.name ?? "Unknown"
                            let store = Store(
                                name: placeName,
                                latitude: item.placemark.coordinate.latitude,
                                longitude: item.placemark.coordinate.longitude,
                                radius: 150
                            )
                            // Avoid duplicates
                            if !selectedStores.contains(where: { $0.name == store.name }) {
                                selectedStores.append(store)
                            }
                        }) {
                            Image(systemName: "mappin")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                }
                .frame(height: 260)

                List {
                    ForEach(selectedStores, id: \.id) { store in
                        Text(store.name)
                    }
                    .onDelete { idx in
                        selectedStores.remove(atOffsets: idx)
                    }
                }

                Button("Save Stores") {
                    for store in selectedStores {
                        appData.addStore(store)
                    }
                    isPresented = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedStores.isEmpty)
                .padding(.vertical)
            }
            .navigationTitle("Map Store Picker")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
            .padding(.bottom)
        }
    }

    func search() {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText

        // For iOS 16+ limit to likely grocery stores. You may only have .foodMarket
        if #available(iOS 16.0, *) {
            request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.foodMarket])
        }
        request.region = region

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let items = response?.mapItems {
                DispatchQueue.main.async {
                    self.searchResults = items
                }
            }
        }
    }
}
