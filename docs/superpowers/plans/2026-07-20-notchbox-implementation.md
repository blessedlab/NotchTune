# NotchBox Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a macOS menu bar application that drops down from the MacBook notch with media controls and track info display.

**Architecture:** Single transparent NSWindow overlay at screen top, SwiftUI view inside with jelly spring animation, global mouse hover detection, CGEvent media key simulation, AppleScript track info fetching.

**Tech Stack:** Swift, SwiftUI, AppKit, CGEvent, AppleScript

---

## File Structure

```
NotchBox/
├── Package.swift                    — Swift Package Manager configuration
├── Sources/
│   └── NotchBox/
│       ├── NotchBoxApp.swift        — App entry point, AppDelegate
│       ├── NotchOverlayWindow.swift — NSWindow management, hover detection
│       ├── NotchBoxView.swift       — SwiftUI view with jelly animation
│       ├── MediaKeySimulator.swift  — CGEvent media key simulation
│       └── TrackInfoFetcher.swift   — AppleScript track info
├── Resources/
│   └── Info.plist                   — LSUIElement = YES
└── docs/
    └── superpowers/
        ├── specs/
        └── plans/
```

---

### Task 1: Project Setup

**Files:**
- Create: `Package.swift`
- Create: `Sources/NotchBox/` directory
- Create: `Resources/Info.plist`

- [ ] **Step 1: Create Swift Package**

```bash
mkdir -p /Users/daniel/Documents/BetterNotch/Sources/NotchBox
mkdir -p /Users/daniel/Documents/BetterNotch/Resources
```

- [ ] **Step 2: Write Package.swift**

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NotchBox",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "NotchBox",
            path: "Sources/NotchBox",
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("CoreGraphics"),
            ]
        )
    ]
)
```

- [ ] **Step 3: Create Info.plist**

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>NotchBox</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>$(MACOSX_DEPLOYMENT_TARGET)</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
```

- [ ] **Step 4: Verify project builds**

```bash
cd /Users/daniel/Documents/BetterNotch && swift build 2>&1 | head -20
```

Expected: Build succeeds (or "no files to compile" since no source files yet)

- [ ] **Step 5: Commit**

```bash
cd /Users/daniel/Documents/BetterNotch && git init && git add . && git commit -m "feat: initial project setup with Swift Package"
```

---

### Task 2: Media Key Simulator

**Files:**
- Create: `Sources/NotchBox/MediaKeySimulator.swift`

- [ ] **Step 1: Create MediaKeySimulator.swift**

```swift
import CoreGraphics
import Foundation

enum MediaKey {
    case play
    case next
    case previous

    var nxKeyType: Int32 {
        switch self {
        case .play: return 16      // NX_KEYTYPE_PLAY
        case .next: return 17      // NX_KEYTYPE_NEXT
        case .previous: return 18  // NX_KEYTYPE_PREVIOUS
        }
    }
}

struct MediaKeySimulator {
    static func simulate(_ key: MediaKey) {
        let event = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true)
        event?.setIntegerValueField(.keyboardEventKeycode, value: Int64(key.nxKeyType))
        event?.flags = .maskAlphaShift
        event?.post(tap: .cghidEventTap)

        let upEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false)
        upEvent?.setIntegerValueField(.keyboardEventKeycode, value: Int64(key.nxKeyType))
        upEvent?.flags = .maskAlphaShift
        upEvent?.post(tap: .cghidEventTap)
    }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
cd /Users/daniel/Documents/BetterNotch && swift build 2>&1
```

Expected: Build succeeds

- [ ] **Step 3: Commit**

```bash
cd /Users/daniel/Documents/BetterNotch && git add Sources/NotchBox/MediaKeySimulator.swift && git commit -m "feat: add media key simulator via CGEvent"
```

---

### Task 3: Track Info Fetcher

**Files:**
- Create: `Sources/NotchBox/TrackInfoFetcher.swift`

- [ ] **Step 1: Create TrackInfoFetcher.swift**

```swift
import Foundation

struct TrackInfoFetcher {
    static func fetchTrackName() -> String {
        if let safariTrack = fetchFromSafari(), !safariTrack.isEmpty {
            return safariTrack
        }
        if let chromeTrack = fetchFromChrome(), !chromeTrack.isEmpty {
            return chromeTrack
        }
        return "No track playing"
    }

    private static func fetchFromSafari() -> String? {
        let script = """
        tell application "Safari"
            try
                return name of current tab of window 1
            on error
                return ""
            end try
        end tell
        """
        return runAppleScript(script)
    }

    private static func fetchFromChrome() -> String? {
        let script = """
        tell application "Google Chrome"
            try
                return title of active tab of front window
            on error
                return ""
            end try
        end tell
        """
        return runAppleScript(script)
    }

    private static func runAppleScript(_ script: String) -> String? {
        guard let appleScript = NSAppleScript(source: script) else { return nil }
        var error: NSDictionary?
        let result = appleScript.executeAndReturnError(&error)
        if error != nil {
            return nil
        }
        return result.stringValue
    }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
cd /Users/daniel/Documents/BetterNotch && swift build 2>&1
```

