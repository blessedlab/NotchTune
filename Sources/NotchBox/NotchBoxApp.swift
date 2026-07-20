import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlayWindow: NotchOverlayWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        requestAccessibility()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.overlayWindow = NotchOverlayWindow()
            self.overlayWindow?.startTracking()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        overlayWindow?.stopTracking()
    }

    private func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let trusted = AXIsProcessTrustedWithOptions(options)
        if !trusted {
            print("Accessibility not granted. Please enable in System Settings → Privacy & Security → Accessibility")
        }
    }
}
