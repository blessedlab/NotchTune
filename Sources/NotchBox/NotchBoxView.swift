import SwiftUI

struct NotchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let maxRadius: CGFloat = 20
        let radius = min(maxRadius, rect.height / 2, rect.width / 2)

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        path.closeSubpath()

        return path
    }
}

struct NotchBorderShape: Shape {
    func path(in rect: CGRect) -> Path {
        let maxRadius: CGFloat = 20
        let radius = min(maxRadius, rect.height / 2, rect.width / 2)
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(90),
                    clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(0),
                    clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))

        return path
    }
}

struct NotchBoxView: View {
    @ObservedObject var viewModel: TrackInfoViewModel
    @State private var coverImage: NSImage?

    private var trackInfo: TrackInfo { viewModel.trackInfo }

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 40)

            ZStack(alignment: .center) {
                if let coverImage = coverImage {
                    Image(nsImage: coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.3))
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 16)
                }

                VStack(alignment: .center, spacing: 3) {
                    Text(trackInfo.title.isEmpty ? "No track playing" : trackInfo.title)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: 200)

                    if !trackInfo.artist.isEmpty {
                        Text(trackInfo.artist)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .frame(maxWidth: 200)
                    }
                }
            }
            .frame(height: 48)

            Spacer().frame(height: 10)

            HStack(spacing: 8) {
                Text(formatTime(trackInfo.progress * trackInfo.duration))
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 32, alignment: .trailing)

                WaveformSeekBar(
                    progress: CGFloat(trackInfo.progress),
                    isPlaying: trackInfo.isPlaying,
                    activeColor: .white
                ) { newProgress in
                    seekTo(progress: newProgress)
                }

                Text(formatTime(trackInfo.duration))
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 32, alignment: .leading)
            }
            .padding(.horizontal, 12)

            Spacer().frame(height: 10)

            HStack(spacing: 32) {
                Button(action: {
                    MediaKeySimulator.simulate(.previous)
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    MediaKeySimulator.simulate(.play)
                }) {
                    Image(systemName: trackInfo.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    MediaKeySimulator.simulate(.next)
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }

            Spacer().frame(height: 16)
        }
        .frame(width: 300, height: 180)
        .background {
            GeometryReader { geo in
                if let coverImage = coverImage {
                    Image(nsImage: coverImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .blur(radius: 40)
                        .saturation(1.3)
                        .scaleEffect(1.2)
                } else {
                    Color.black
                }
            }
        }
        .background(.ultraThinMaterial)
        .overlay {
            GeometryReader { geo in
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.7),
                        Color.black.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .overlay(
            NotchBorderShape()
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .clipShape(NotchShape())
        .onAppear {
            loadCoverArt()
        }
        .onChange(of: trackInfo.coverArtURL) { _, _ in
            loadCoverArt()
        }
    }

    private func loadCoverArt() {
        guard let urlString = trackInfo.coverArtURL,
              let url = URL(string: urlString) else {
            coverImage = nil
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = NSImage(data: data) {
                DispatchQueue.main.async {
                    self.coverImage = image
                }
            }
        }.resume()
    }

    private func formatTime(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }
        let s = Int(seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    private func seekTo(progress: CGFloat) {
        let durationMs = trackInfo.duration * 1000
        let positionMs = Int(progress * durationMs)
        let js = """
        (function() {
            var el = document.querySelector('[data-testid="playback-progressbar"] input[type=range]');
            if (!el) return 'no_element';
            var nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
            nativeInputValueSetter.call(el, \(positionMs));
            el.dispatchEvent(new Event('input', { bubbles: true }));
            el.dispatchEvent(new Event('change', { bubbles: true }));
            return 'ok';
        })()
        """
        _ = TrackInfoFetcher.runJSOnSpotifyTab(js)
    }
}
