//
//  AddItemSheet.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/26/25.
//

import SwiftUI

struct AddItemSheet: View {
    @EnvironmentObject var appData: AppData
    let store: Store
    @Environment(\.dismiss) var dismiss
    @State private var newItem: String = ""
    @State private var editingIndex: Int?
    @State private var editedText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Add items to \(store.name)")
                    .font(.headline)
                HStack {
                    TextField("Item name", text: $newItem)
                        .textFieldStyle(.roundedBorder)
                    Button("Add") {
                        appData.addItem(newItem, to: store)
                        newItem = ""
                    }
                    .disabled(newItem.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                List {
                    ForEach(Array(appData.groceryLists[store.id] ?? []).indices, id: \.self) { idx in
                        HStack {
                            if editingIndex == idx {
                                TextField("Edit Item", text: $editedText, onCommit: {
                                    if !editedText.trimmingCharacters(in: .whitespaces).isEmpty {
                                        appData.updateItem(at: idx, in: store, to: editedText)
                                    }
                                    editingIndex = nil
                                })
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.none)
                            } else {
                                Text(appData.groceryLists[store.id]?[idx] ?? "")
                                Spacer()
                                Button(action: {
                                    editingIndex = idx
                                    editedText = appData.groceryLists[store.id]?[idx] ?? ""
                                }) {
                                    Image(systemName: "pencil")
                                }
                                Button(action: {
                                    appData.removeItem(at: idx, from: store)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Manage \(store.name)")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
