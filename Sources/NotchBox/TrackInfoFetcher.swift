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
