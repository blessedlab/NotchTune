import Foundation

enum MediaKey {
    case play
    case next
    case previous
}

struct MediaKeySimulator {
    static func simulate(_ key: MediaKey) {
        let js: String
        switch key {
        case .play:
            js = "document.querySelector('[data-testid=\"control-button-playpause\"]')?.click(); 'ok'"
        case .next:
            js = "document.querySelector('[data-testid=\"control-button-skip-forward\"]')?.click(); 'ok'"
        case .previous:
            js = "document.querySelector('[data-testid=\"control-button-skip-back\"], .control-button.spoticon-skip-back-16')?.click(); 'ok'"
        }
        _ = TrackInfoFetcher.runJSOnSpotifyTab(js)
    }
}
