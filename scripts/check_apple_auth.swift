#!/usr/bin/env swift
// check_apple_auth.swift — Check Apple Speech Recognition authorization status
// Usage: swift check_apple_auth.swift
// Exit 0 = authorized, Exit 1 = denied/restricted, Exit 2 = not determined (will prompt)
import Foundation
import Speech

let semaphore = DispatchSemaphore(value: 0)
var exitCode: Int32 = 0

let status = SFSpeechRecognizer.authorizationStatus()
switch status {
case .authorized:
    print("authorized")
    exit(0)
case .denied:
    fputs("denied — enable in System Settings > Privacy & Security > Speech Recognition\n", stderr)
    exit(1)
case .restricted:
    fputs("restricted — Speech Recognition not available on this device\n", stderr)
    exit(1)
case .notDetermined:
    // Will prompt user; return 2 so caller can handle
    print("not_determined")
    exit(2)
@unknown default:
    fputs("unknown authorization status\n", stderr)
    exit(1)
}
