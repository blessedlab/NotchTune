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
        return runOascript(script)
    }

    private static func fetchFromChrome() -> String? {
        let script = """
        tell application "Google Chrome"
            if (count of windows) = 0 then return ""
            set tabTitle to title of active tab of front window
            return tabTitle
        end tell
        """
        return runOascript(script)
    }

    private static func runOascript(_ script: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        process.arguments = ["-e", script]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)

            if process.terminationStatus == 0, let output = output, !output.isEmpty {
                return output
            }
        } catch {
            print("osascript error: \(error)")
        }
        return nil
    }
}
