import SwiftUI
import AVFoundation
import UserNotifications

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate, ObservableObject {
    @Published var isSpeaking: Bool = false
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) { isSpeaking = true }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) { isSpeaking = false }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) { isSpeaking = false }
}

struct ContentView: View {
    @StateObject var groceryListManager = GroceryListManager()
    @StateObject var contextManager = ContextManager()
    @State private var selectedStore: String = "Trader Joe's"
    @State private var newStoreName: String = ""
    @State private var showAddStoreAlert = false
    @State private var speechSynthesizer = AVSpeechSynthesizer()
    @StateObject private var speechDelegate = SpeechDelegate()
    @State private var didCheckNotifications = false

    var body: some View {
        VStack(spacing: 24) {
            Picker("Store", selection: $selectedStore) {
                ForEach(Array(groceryListManager.lists.keys.sorted()), id: \.self) { store in
                    Text(store).tag(store)
                }
                Text("+ Add Store").tag("+ Add Store")
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedStore) {
                if selectedStore == "+ Add Store" {
                    showAddStoreAlert = true
                } else if !selectedStore.isEmpty {
                    if !speechDelegate.isSpeaking {
                        speakList(for: selectedStore)
                    }
                }
            }

            GroceryListView(groceryListManager: groceryListManager, selectedStore: selectedStore)
                .padding(.bottom)

            Button {
                speakList(for: selectedStore)
            } label: {
                HStack {
                    if speechDelegate.isSpeaking {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 20, height: 20)
                    }
                    Text("Read List Aloud")
                }
            }
            .disabled(groceryListManager.items(for: selectedStore).isEmpty || speechDelegate.isSpeaking)
            .padding()

            Button("Simulate Trader Joe's Entry") {
                contextManager.detectedStore = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    contextManager.detectedStore = "Trader Joe's"
                }
            }
            .padding()
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        // Listen for context (store) changes from ContextManager
        .onChange(of: contextManager.detectedStore) { newStore in
            guard let store = newStore else { return }
            selectedStore = store
        }
        .onAppear {
            requestNotificationPermission()
            if groceryListManager.lists.isEmpty {
                groceryListManager.lists["Trader Joe's"] = []
                selectedStore = "Trader Joe's"
            } else if !groceryListManager.lists.keys.contains(selectedStore) {
                selectedStore = groceryListManager.lists.keys.first ?? "Trader Joe's"
            }
            speechSynthesizer.delegate = speechDelegate

            // Check for notification response ONLY on first launch in session
            if !didCheckNotifications {
                didCheckNotifications = true
                UNUserNotificationCenter.current().getDeliveredNotifications { notifs in
                    for notif in notifs {
                        if notif.request.content.title == "Grocery List Reminder" {
                            // Clear notification and trigger speech
                            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [notif.request.identifier])
                            DispatchQueue.main.async {
                                speakList(for: selectedStore)
                            }
                        }
                    }
                }
            }
        }
        .alert("Add a new store", isPresented: $showAddStoreAlert, actions: {
            TextField("Store name", text: $newStoreName)
            Button("Add", action: {
                let trimmed = newStoreName.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                if groceryListManager.lists[trimmed] == nil {
                    groceryListManager.lists[trimmed] = []
                }
                selectedStore = trimmed
                newStoreName = ""
            })
            Button("Cancel", role: .cancel, action: {
                selectedStore = groceryListManager.lists.keys.sorted().first ?? "Trader Joe's"
            })
        })
    }

    // MARK: - Notification permission helper

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            } else {
                print("Notification permission granted: \(granted)")
            }
        }
    }

    // MARK: - Speak

    func speakList(for store: String) {
        let items = groceryListManager.items(for: store)
        guard !items.isEmpty else { return }
        let listText = "Your \(store) grocery list is: " + items.joined(separator: ", ")
        let utterance = AVSpeechUtterance(string: listText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(utterance)
    }
}
