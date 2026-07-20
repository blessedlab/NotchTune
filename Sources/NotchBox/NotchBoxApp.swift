import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    private var overlayWindow: NotchOverlayWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        overlayWindow = NotchOverlayWindow()
        overlayWindow?.startTracking()
    }

    func applicationWillTerminate(_ notification: Notification) {
        overlayWindow?.stopTracking()
    }
}
