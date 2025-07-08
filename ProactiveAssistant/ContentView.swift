import SwiftUI
import AVFoundation

struct ContentView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var contextManager: ContextManager
    @State private var showStorePicker = false
    @State private var editingItem: (store: Store, oldValue: String)? = nil
    @State private var editedText: String = ""
    @State private var showAddItemSheet: Store? = nil
    @State private var storeToDelete: Store? = nil
    @State private var showDeleteStoreAlert = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()

    var body: some View {
        NavigationView {
            List {
                if appData.stores.isEmpty {
                    Text("No stores yet. Tap \"Manage Stores\" to add your first store!")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(appData.stores) { store in
                        StoreSection(
                            store: store,
                            editingItem: $editingItem,
                            editedText: $editedText,
                            showAddItemSheet: $showAddItemSheet,
                            storeToDelete: $storeToDelete,
                            showDeleteStoreAlert: $showDeleteStoreAlert,
                            speakList: speakList
                        )
                        .environmentObject(appData)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Stores & Lists")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Manage Stores") {
                        showStorePicker = true
                    }
                }
            }
        }
        .sheet(isPresented: $showStorePicker) {
            MapStorePickerView(isPresented: $showStorePicker)
                .environmentObject(appData)
        }
        .sheet(item: $showAddItemSheet) { store in
            AddItemSheet(store: store)
                .environmentObject(appData)
        }
        .alert("Edit Item", isPresented: Binding<Bool>(
            get: { editingItem != nil },
            set: { if !$0 { editingItem = nil } }
        )) {
            TextField("Item", text: $editedText)
            Button("Save") {
                if let (store, oldValue) = editingItem, !editedText.trimmingCharacters(in: .whitespaces).isEmpty {
                    appData.editItem(oldValue, to: editedText, in: store)
                }
                editingItem = nil
            }
            Button("Cancel", role: .cancel) {
                editingItem = nil
            }
        }
        .alert("Delete Store", isPresented: $showDeleteStoreAlert) {
            Button("Delete", role: .destructive) {
                if let store = storeToDelete {
                    appData.removeStore(store)
                }
                storeToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                storeToDelete = nil
            }
        } message: {
            if let store = storeToDelete, let items = appData.groceryLists[store.id], !items.isEmpty {
                Text("Are you sure you want to remove \"\(store.name)\"? This will also delete \(items.count) item(s) in the list.")
            } else {
                Text("Are you sure you want to remove this store?")
            }
        }
        .onChange(of: contextManager.detectedStoreID) { newID in
            guard let storeID = newID,
                  let store = appData.stores.first(where: { $0.id == storeID }) else { return }
            speakList(for: store)
        }
    }

    func speakList(for store: Store) {
        let items = appData.groceryLists[store.id] ?? []
        guard !items.isEmpty else { return }
        let listText = "Your \(store.name) grocery list is: " + items.joined(separator: ", ")
        let utterance = AVSpeechUtterance(string: listText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(utterance)
    }
}

// === Subview: StoreSection ===
struct StoreSection: View {
    let store: Store
    @EnvironmentObject var appData: AppData
    @Binding var editingItem: (store: Store, oldValue: String)?
    @Binding var editedText: String
    @Binding var showAddItemSheet: Store?
    @Binding var storeToDelete: Store?
    @Binding var showDeleteStoreAlert: Bool
    var speakList: (Store) -> Void

    var body: some View {
        Section(
            header: HStack {
                Text(store.name)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    storeToDelete = store
                    showDeleteStoreAlert = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        ) {
            ForEach(appData.groceryLists[store.id] ?? [], id: \.self) { item in
                HStack {
                    Text(item)
                    Spacer()
                    Button(action: {
                        editingItem = (store, item)
                        editedText = item
                    }) {
                        Image(systemName: "pencil")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    Button(action: {
                        appData.removeItem(item, from: store)
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .onDelete { idx in
                if let first = idx.first {
                    let item = appData.groceryLists[store.id]?[first]
                    if let item = item {
                        appData.removeItem(item, from: store)
                    }
                }
            }

            Button(action: { showAddItemSheet = store }) {
                Label("Add Item", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.bordered)
            .padding(.vertical, 4)

            Button("Listen to List") {
                speakList(store)
            }
            .padding(.vertical, 4)
        }
    }
}
