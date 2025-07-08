//
//  AppData.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/26/25.
//
import Foundation

class AppData: ObservableObject {
    @Published var stores: [Store] = []
    @Published var groceryLists: [UUID: [String]] = [:]
    @Published var onboardingComplete: Bool = false

    // Persistence
    private let storesKey = "stores_v2"
    private let listsKey = "lists_v2"
    private let onboardingKey = "onboarding_v2"

    init() {
        load()
    }

    func addStore(_ store: Store) {
        if !stores.contains(store) {
            stores.append(store)
            if groceryLists[store.id] == nil {
                groceryLists[store.id] = []
            }
            save()
        }
    }

    func removeStore(_ store: Store) {
        stores.removeAll { $0 == store }
        groceryLists[store.id] = nil
        save()
    }

    func addItem(_ item: String, to store: Store) {
        let trimmed = item.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        groceryLists[store.id, default: []].append(trimmed)
        objectWillChange.send()
        save()
    }

    func removeItem(_ item: String, from store: Store) {
        groceryLists[store.id]?.removeAll { $0 == item }
        objectWillChange.send()
        save()
    }

    func save() {
        // Save stores
        if let data = try? JSONEncoder().encode(stores) {
            UserDefaults.standard.set(data, forKey: storesKey)
        }
        // Save lists
        if let data = try? JSONEncoder().encode(groceryLists) {
            UserDefaults.standard.set(data, forKey: listsKey)
        }
        // Save onboarding
        UserDefaults.standard.set(onboardingComplete, forKey: onboardingKey)
    }

    func load() {
        // Load stores
        if let data = UserDefaults.standard.data(forKey: storesKey),
           let decoded = try? JSONDecoder().decode([Store].self, from: data) {
            stores = decoded
        }
        // Load lists
        if let data = UserDefaults.standard.data(forKey: listsKey),
           let decoded = try? JSONDecoder().decode([UUID: [String]].self, from: data) {
            groceryLists = decoded
        }
        // Load onboarding
        onboardingComplete = UserDefaults.standard.bool(forKey: onboardingKey)
    }
   
    func updateItem(at index: Int, in store: Store, to newText: String) {
        guard var items = groceryLists[store.id], items.indices.contains(index) else { return }
        items[index] = newText
        groceryLists[store.id] = items
        objectWillChange.send()
        save()
    }

    func removeItem(at index: Int, from store: Store) {
        guard var items = groceryLists[store.id], items.indices.contains(index) else { return }
        items.remove(at: index)
        groceryLists[store.id] = items
        objectWillChange.send()
        save()
    }
    func editItem(_ oldValue: String, to newValue: String, in store: Store) {
        guard let idx = groceryLists[store.id]?.firstIndex(of: oldValue), !newValue.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        groceryLists[store.id]?[idx] = newValue
        save()
        objectWillChange.send()
    }
}
