import AppKit
import SwiftUI

class NotchOverlayWindow: NSWindow {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var isHoveringOverNotch = false
    private var isHoveringOverWindow = false
    private var notchView: NotchBoxView?

    init() {
        let screen = NSScreen.main!
        let screenWidth = screen.frame.width
        let windowWidth: CGFloat = 300
        let windowHeight: CGFloat = 200

        let windowRect = NSRect(
            x: (screenWidth - windowWidth) / 2,
            y: screen.frame.height - windowHeight,
            width: windowWidth,
            height: windowHeight
        )

        super.init(contentRect: windowRect, styleMask: .borderless, backing: .buffered, defer: false)

        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .statusBar
        self.hidesOnDeactivate = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = false

        let contentView = NotchBoxView(trackName: "No track playing")
        self.contentView = NSHostingView(rootView: contentView)
        self.notchView = contentView

        self.alphaValue = 0
    }

    func startTracking() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown, .rightMouseDown]) { [weak self] event in
            self?.handleGlobalMouseEvent(event)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown, .rightMouseDown]) { [weak self] event in
            self?.handleLocalMouseEvent(event)
            return event
        }
    }

    func stopTracking() {
        if let monitor = globalMonitor {
            NSEvent.removeMonitor(monitor)
            globalMonitor = nil
        }
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
    }

    private func handleGlobalMouseEvent(_ event: NSEvent) {
        let mouseLocation = NSEvent.mouseLocation
        let screen = NSScreen.main!
        let notchCenterX = screen.frame.width / 2
        let notchWidth: CGFloat = 220
        let notchHeight: CGFloat = 30

        let isInNotchZone = mouseLocation.x >= (notchCenterX - notchWidth / 2) &&
                             mouseLocation.x <= (notchCenterX + notchWidth / 2) &&
                             mouseLocation.y >= (screen.frame.height - notchHeight) &&
                             mouseLocation.y <= screen.frame.height

        if isInNotchZone && !isHoveringOverNotch {
            isHoveringOverNotch = true
            showWindow()
        } else if !isInNotchZone && !isHoveringOverWindow {
            isHoveringOverNotch = false
            hideWindow()
        }
    }

    private func handleLocalMouseEvent(_ event: NSEvent) {
        let mouseLocation = NSEvent.mouseLocation
        let windowFrame = self.frame

        let isInsideWindow = windowFrame.contains(mouseLocation)

        if isInsideWindow && !isHoveringOverWindow {
            isHoveringOverWindow = true
        } else if !isInsideWindow && isHoveringOverWindow {
            isHoveringOverWindow = false
            if !isHoveringOverNotch {
                hideWindow()
            }
        }
    }

    private func showWindow() {
        let trackName = TrackInfoFetcher.fetchTrackName()
        notchView?.trackName = trackName

        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)

        self.orderFront(nil)
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            context.allowsImplicitAnimation = true
            self.animator().alphaValue = 1.0
        }
    }

    private func hideWindow() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            context.allowsImplicitAnimation = true
            self.animator().alphaValue = 0.0
        } completionHandler: { [weak self] in
            self?.orderOut(nil)
        }
    }

    deinit {
        stopTracking()
    }
}