Expected: Build succeeds

- [ ] **Step 3: Commit**

```bash
cd /Users/daniel/Documents/BetterNotch && git add Sources/NotchBox/TrackInfoFetcher.swift && git commit -m "feat: add track info fetcher via AppleScript"
```

---

### Task 4: Notch Overlay Window

**Files:**
- Create: `Sources/NotchBox/NotchOverlayWindow.swift`

- [ ] **Step 1: Create NotchOverlayWindow.swift**

```swift
import AppKit
import SwiftUI

class NotchOverlayWindow: NSWindow {
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var isHoveringOverNotch = false
    private var isHoveringOverWindow = false
    private var trackInfo: String = "No track playing"
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

        let contentView = NotchBoxView(trackName: trackInfo)
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
        trackInfo = TrackInfoFetcher.fetchTrackName()
        notchView?.trackName = trackInfo

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
```

- [ ] **Step 2: Verify it compiles**

```bash
cd /Users/daniel/Documents/BetterNotch && swift build 2>&1
```

Expected: Build succeeds

- [ ] **Step 3: Commit**

```bash
cd /Users/daniel/Documents/BetterNotch && git add Sources/NotchBox/NotchOverlayWindow.swift && git commit -m "feat: add notch overlay window with hover detection"
```

---

### Task 5: SwiftUI Notch Box View

**Files:**
- Create: `Sources/NotchBox/NotchBoxView.swift`

- [ ] **Step 1: Create NotchBoxView.swift**

```swift
import SwiftUI

struct NotchBoxView: View {
    @State var trackName: String
    @State private var isAppeared = false

    var body: some View {
        VStack(spacing: 12) {
            Text(trackName)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)

            HStack(spacing: 24) {
                Button(action: {
                    MediaKeySimulator.simulate(.previous)
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    MediaKeySimulator.simulate(.play)
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    MediaKeySimulator.simulate(.next)
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(width: 300, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .offset(y: isAppeared ? 0 : -200)
        .animation(.spring(response: 0.5, dampingFraction: 0.3), value: isAppeared)
        .onAppear {
            isAppeared = true
        }
    }
}
```

- [ ] **Step 2: Verify it compiles**

```bash
cd /Users/daniel/Documents/BetterNotch && swift build 2>&1
```

Expected: Build succeeds

- [ ] **Step 3: Commit**

```bash
cd /Users/daniel/Documents/BetterNotch && git add Sources/NotchBox/NotchBoxView.swift && git commit -m "feat: add SwiftUI notch box view with jelly animation"
```

---

### Task 6: App Entry Point

**Files:**
- Create: `Sources/NotchBox/NotchBoxApp.swift`

- [ ] **Step 1: Create NotchBoxApp.swift**

```swift
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
```

- [ ] **Step 2: Verify full build**

```bash
cd /Users/daniel/Documents/BetterNotch && swift build 2>&1
```

Expected: Build succeeds

- [ ] **Step 3: Run the app to test**

```bash
cd /Users/daniel/Documents/BetterNotch && swift run 2>&1
```

Expected: App launches without dock icon, move mouse to top center to see notch box drop down

- [ ] **Step 4: Commit**

```bash
cd /Users/daniel/Documents/BetterNotch && git add Sources/NotchBox/NotchBoxApp.swift && git commit -m "feat: add app entry point with AppDelegate"
```

---

### Task 7: Final Integration & Testing

**Files:**
- Modify: `Sources/NotchBox/*.swift` (if needed)

- [ ] **Step 1: Clean build**

```bash
cd /Users/daniel/Documents/BetterNotch && swift build 2>&1
```

Expected: Build succeeds with no warnings

- [ ] **Step 2: Test full flow**

```bash
cd /Users/daniel/Documents/BetterNotch && swift run 2>&1
```

Test checklist:
- [ ] No dock icon appears
- [ ] Mouse hover under notch shows window with jelly animation
- [ ] Haptic feedback triggers on show
- [ ] Mouse leave hides window
- [ ] Play/Pause button works (test with Spotify in browser)
- [ ] Next/Previous buttons work
- [ ] Track name displays correctly

- [ ] **Step 3: Final commit**

```bash
cd /Users/daniel/Documents/BetterNotch && git add -A && git commit -m "feat: complete NotchBox MVP"
```

---

## Permissions Note

For track info to work, the user must grant Accessibility permission:
1. System Preferences → Privacy & Security → Accessibility
2. Click "+" and add NotchBox app
3. Toggle ON

Without this permission, track name will show "No track playing" but media keys will still work.
