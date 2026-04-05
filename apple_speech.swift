#!/usr/bin/env swift
// Apple Speech Recognition backend for ccplugin-voice-input
import Foundation
import Speech
import AVFoundation

guard CommandLine.arguments.count > 1 else {
    fputs("Usage: apple_speech.swift <audio_file.wav>\n", stderr)
    exit(1)
}

let audioURL = URL(fileURLWithPath: CommandLine.arguments[1])
let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "tr-TR"))!
let request = SFSpeechURLRecognitionRequest(url: audioURL)
request.shouldReportPartialResults = false

let semaphore = DispatchSemaphore(value: 0)
var resultText = ""
var exitCode: Int32 = 0

SFSpeechRecognizer.requestAuthorization { status in
    guard status == .authorized else {
        fputs("❌ İzin reddedildi — Sistem Tercihleri > Gizlilik > Konuşma Tanıma\n", stderr)
        exitCode = 1
        semaphore.signal()
        return
    }
    recognizer.recognitionTask(with: request) { result, error in
        if let error = error {
            fputs("❌ Hata: \(error.localizedDescription)\n", stderr)
            exitCode = 1
            semaphore.signal()
            return
        }
        if let result = result, result.isFinal {
            resultText = result.bestTranscription.formattedString
            semaphore.signal()
        }
    }
}

semaphore.wait()
if exitCode == 0 { print(resultText) }
exit(exitCode)
