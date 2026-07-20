import SwiftUI

@main
struct NotchBoxApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

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
