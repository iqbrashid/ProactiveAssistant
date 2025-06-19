//
//  VoiceCommandManager.swift
//  ProactiveAssistant
//
//  Created by Rashid Iqbal on 6/13/25.
//

import Foundation
import Speech
import AVFoundation

class VoiceCommandManager: NSObject, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // For debugging state
    @Published var isListening = false
    @Published var lastRecognizedText = ""
    @Published var lastError: String = ""

    func listenForYes(completion: @escaping (Bool) -> Void) {
        print("Requesting speech authorization...")
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if authStatus == .authorized {
                    print("Speech authorization granted.")
                    self.startRecording(completion: completion)
                } else {
                    print("Speech authorization denied or not determined: \(authStatus.rawValue)")
                    self.lastError = "Speech authorization denied or not determined: \(authStatus.rawValue)"
                    completion(false)
                }
            }
        }
    }

    private func startRecording(completion: @escaping (Bool) -> Void) {
        print("Preparing to start recording...")

        // Ensure no previous audio is running
        stopRecording()
        
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("Audio session set up for recording.")
        } catch {
            print("Audio session setup failed: \(error.localizedDescription)")
            lastError = "Audio session setup failed: \(error.localizedDescription)"
            completion(false)
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create recognition request.")
            lastError = "Unable to create recognition request."
            completion(false)
            return
        }
        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0) // Remove any existing taps before starting
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            isListening = true
            print("Audio engine started. Listening for 'yes'...")
        } catch {
            print("AudioEngine couldn't start: \(error.localizedDescription)")
            lastError = "AudioEngine couldn't start: \(error.localizedDescription)"
            completion(false)
            return
        }

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                let spoken = result.bestTranscription.formattedString.lowercased()
                print("Recognized: \(spoken)")
                self.lastRecognizedText = spoken
                if spoken.contains("yes") {
                    print("Heard 'yes'! Stopping recognition.")
                    self.stopRecording()
                    completion(true)
                }
            }
            if let error = error {
                print("Speech recognition error: \(error.localizedDescription)")
                self.lastError = "Speech recognition error: \(error.localizedDescription)"
                self.stopRecording()
                completion(false)
            }
        }

        // Safety: Stop listening after 7 seconds if no result
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) { [weak self] in
            guard let self = self else { return }
            if self.isListening {
                print("Timeout reached, stopping recognition.")
                self.stopRecording()
                completion(false)
            }
        }
    }

    func stopRecording() {
        if audioEngine.isRunning {
            print("Stopping audio engine...")
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        isListening = false
    }
}
