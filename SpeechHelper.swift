//
//  SpeechHelper.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/13/25.
//
import Foundation
import AVFoundation

class SpeechHelper: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    var onFinish: (() -> Void)?
    private var synthesizer: AVSpeechSynthesizer?

    func speak(_ text: String, onFinish: @escaping () -> Void) {
        let utterance = AVSpeechUtterance(string: text)
        let synthesizer = AVSpeechSynthesizer()
        self.synthesizer = synthesizer // keep a strong reference!
        self.onFinish = onFinish
        synthesizer.delegate = self
        synthesizer.speak(utterance)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        onFinish?()
        onFinish = nil
        self.synthesizer = nil // release reference
    }
}

