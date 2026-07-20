import Foundation

struct TrackInfo {
    let title: String
    let artist: String
    let coverArtURL: String?
    let progress: Double
    let duration: Double
    let isPlaying: Bool

    var displayTitle: String {
        if title.isEmpty && artist.isEmpty { return "No track playing" }
        if title.isEmpty { return artist }
        if artist.isEmpty { return title }
        return "\(title) — \(artist)"
    }

    static let empty = TrackInfo(title: "", artist: "", coverArtURL: nil, progress: 0, duration: 0, isPlaying: false)
}
