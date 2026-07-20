import Foundation
import Combine
import QuartzCore

class TrackInfoViewModel: ObservableObject {
    @Published var trackInfo: TrackInfo = .empty

    private var rawProgress: Double = 0
    private var rawDuration: Double = 0
    private var rawIsPlaying: Bool = false
    private var lastUpdateTime: CFTimeInterval = 0
    private var animTimer: Timer?

    init() {
        animTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func update(from info: TrackInfo) {
        rawProgress = info.progress
        rawDuration = max(info.duration, 1)
        rawIsPlaying = info.isPlaying
        lastUpdateTime = CACurrentMediaTime()
        trackInfo = info
    }

    private func tick() {
        guard rawIsPlaying, rawDuration > 0 else { return }

        let elapsed = CACurrentMediaTime() - lastUpdateTime
        let interpolated = rawProgress + elapsed / rawDuration
        let clamped = min(interpolated, 1.0)

        guard clamped != trackInfo.progress else { return }

        trackInfo = TrackInfo(
            title: trackInfo.title,
            artist: trackInfo.artist,
            coverArtURL: trackInfo.coverArtURL,
            progress: clamped,
            duration: rawDuration,
            isPlaying: trackInfo.isPlaying
        )
    }

    deinit {
        animTimer?.invalidate()
    }
}
