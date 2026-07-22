import Foundation

struct TrackInfoFetcher {
    static func fetchTrackInfo() -> TrackInfo {
        let script = """
        tell application "Safari"
            set spotifyTab to missing value
            repeat with t in tabs of window 1
                if URL of t contains "open.spotify.com" then
                    set spotifyTab to t
                    exit repeat
                end if
            end repeat
            if spotifyTab is not missing value then
                set result to do JavaScript "JSON.stringify({t:document.querySelector('[data-testid=\\"context-item-info-title\\"]')?.textContent||'',a:document.querySelector('[data-testid=\\"context-item-info-artist\\"]')?.textContent||'',c:document.querySelector('[data-testid=\\"cover-art-image\\"]')?.src||'',p:document.querySelector('[data-testid=\\"playback-progressbar\\"] input[type=range]')?.value||'0',d:document.querySelector('[data-testid=\\"playback-progressbar\\"] input[type=range]')?.max||'0',s:document.querySelector('[data-testid=\\"control-button-playpause\\"]')?.getAttribute('aria-label')||'Play'})" in spotifyTab
                return result
            else
                return "NO_SPOTIFY_TAB"
            end if
        end tell
        """

        print("[NotchBox] Running AppleScript...")
        guard let output = runOascript(script), !output.isEmpty else {
            print("[NotchBox] AppleScript returned nil or empty output")
            return .empty
        }

        print("[NotchBox] Raw output: \(output)")

        if output == "NO_SPOTIFY_TAB" {
            print("[NotchBox] No Spotify tab found in Safari window 1")
            return .empty
        }

        return parseJSON(output)
    }

    static func fetchTrackName() -> String {
        fetchTrackInfo().displayTitle
    }

    private static func parseJSON(_ json: String) -> TrackInfo {
        guard let data = json.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("[NotchBox] Failed to parse JSON: \(json)")
            return .empty
        }

        let title = (obj["t"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let artist = (obj["a"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let coverURL = obj["c"] as? String
        let progress = Double(obj["p"] as? String ?? "0") ?? 0
        let duration = Double(obj["d"] as? String ?? "0") ?? 1
        let isPlaying = (obj["s"] as? String == "Pause")

        print("[NotchBox] Parsed: title=\(title), artist=\(artist), progress=\(progress), duration=\(duration), isPlaying=\(isPlaying)")

        return TrackInfo(
            title: title,
            artist: artist,
            coverArtURL: coverURL?.isEmpty == false ? coverURL : nil,
            progress: progress / max(duration, 1),
            duration: duration / 1000,
            isPlaying: isPlaying
        )
    }

    static func runJSOnSpotifyTab(_ js: String) -> String? {
        let escaped = js.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        let script = """
        tell application "Safari"
            repeat with t in tabs of window 1
                if URL of t contains "open.spotify.com" then
                    return do JavaScript "\(escaped)" in t
                end if
            end repeat
        end tell
        """
        return runOascript(script)
    }

    private static func runOascript(_ script: String) -> String? {
        let uuid = UUID().uuidString
        let tmpFile = FileManager.default.temporaryDirectory.appendingPathComponent("notchbox_\(uuid).scpt")
        try? script.write(to: tmpFile, atomically: true, encoding: .utf8)

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = [tmpFile.path]

        let outPipe = Pipe()
        let errPipe = Pipe()
        process.standardOutput = outPipe
        process.standardError = errPipe

        do {
            try process.run()

            let outData = outPipe.fileHandleForReading.readDataToEndOfFile()
            _ = errPipe.fileHandleForReading.readDataToEndOfFile()

            process.waitUntilExit()

            let output = String(data: outData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

            try? FileManager.default.removeItem(at: tmpFile)

            if process.terminationStatus == 0, let output = output, !output.isEmpty {
                return output
            }
        } catch {
        }
        return nil
    }
}
