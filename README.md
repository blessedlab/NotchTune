# BetterNotch

**A native macOS music controller that lives in your MacBook's notch.**

BetterNotch is a lightweight, zero-bloat utility that displays a sleek music player overlay when you hover your mouse near the notch on your MacBook. It reads track info from Spotify running in Safari and gives you full playback control — all from a beautiful, notch-shaped widget.

https://github.com/user-attachments/assets/movie.mp4

## Why BetterNotch?

| Feature | BetterNotch | Other Notch Apps |
|---------|------------|------------------|
| **Native Swift** | ✅ Pure Swift, no Electron | ❌ Often Electron/web-based |
| **Resource usage** | ✅ Minimal (~10MB RAM) | ❌ Heavy (100MB+) |
| **Animation** | ✅ 60fps waveform, smooth expand | ⚠️ Often janky |
| **Design** | ✅ Matches MacBook notch shape | ⚠️ Generic rounded rects |
| **Integration** | ✅ Direct Safari JS control | ⚠️ Limited APIs |
| **Background footprint** | ✅ Accessory app, no dock icon | ❌ Full app with dock presence |

## Features

- **Notch-shaped overlay** — UI that mirrors your MacBook's notch design
- **Real-time track info** — Title, artist, and album art from Spotify
- **Animated waveform seek bar** — Beautiful 60fps visualization with drag-to-seek
- **Playback controls** — Play/pause, next, previous track
- **Smooth animations** — 270ms expand/collapse with haptic feedback
- **Smart activation** — Only appears when you hover near the notch
- **Always-on-top** — Stays visible across all Spaces and fullscreen apps
- **Zero dock icon** — Runs as a background accessory app

## Requirements

- macOS 14.0 (Sonoma) or later
- A MacBook with a notch (MacBook Pro 2021+, MacBook Air M3+)
- Safari with [open.spotify.com](https://open.spotify.com) loaded

## Installation

### Option 1: Build from Source (Recommended)

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/BetterNotch.git
   cd BetterNotch
   ```

2. **Build the app:**
   ```bash
   swift build -c release
   ```

3. **Create the app bundle:**
   ```bash
   mkdir -p NotchBox.app/Contents/MacOS
   mkdir -p NotchBox.app/Contents/Resources
   cp .build/release/NotchBox NotchBox.app/Contents/MacOS/
   cp Resources/Info.plist NotchBox.app/Contents/
   ```

4. **Move to Applications:**
   ```bash
   mv NotchBox.app /Applications/
   ```

5. **Launch the app:**
   ```bash
   open /Applications/NotchBox.app
   ```

### Option 2: Pre-built App

If you have the `NotchBox-Classic.app` bundle:

1. Copy `NotchBox-Classic.app` to your `/Applications/` folder
2. Double-click to launch
3. Follow the permission setup below

## Permission Setup

BetterNotch needs two permissions to work correctly. You'll be prompted automatically when you first launch the app.

### 1. Accessibility Permission

**Why:** BetterNotch monitors your mouse position globally to detect when you hover near the notch.

**How to enable:**

1. When you first launch, a system dialog will appear asking for Accessibility access
2. Click **Open System Settings**
3. Navigate to **Privacy & Security → Accessibility**
4. Click the **+** button and add `NotchBox` (or find it in the list and toggle it on)
5. If prompted, enter your password

**Manual setup (if dialog doesn't appear):**
1. Open **System Settings**
2. Go to **Privacy & Security → Accessibility**
3. Click the **+** button
4. Navigate to `/Applications/NotchBox.app` and add it
5. Make sure the toggle is **ON**

### 2. Safari Permissions

**Why:** BetterNotch communicates with Safari via AppleScript to read track info and control playback on Spotify's web player.

**How to enable:**

1. Open **Safari**
2. Go to **Safari → Settings → Privacy**
3. Make sure **Allow JavaScript from Apple Events** is enabled
4. If not, check the box to enable it

**Important:** Safari must be running with [open.spotify.com](https://open.spotify.com) loaded in a tab. BetterNotch communicates directly with the Spotify web player through Safari.

### 3. Spotify Setup

1. Open Safari
2. Navigate to [open.spotify.com](https://open.spotify.com)
3. Log in to your Spotify account
4. Start playing music
5. Keep Safari open (you can minimize it — BetterNotch reads from the background)

## Usage

1. **Launch** NotchBox from your Applications folder
2. **Move your mouse** to the top-center of your screen (near the notch)
3. **Wait ~500ms** — the overlay will expand smoothly from the notch
4. **Interact** with the controls:
   - Click **Play/Pause** to control playback
   - Click **Forward/Backward** to skip tracks
   - **Drag** the waveform seek bar to jump to a position
   - **Hover** over the seek bar to see a time preview
5. **Move your mouse away** — the overlay collapses back into the notch

## Troubleshooting

### Overlay doesn't appear
- Ensure Accessibility permission is granted (see above)
- Make sure Safari is running with Spotify loaded
- Try restarting the app

### Track info shows "No track playing"
- Check that Spotify is playing in Safari (not the desktop app)
- Verify the Spotify tab is in Safari window 1
- Refresh the Spotify page

### Playback controls don't work
- Ensure JavaScript from Apple Events is enabled in Safari settings
- Try reloading the Spotify page in Safari

### App doesn't appear in Accessibility settings
- Launch the app once to trigger the permission prompt
- If still missing, add it manually via the **+** button

## Architecture

```
BetterNotch/
├── Sources/NotchBox/
│   ├── main.swift              # App entry point
│   ├── NotchBoxApp.swift       # AppDelegate, accessibility setup
│   ├── NotchOverlayWindow.swift # Window management, mouse tracking
│   ├── NotchBoxView.swift       # Main UI (track info, controls)
│   ├── WaveformSeekBar.swift    # Animated waveform seek bar
│   ├── TrackInfoFetcher.swift   # Safari/AppleScript communication
│   ├── TrackInfoViewModel.swift # Real-time progress interpolation
│   ├── TrackInfo.swift          # Track data model
│   └── MediaKeySimulator.swift  # Playback control via JS
├── Resources/
│   └── Info.plist               # App metadata
└── Package.swift                # Swift Package Manager config
```

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE) for details.

## Contributing

1. Fork the repo
2. Create a feature branch
3. Make your changes
4. Test on a MacBook with a notch
5. Submit a pull request

---

**Made with ❤️ for MacBook owners who love Spotify**
