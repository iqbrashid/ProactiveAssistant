//
//  PermissionsScreen.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/25/25.
//
import SwiftUI

struct PermissionsScreen: View {
    var onNext: () -> Void
    var body: some View {
        VStack(spacing: 30) {
            Text("Permissions Needed")
                .font(.title2)
            Text("To proactively help you, we need access to your location (for store entry detection).")
                .multilineTextAlignment(.center)
            Button("Allow & Continue") {
                // Here you’d actually request permissions, but for demo:
                onNext()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
