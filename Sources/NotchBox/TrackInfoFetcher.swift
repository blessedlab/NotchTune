import Foundation

struct TrackInfoFetcher {
    static func fetchTrackName() -> String {
        let track = fetchFromSafari() ?? fetchFromChrome()
        return track?.isEmpty == false ? track! : "No track playing"
    }

    private static func fetchFromSafari() -> String? {
        let script = """
        tell application "Safari"
            if (count of windows) = 0 then return ""
            set tabTitle to name of current tab of window 1
            return tabTitle
        end tell
        """
        return runAppleScript(script)
    }

    private static func fetchFromChrome() -> String? {
        let script = """
        tell application "Google Chrome"
            if (count of windows) = 0 then return ""
            set tabTitle to title of active tab of front window
            return tabTitle
        end tell
        """
        return runAppleScript(script)
    }

    private static func runAppleScript(_ script: String) -> String? {
        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else { return nil }
        let result = appleScript.executeAndReturnError(&error)
        if let error = error {
            print("AppleScript error: \(error)")
            return nil
        }
        return result.stringValue
    }
}
