import AppKit
import SwiftUI

class NotchOverlayWindow: NSWindow {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private let viewModel = TrackInfoViewModel()
    private var isShowing = false
    private var isAnimating = false
    private let finalWidth: CGFloat = 300
    private let finalHeight: CGFloat = 180
    private let notchWidth: CGFloat = 220
    private var trackRefreshTimer: Timer?
    private var lastTrackInfo: TrackInfo = .empty

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

        let contentView = NotchBoxView(viewModel: viewModel)
        self.contentView = NSHostingView(rootView: contentView)

        preloadTrackInfo()
    }

    func startTracking() {
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.handleGlobalMouseEvent(event)
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved, .leftMouseDown]) { [weak self] event in
            self?.handleLocalMouseEvent(event)
            return event
        }

        trackRefreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.refreshTrackInfoAsync()
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
        trackRefreshTimer?.invalidate()
        trackRefreshTimer = nil
    }

    private func preloadTrackInfo() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let info = TrackInfoFetcher.fetchTrackInfo()
            DispatchQueue.main.async {
                self?.viewModel.update(from: info)
                self?.lastTrackInfo = info
            }
        }
    }

    private func refreshTrackInfoAsync() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let info = TrackInfoFetcher.fetchTrackInfo()
            DispatchQueue.main.async {
                self.viewModel.update(from: info)
                self.lastTrackInfo = info
            }
        }
    }

    private func isInNotchZone(_ location: NSPoint) -> Bool {
        let triggerWidth: CGFloat = 220
        let triggerHeight: CGFloat = 37

        for screen in NSScreen.screens {
            let frame = screen.frame
            let isBuiltIn = screen == NSScreen.main || frame.height <= 1080

            if !isBuiltIn { continue }

            let notchCenterX = frame.midX
            if location.x >= (notchCenterX - triggerWidth / 2) &&
               location.x <= (notchCenterX + triggerWidth / 2) &&
               location.y >= (frame.height - triggerHeight) &&
               location.y <= frame.height {
                return true
            }
        }
        return false
    }

    private func handleGlobalMouseEvent(_ event: NSEvent) {
        let mouseLocation = NSEvent.mouseLocation
        let inNotch = isInNotchZone(mouseLocation)

        if inNotch && !isShowing && !isAnimating {
            showWindow()
        } else if !inNotch && !isHoveringOverWindow() && isShowing && !isAnimating {
            hideWindow()
        }
    }

    private func isHoveringOverWindow() -> Bool {
        let mouseLocation = NSEvent.mouseLocation
        return frame.contains(mouseLocation)
    }

    private func handleLocalMouseEvent(_ event: NSEvent) {
        let mouseLocation = NSEvent.mouseLocation
        let isInsideWindow = frame.contains(mouseLocation)

        if !isInsideWindow && isShowing && !isAnimating && !isInNotchZone(mouseLocation) {
            hideWindow()
        }
    }

    private func showWindow() {
        guard !isShowing else { return }
        isAnimating = true

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
        }, completionHandler: { [weak self] in
            self?.isShowing = true
            self?.isAnimating = false
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            if self?.isAnimating == true {
                self?.isShowing = true
                self?.isAnimating = false
            }
        }

        refreshTrackInfoAsync()
    }

    private func hideWindow() {
        guard isShowing else { return }
        isAnimating = true
        isShowing = false

        let screen = NSScreen.main!
        let screenFrame = screen.frame
        let startX = (screenFrame.width - notchWidth) / 2
        let startY = screenFrame.height

        let collapsedRect = NSRect(x: startX, y: startY, width: notchWidth, height: 0)

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            context.timingFunction = CAMediaTimingFunction(controlPoints: 0.55, 0.0, 0.85, 0.36)
            context.allowsImplicitAnimation = true
            self.animator().setFrame(collapsedRect, display: true)
        }, completionHandler: { [weak self] in
            self?.orderOut(nil)
            self?.isAnimating = false
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isAnimating = false
        }
    }

    deinit {
        stopTracking()
    }
}
