//
//  ProactiveAssistantApp.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/26/25.
//
import SwiftUI

@main
struct ProactiveAssistantApp: App {
    @StateObject private var appData = AppData()
    @StateObject private var contextManager: ContextManager

    init() {
        let appData = AppData()
        _appData = StateObject(wrappedValue: appData)
        _contextManager = StateObject(wrappedValue: ContextManager(appData: appData))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
                .environmentObject(contextManager)
        }
    }
}
