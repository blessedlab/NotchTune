# NotchBox Design Spec

## Overview

NotchBox is a macOS menu bar/background application that provides a custom view dropping down from the MacBook notch area. It simulates global media keys to control Spotify playing in web browsers (Safari/Chrome) and displays the current track name.

## Architecture

### Project Structure

```
NotchBox/
├── NotchBoxApp.swift          — App entry point, AppDelegate
├── NotchOverlayWindow.swift   — NSWindow management, hover detection
├── NotchBoxView.swift         — SwiftUI view with jelly animation and media buttons
├── MediaKeySimulator.swift    — CGEvent media key simulation
├── TrackInfoFetcher.swift     — AppleScript for track name retrieval
└── Info.plist                 — LSUIElement = YES
```

### Components

#### 1. AppDelegate (NotchBoxApp.swift)

- `@main` App struct with `NSApplicationDelegateAdaptor`
- Set `NSApp.setActivationPolicy(.accessory)` — no dock icon
- Create and show overlay window
- Start global mouse monitor

#### 2. NotchOverlayWindow

- `NSWindow` with: `isOpaque = false`, `backgroundColor = .clear`, `level = .statusBar`
- Position: top-center of screen, width ~300px, height ~200px (extends beyond screen, clipped)
- `hidesOnDeactivate = false` — window doesn't disappear on focus loss
- `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]`

#### 3. Hover Detection

- `NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved)` — track mouse position
- Activation zone: directly below notch (centerX ± 110px, y from 0 to 30px)
- Mouse enters zone → show window with animation
- Mouse leaves zone → hide window with animation
- Additional: `NSEvent.addLocalMonitorForEvents` for tracking mouse over the NotchBox window itself (prevents closing when hovering over the control)

#### 4. Jelly Animation (SwiftUI)

- `offset(y:)` with `animation(.spring(response: 0.5, dampingFraction: 0.3))` — bouncing spring
- Show: `y = -200` → `y = 0` (drop down)
- Hide: `y = 0` → `y = -200` (retract)
- `interactiveSpring` for gesture responsiveness

#### 5. Haptic Feedback

- `NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)`
- Triggered at the moment the drop-down animation begins

#### 6. Media Key Simulation (MediaKeySimulator.swift)

- Function `simulateMediaKey(type: NX_KEYTYPE)` via `CGEvent`
- `NX_KEYTYPE_PLAY = 16`, `NX_KEYTYPE_NEXT = 17`, `NX_KEYTYPE_PREVIOUS = 18`
- Create `CGEvent` with `NX_KEYTYPE` and post via `.post(tap: .cghidEventTap)`

#### 7. Track Info (TrackInfoFetcher.swift)

- AppleScript for Safari: `tell application "Safari" to get name of current tab of window 1`
- AppleScript for Chrome: `tell application "Google Chrome" to get title of active tab of front window`
- Fallback: if neither Safari nor Chrome → show "No track playing"
- Update on each window show or via timer

#### 8. UI Layout (NotchBoxView.swift)

- HStack with three buttons: Previous, Play/Pause, Next
- Text with track name (single line, truncation)
- Dark background with blur effect, rounded corners
- Size: ~300×80px

## Data Flow

```
Mouse Event → HoverDetector → Window Show/Hide
                                    ↓
                              HapticFeedback
                                    ↓
                              SwiftUI View (animation)
                                    ↓
Button Tap → MediaKeySimulator → CGEvent → macOS → Safari/Chrome
                                    ↓
TrackInfoFetcher → AppleScript → Track Name → Text
```

## Security & Permissions

- AppleScript for track info requires Accessibility permission (System Preferences → Privacy → Accessibility)
- On first launch macOS will show a dialog requesting permission
- App must be added to Accessibility list for track info to work

## Key Parameters

| Parameter | Value |
|-----------|-------|
| Notch detection zone width | 220px |
| Notch detection zone height | 30px |
| Window width | 300px |
| Window height | 200px (clipped) |
| Spring response | 0.5s |
| Spring damping | 0.3 |
| Media key codes | PLAY=16, NEXT=17, PREVIOUS=18 |
