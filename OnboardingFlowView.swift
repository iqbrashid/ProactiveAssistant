//
//  OnboardingFlowView.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/25/25.
//
import SwiftUI

enum OnboardingStep {
    case welcome, permissions, addStores, createLists, finish
}

struct OnboardingFlowView: View {
    @EnvironmentObject var appData: AppData
    @State private var step: OnboardingStep = .welcome
    @State private var showMapStorePicker = false
    @State private var storesCreated: Bool = false // Tracks whether at least one store was added
    @State private var currentStoreIndex: Int = 0

    var body: some View {
        switch step {
        case .welcome:
            WelcomeScreen(onNext: { step = .permissions })
        case .permissions:
            PermissionsScreen(onNext: { step = .addStores })
        case .addStores:
            // We launch the sheet as soon as this step is hit.
            EmptyView()
                .sheet(isPresented: $showMapStorePicker) {
                    MapStorePickerView(isPresented: $showMapStorePicker)
                        .environmentObject(appData)
                }
                .onAppear {
                    showMapStorePicker = true
                }
                .onChange(of: showMapStorePicker) { newValue in
                    // When sheet is dismissed and stores exist, continue
                    if !newValue, !appData.stores.isEmpty {
                        step = .createLists
                    }
                }
        case .createLists:
            if currentStoreIndex < appData.stores.count {
                ListCreationScreen(
                    store: appData.stores[currentStoreIndex],
                    onDone: {
                        if currentStoreIndex + 1 < appData.stores.count {
                            currentStoreIndex += 1
                        } else {
                            step = .finish
                        }
                    }
                )
            }
        case .finish:
            FinishScreen(onFinish: {
                appData.onboardingComplete = true
                appData.save()
            })
        }
    }
}

 
