#!/usr/bin/env swift
// Apple Speech Recognition backend for ccplugin-voice-input
// Usage: apple_speech.swift <audio_file.wav> [language_code]
// Language: VOICE_LANG env var or argument (default: tr-TR)
// Examples: apple_speech.swift audio.wav en-US
//           VOICE_LANG=en-US swift apple_speech.swift audio.wav
import Foundation
import Speech
import AVFoundation

guard CommandLine.arguments.count > 1 else {
    fputs("Usage: apple_speech.swift <audio_file.wav> [language_code]\n", stderr)
    exit(1)
}

let audioURL = URL(fileURLWithPath: CommandLine.arguments[1])

// Language selection: argument > env var > default
let langCode: String
if CommandLine.arguments.count > 2 {
    langCode = CommandLine.arguments[2]
} else if let envLang = ProcessInfo.processInfo.environment["VOICE_LANG"], !envLang.isEmpty, envLang != "auto" {
    langCode = envLang
} else {
    langCode = "tr-TR"
}

guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: langCode)) else {
    fputs("❌ Speech recognizer unavailable for locale: \(langCode)\n", stderr)
    exit(1)
}

guard recognizer.isAvailable else {
    fputs("❌ Speech recognizer not available (locale: \(langCode)) — check Accessibility settings\n", stderr)
    exit(1)
}

let request = SFSpeechURLRecognitionRequest(url: audioURL)
request.shouldReportPartialResults = false

let semaphore = DispatchSemaphore(value: 0)
var resultText = ""
var exitCode: Int32 = 0

SFSpeechRecognizer.requestAuthorization { status in
    guard status == .authorized else {
        switch status {
        case .denied:
            fputs("❌ Speech recognition denied — enable in System Settings > Privacy > Speech Recognition\n", stderr)
        case .restricted:
            fputs("❌ Speech recognition restricted on this device\n", stderr)
        case .notDetermined:
            fputs("❌ Speech recognition authorization not determined\n", stderr)
        default:
            fputs("❌ Speech recognition not authorized\n", stderr)
        }
        exitCode = 1
        semaphore.signal()
        return
    }
    recognizer.recognitionTask(with: request) { result, error in
        if let error = error {
            fputs("❌ Recognition error: \(error.localizedDescription)\n", stderr)
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
