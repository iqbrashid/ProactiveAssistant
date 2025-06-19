//
//  LabeledPlaceStore.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/11/25.
//
import Foundation

class LabeledPlaceStore {
    static let shared = LabeledPlaceStore()
    private let key = "labeledPlaces"
    
    func save(place: LabeledPlace) {
        var places = load()
        if !places.contains(place) {
            places.append(place)
            if let data = try? JSONEncoder().encode(places) {
                UserDefaults.standard.set(data, forKey: key)
            }
        }
    }
    
    func load() -> [LabeledPlace] {
        if let data = UserDefaults.standard.data(forKey: key),
           let places = try? JSONDecoder().decode([LabeledPlace].self, from: data) {
            return places
        }
        return []
    }
}

