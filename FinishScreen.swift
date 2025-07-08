//
//  FinishScreen.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/26/25.
//
import SwiftUI

struct FinishScreen: View {
    var onFinish: () -> Void
    var body: some View {
        VStack(spacing: 24) {
            Text("You’re All Set!")
                .font(.largeTitle)
                .padding(.top, 48)
            Text("Your grocery store lists are ready. Enjoy hands-free shopping!")
                .multilineTextAlignment(.center)
                .padding(.bottom, 36)
            Button("Start Using the App") {
                onFinish()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
