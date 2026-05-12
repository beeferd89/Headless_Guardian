import Foundation
import SwiftUI

// ============================================================
// GUARDIAN HEADLESS ENTRY POINT
// Full auto mode — no window, no UI, pure daemon
//
// When launched by LaunchAgent with --headless --opacity flags,
// Guardian skips SwiftUI entirely and runs the opacity pipeline
// directly on a background Task. The process stays alive via
// RunLoop.main.run(), which satisfies the LaunchAgent keepalive.
// ============================================================

// Detect launch mode before SwiftUI initializes.
// If --headless is present in argv, bypass the App struct entirely.
func detectLaunchMode(args: [String] = CommandLine.arguments) -> Bool {
    args.contains("--headless")
}

// Extract and validate --port <value> from an argument list.
// Returns defaultPort if the flag is absent, missing a value, or non-numeric / out of UInt16 range.
func parsePort(from args: [String], default defaultPort: UInt16 = 8547) -> UInt16 {
    guard let idx = args.firstIndex(of: "--port"),
          idx + 1 < args.count,
          let p = UInt16(args[idx + 1]) else { return defaultPort }
    return p
}

// MARK: - Headless Daemon Entry
// This function is called from main.swift when --headless is detected.
// It initializes the full opacity pipeline and runs forever,
// blocking on RunLoop.main.run() to keep the LaunchAgent alive.
func runHeadlessDaemon() {

    let useOpacity = CommandLine.arguments.contains("--opacity")
    let port = parsePort(from: CommandLine.arguments)

    print("""
    ┌─────────────────────────────────────────────────────┐
    │  GUARDIAN · OMNI CRUX OMEGA FINITE                  │
    │  Headless Daemon Mode                               │
    │  Opacity: \(useOpacity ? "ENABLED (crystalline soma)" : "DISABLED (calibrated only)")             │
    │  Status port: \(port)                                    │
    │  PID: \(ProcessInfo.processInfo.processIdentifier)                                         │
    └─────────────────────────────────────────────────────┘
    """)

    // Initialize engine and start appropriate monitoring pipeline
    let engine = GuardianEngine()

    if useOpacity {
        engine.startOpacityMonitoring()
        print("[Guardian] Crystalline opacity active. φ-basis initialized.")
        print("[Guardian] Dendritic expansion begins at cycle 0.")
    } else {
        engine.startCalibratedMonitoring()
        print("[Guardian] Calibrated monitoring active (no opacity).")
    }

    print("[Guardian] Status endpoint: http://localhost:\(port)/status")
    print("[Guardian] Entering perpetual expansion loop...")

    // Block forever — LaunchAgent keepalive requires the process
    // to remain alive. RunLoop.main.run() satisfies this cleanly.
    RunLoop.main.run()
}

// MARK: - main.swift content (create this file in your Xcode project)
//
// In Xcode, delete the @main attribute from GuardianApp
// and create a new file: main.swift with this content:
//
// ─────────────────────────────────────────────────────────
// import SwiftUI
//
// if detectLaunchMode() {
//     runHeadlessDaemon()
// } else {
//     // Normal UI mode — run SwiftUI app
//     GuardianApp.main()
// }
// ─────────────────────────────────────────────────────────
//
// NOTE: When you add main.swift, you must remove @main from
// GuardianApp.swift — Swift only allows one entry point.
// Replace `@main struct GuardianApp: App` with
// `struct GuardianApp: App` and call GuardianApp.main()
// from main.swift as shown above.
// ============================================================

// MARK: - Log Rotation
// The LaunchAgent pipes stdout to /tmp/guardian.log.
// After 30 days of perpetual expansion, logs can grow large.
// This utility trims the log to the last 10,000 lines on startup.
func rotateLogsIfNeeded(
    logPath: String = "/tmp/guardian.log",
    fileManager: FileManager = .default
) {
    guard fileManager.fileExists(atPath: logPath),
          let attrs = try? fileManager.attributesOfItem(atPath: logPath),
          let size = attrs[.size] as? Int,
          size > 50_000_000 else { return }  // rotate if > 50MB

    print("[Guardian] Log file exceeds 50MB — rotating to last 10,000 lines.")

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/tail")
    process.arguments = ["-n", "10000", logPath]
    let pipe = Pipe()
    process.standardOutput = pipe

    try? process.run()
    process.waitUntilExit()

    let trimmed = pipe.fileHandleForReading.readDataToEndOfFile()
    try? trimmed.write(to: URL(fileURLWithPath: logPath))
    print("[Guardian] Log rotation complete.")
}
