import Foundation

enum MediaKey {
    case play
    case next
    case previous
}

struct MediaKeySimulator {
    static func simulate(_ key: MediaKey) {
        switch key {
        case .play:
            _ = runOascript("tell application \"Safari\" to tell current tab of window 1 to do JavaScript \"document.querySelector('audio')?.paused ? document.querySelector('audio').play() : document.querySelector('audio')?.pause()\"")
            _ = runOascript("tell application \"Google Chrome\" to tell active tab of front window to execute javascript \"document.querySelector('audio')?.paused ? document.querySelector('audio').play() : document.querySelector('audio')?.pause()\"")
        case .next:
            _ = runOascript("tell application \"Safari\" to tell current tab of window 1 to do JavaScript \"document.querySelector('audio').dispatchEvent(new KeyboardEvent('keydown', {key: 'ArrowRight', keyCode: 39, bubbles: true}))\"")
            _ = runOascript("tell application \"Google Chrome\" to tell active tab of front window to execute javascript \"document.querySelector('audio').dispatchEvent(new KeyboardEvent('keydown', {key: 'ArrowRight', keyCode: 39, bubbles: true}))\"")
        case .previous:
            _ = runOascript("tell application \"Safari\" to tell current tab of window 1 to do JavaScript \"document.querySelector('audio').dispatchEvent(new KeyboardEvent('keydown', {key: 'ArrowLeft', keyCode: 37, bubbles: true}))\"")
            _ = runOascript("tell application \"Google Chrome\" to tell active tab of front window to execute javascript \"document.querySelector('audio').dispatchEvent(new KeyboardEvent('keydown', {key: 'ArrowLeft', keyCode: 37, bubbles: true}))\"")
        }
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
            return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return nil
        }
    }
}
