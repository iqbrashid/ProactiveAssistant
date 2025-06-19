import Foundation

class GroceryListManager: ObservableObject {
    @Published var lists: [String: [String]] = [:] {
        didSet {
            saveLists()
        }
    }
    
    init() {
        loadLists()
    }
    
    func addItem(_ item: String, to store: String) {
        var storeList = lists[store] ?? []
        storeList.append(item)
        lists[store] = storeList
    }
    
    func removeItem(at offsets: IndexSet, from store: String) {
        guard var storeList = lists[store] else { return }
        storeList.remove(atOffsets: offsets)
        lists[store] = storeList
    }
    
    func items(for store: String) -> [String] {
        lists[store] ?? []
    }
    
    // MARK: - Persistence
    
    private let listsKey = "GroceryListsKey"
    
    private func saveLists() {
        if let data = try? JSONEncoder().encode(lists) {
            UserDefaults.standard.set(data, forKey: listsKey)
        }
    }
    
    private func loadLists() {
        if let data = UserDefaults.standard.data(forKey: listsKey),
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            lists = decoded
        } else {
            // Default store on first launch
            lists = ["Trader Joe's": []]
        }
    }
}
