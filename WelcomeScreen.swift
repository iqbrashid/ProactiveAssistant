//
//  WelcomeScreen.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/25/25.
//
import SwiftUI

struct WelcomeScreen: View {
    var onNext: () -> Void
    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to Proactive Assistant")
                .font(.largeTitle)
            Text("Your proactive, context-aware assistant for shopping and more.")
                .multilineTextAlignment(.center)
            Button("Get Started", action: onNext)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
