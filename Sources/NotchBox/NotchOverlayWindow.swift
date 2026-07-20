import AppKit
import SwiftUI

class NotchOverlayWindow: NSWindow {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var isHoveringOverNotch = false
    private var isHoveringOverWindow = false
    private var notchView: NotchBoxView?
    private var isShowing = false

    init() {
        let screen = NSScreen.main!
        let screenFrame = screen.frame
        let windowWidth: CGFloat = 280
        let windowHeight: CGFloat = 120

        let x = (screenFrame.width - windowWidth) / 2
        let y = screenFrame.height - windowHeight

        let windowRect = NSRect(x: x, y: y, width: windowWidth, height: windowHeight)

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

        self.alphaValue = 0
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

    private func handleGlobalMouseEvent(_ event: NSEvent) {
        let mouseLocation = NSEvent.mouseLocation

        guard let screen = NSScreen.main, screen.frame.contains(mouseLocation) else {
            if isShowing { hideWindow() }
            return
        }

        let screenFrame = screen.frame
        let notchCenterX = screenFrame.width / 2
        let notchWidth: CGFloat = 220
        let notchHeight: CGFloat = 37

        let mouseX = mouseLocation.x
        let mouseY = mouseLocation.y

        let isInNotchZone = mouseX >= (notchCenterX - notchWidth / 2) &&
                             mouseX <= (notchCenterX + notchWidth / 2) &&
                             mouseY >= (screenFrame.height - notchHeight)

        if isInNotchZone && !isHoveringOverNotch && !isShowing {
            isHoveringOverNotch = true
            showWindow()
        } else if !isInNotchZone && !isHoveringOverWindow && isShowing {
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

        notchView?.scale = 0.0
        notchView?.opacity = 0.0

        self.alphaValue = 1.0
        self.orderOut(nil)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.orderFront(nil)

            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.45
                context.timingFunction = CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)
                context.allowsImplicitAnimation = true
                self.notchView?.scale = 1.0
                self.notchView?.opacity = 1.0
            }, completionHandler: nil)
        }

        isShowing = true
    }

    private func hideWindow() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            context.allowsImplicitAnimation = true
            self.notchView?.scale = 0.0
            self.notchView?.opacity = 0.0
        }, completionHandler: { [weak self] in
            self?.orderOut(nil)
            self?.isShowing = false
        })
    }

    deinit {
        stopTracking()
    }
}
