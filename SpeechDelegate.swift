//
//  SpeechDelegate.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/14/25.
//

import AVFoundation

class SpeechDelegate: NSObject, AVSpeechSynthesizerDelegate, ObservableObject {
    @Published var isSpeaking: Bool = false

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
    }
}
