import AppKit
import SwiftUI

class NotchOverlayWindow: NSWindow {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var isHoveringOverNotch = false
    private var isHoveringOverWindow = false
    private var notchView: NotchBoxView?
    private var isShowing = false
    private let finalWidth: CGFloat = 280
    private let finalHeight: CGFloat = 120
    private let notchWidth: CGFloat = 220

    init() {
        let screen = NSScreen.main!
        let screenFrame = screen.frame
        let x = (screenFrame.width - notchWidth) / 2
        let y = screenFrame.height

        let windowRect = NSRect(x: x, y: y, width: notchWidth, height: 0)

        super.init(contentRect: windowRect, styleMask: .borderless, backing: .buffered, defer: false)

        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .statusBar
        self.hidesOnDeactivate = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = false
        self.acceptsMouseMovedEvents = true

        let contentView = NotchBoxView(trackName: "No track playing")
        self.contentView = NSHostingView(rootView: contentView)
        self.notchView = contentView

        self.orderOut(nil)
    }

    func startTracking() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.handleGlobalMouseEvent(event)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown]) { [weak self] event in
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

    private func isInNotchZone(_ location: NSPoint) -> Bool {
        guard let screen = NSScreen.main else { return false }
        let screenFrame = screen.frame
        let notchCenterX = screenFrame.width / 2
        let triggerWidth: CGFloat = 220
        let triggerHeight: CGFloat = 37

        return location.x >= (notchCenterX - triggerWidth / 2) &&
               location.x <= (notchCenterX + triggerWidth / 2) &&
               location.y >= (screenFrame.height - triggerHeight)
    }

    private func handleGlobalMouseEvent(_ event: NSEvent) {
        let mouseLocation = NSEvent.mouseLocation

        let inNotch = isInNotchZone(mouseLocation)

        if inNotch && !isHoveringOverNotch && !isShowing {
            isHoveringOverNotch = true
            showWindow()
        } else if !inNotch && !isHoveringOverWindow && isShowing {
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

        let screen = NSScreen.main!
        let screenFrame = screen.frame
        let startX = (screenFrame.width - notchWidth) / 2
        let startY = screenFrame.height
        let finalX = (screenFrame.width - finalWidth) / 2
        let finalY = screenFrame.height - finalHeight

        let collapsedRect = NSRect(x: startX, y: startY, width: notchWidth, height: 0)
        let expandedRect = NSRect(x: finalX, y: finalY, width: finalWidth, height: finalHeight)

        self.setFrame(collapsedRect, display: false)
        self.orderFront(nil)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.45
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)
            context.allowsImplicitAnimation = true
            self.animator().setFrame(expandedRect, display: true)
        }, completionHandler: nil)

        isShowing = true
    }

    private func hideWindow() {
        let screen = NSScreen.main!
        let screenFrame = screen.frame
        let startX = (screenFrame.width - notchWidth) / 2
        let startY = screenFrame.height
        let finalX = (screenFrame.width - finalWidth) / 2
        let finalY = screenFrame.height - finalHeight

        let collapsedRect = NSRect(x: startX, y: startY, width: notchWidth, height: 0)
        let expandedRect = NSRect(x: finalX, y: finalY, width: finalWidth, height: finalHeight)

        self.setFrame(expandedRect, display: false)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.6, 0.0, 0.85, 0.3)
            context.allowsImplicitAnimation = true
            self.animator().setFrame(collapsedRect, display: true)
        }, completionHandler: { [weak self] in
            self?.orderOut(nil)
            self?.isShowing = false
        })
    }

    deinit {
        stopTracking()
    }
}
