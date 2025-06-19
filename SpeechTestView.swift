//
//  SpeechTestView.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/13/25.
//
import SwiftUI
import Speech
import AVFoundation

struct SpeechTestView: View {
    @State private var recognizedText = ""
    @State private var isListening = false

    // Need to keep these alive for the duration of recognition
    let speechRecognizer = SFSpeechRecognizer()
    let audioEngine = AVAudioEngine()
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?

    var body: some View {
        VStack(spacing: 30) {
            Text("Recognized: \(recognizedText)")
                .padding()

            Button(isListening ? "Stop Listening" : "Start Listening") {
                if isListening {
                    audioEngine.stop()
                    audioEngine.inputNode.removeTap(onBus: 0)
                    isListening = false
                } else {
                    startListening()
                }
            }
            .padding()
            .background(isListening ? Color.red : Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    func startListening() {
        SFSpeechRecognizer.requestAuthorization { status in
            if status == .authorized {
                DispatchQueue.main.async {
                    let request = SFSpeechAudioBufferRecognitionRequest()
                    let inputNode = audioEngine.inputNode

                    let recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
                        if let result = result {
                            recognizedText = result.bestTranscription.formattedString
                        }
                        if error != nil || (result?.isFinal ?? false) {
                            audioEngine.stop()
                            inputNode.removeTap(onBus: 0)
                            isListening = false
                        }
                    }
                    let recordingFormat = inputNode.outputFormat(forBus: 0)
                    inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                        request.append(buffer)
                    }
                    audioEngine.prepare()
                    try? audioEngine.start()
                    isListening = true
                }
            } else {
                recognizedText = "Speech recognition not authorized."
            }
        }
    }
}

