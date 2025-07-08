//
//  Store.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/30/25.
//
// Store.swift
import Foundation
import CoreLocation

struct Store: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var radius: Double

    init(id: UUID = UUID(), name: String, latitude: Double, longitude: Double, radius: Double = 150) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

