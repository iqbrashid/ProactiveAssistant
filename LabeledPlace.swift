//
//  LabeledPlace.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/11/25.
//
import Foundation
import CoreLocation

struct LabeledPlace: Codable, Equatable {
    let type: String
    let latitude: Double
    let longitude: Double
}

