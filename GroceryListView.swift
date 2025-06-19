import SwiftUI

struct GroceryListView: View {
    @ObservedObject var groceryListManager: GroceryListManager
    var selectedStore: String

    @State private var newItem: String = ""
    @FocusState private var isItemFieldFocused: Bool

    var body: some View {
        VStack {
            List {
                ForEach(groceryListManager.items(for: selectedStore), id: \.self) { item in
                    Text(item)
                }
                .onDelete { offsets in
                    groceryListManager.removeItem(at: offsets, from: selectedStore)
                }
            }
            .frame(maxHeight: 300)

            HStack {
                TextField("Add item", text: $newItem)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isItemFieldFocused)
                Button("Add") {
                    let trimmed = newItem.trimmingCharacters(in: .whitespaces)
                    guard !trimmed.isEmpty else { return }
                    groceryListManager.addItem(trimmed, to: selectedStore)
                    newItem = ""
                    isItemFieldFocused = false // Dismiss keyboard!
                }
                .disabled(selectedStore.isEmpty || newItem.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
        }
    }
}
