//
//  StorePickerScreen.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/25/25.
//
import SwiftUI
import MapKit

struct StorePickerScreen: View {
    var onDone: ([Store]) -> Void

    @State private var newStoreName: String = ""
    @State private var stores: [Store] = []
    @State private var latitude: String = ""
    @State private var longitude: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Add Your Favorite Stores")
                .font(.title2)
            HStack {
                TextField("Store Name", text: $newStoreName)
                TextField("Lat", text: $latitude)
                    .keyboardType(.decimalPad)
                TextField("Lon", text: $longitude)
                    .keyboardType(.decimalPad)
                Button("Add") {
                    guard let lat = Double(latitude),
                          let lon = Double(longitude),
                          !newStoreName.trimmingCharacters(in: .whitespaces).isEmpty
                    else { return }
                    let store = Store(name: newStoreName, latitude: lat, longitude: lon)
                    stores.append(store)
                    newStoreName = ""
                    latitude = ""
                    longitude = ""
                }
            }
            .textFieldStyle(.roundedBorder)
            List {
                ForEach(stores) { store in
                    Text("\(store.name) (\(store.latitude), \(store.longitude))")
                }
                .onDelete { idx in
                    stores.remove(atOffsets: idx)
                }
            }
            Button("Continue") {
                onDone(stores)
            }
            .buttonStyle(.borderedProminent)
            .disabled(stores.isEmpty)
        }
        .padding()
    }
}
