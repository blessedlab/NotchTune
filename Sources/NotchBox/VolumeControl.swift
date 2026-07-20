import Foundation

struct VolumeControl {
    static var volume: Float {
        get {
            let script = "output volume of (get volume settings)"
            guard let output = runOascript(script),
                  let val = Float(output) else { return 0.5 }
            return val / 100.0
        }
        set {
            let percent = Int(newValue * 100)
            _ = runOascript("set volume output volume \(percent)")
        }
    }

    static func volumeIcon(_ volume: Float) -> String {
        switch volume {
        case 0: return "speaker.fill"
        case 0..<0.33: return "speaker.wave.1.fill"
        case 0.33..<0.66: return "speaker.wave.2.fill"
        default: return "speaker.wave.3.fill"
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
