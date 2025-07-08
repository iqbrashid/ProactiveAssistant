//
//  ListCreationScreen.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/26/25.
//
import SwiftUI

struct ListCreationScreen: View {
    let store: Store
    var onDone: () -> Void

    @EnvironmentObject var appData: AppData
    @State private var newItem: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Add items for \(store.name)")
                .font(.title2)
            HStack {
                TextField("e.g. Milk", text: $newItem)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.done)
                Button("Add") {
                    let item = newItem.trimmingCharacters(in: .whitespaces)
                    guard !item.isEmpty else { return }
                    appData.addItem(item, to: store)
                    newItem = ""
                }
                .disabled(newItem.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            List {
                ForEach(appData.groceryLists[store.id] ?? [], id: \.self) { item in
                    Text(item)
                }
                .onDelete { idx in
                    if var items = appData.groceryLists[store.id] {
                        items.remove(atOffsets: idx)
                        appData.groceryLists[store.id] = items
                        appData.objectWillChange.send()
                    }
                }
            }
            .frame(height: 200)
            Button("Done") {
                onDone()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
        }
        .padding()
    }
}
