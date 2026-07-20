import SwiftUI

struct WaveformSeekBar: View {
    let progress: CGFloat
    let isPlaying: Bool
    let activeColor: Color
    let onSeek: (CGFloat) -> Void

    @State private var isDragging = false
    @State private var isHovering = false
    @State private var dragProgress: CGFloat = 0
    @State private var hoverProgress: CGFloat = 0

    private var displayedProgress: CGFloat {
        isDragging ? dragProgress : progress
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            GeometryReader { proxy in
                let width = proxy.size.width
                let phase = timeline.date.timeIntervalSinceReferenceDate

                ZStack(alignment: .leading) {
                    Canvas { context, size in
                        let path = waveformPath(in: size, phase: phase, progress: displayedProgress)

                        context.stroke(
                            path,
                            with: .color(.white.opacity(0.15)),
                            style: .init(lineWidth: 2, lineCap: .round)
                        )

                        context.drawLayer { layerContext in
                            let playedRect = CGRect(
                                x: 0, y: 0,
                                width: size.width * displayedProgress,
                                height: size.height
                            )
                            layerContext.clip(to: Path(playedRect))
                            layerContext.stroke(
                                path,
                                with: .color(activeColor.opacity(0.9)),
                                style: .init(lineWidth: 2.5, lineCap: .round)
                            )
                        }

                        if isDragging || isHovering {
                            let lineX = size.width * (isDragging ? dragProgress : hoverProgress)
                            let markerRect = CGRect(x: lineX - 1, y: 0, width: 2, height: size.height)
                            context.fill(Path(roundedRect: markerRect, cornerRadius: 1), with: .color(.white.opacity(0.8)))
                        }
                    }

                    if isDragging {
                        let x = width * dragProgress
                        Text(formatTime(dragProgress * 100))
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .fixedSize()
                            .position(x: min(max(20, x), width - 20), y: -6)
                    }
                }
                .contentShape(Rectangle())
                .onHover { hovering in
                    isHovering = hovering
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let p = min(max(value.location.x / max(width, 1), 0), 1)
                            if !isDragging { isDragging = true }
                            dragProgress = p
                        }
                        .onEnded { value in
                            let p = min(max(value.location.x / max(width, 1), 0), 1)
                            dragProgress = p
                            onSeek(p)
                            isDragging = false
                        }
                )
                .onTapGesture { location in
                    let p = min(max(location.x / max(width, 1), 0), 1)
                    onSeek(p)
                }
                .onContinuousHover { phase in
                    switch phase {
                    case .active(let location):
                        isHovering = true
                        hoverProgress = min(max(location.x / max(width, 1), 0), 1)
                    case .ended:
                        isHovering = false
                    }
                }
            }
        }
        .frame(height: 24)
    }

    private func waveformPath(in size: CGSize, phase: TimeInterval, progress: CGFloat) -> Path {
        var path = Path()
        let sampleCount = 80
        let step = size.width / CGFloat(max(sampleCount - 1, 1))
        let middleY = size.height * 0.55
        let baseAmplitude = size.height * 0.4

        let speed: CGFloat = isPlaying ? 3.0 : 0.5
        let scrollOffset = progress * 25

        for index in 0..<sampleCount {
            let t = CGFloat(phase) * speed + CGFloat(index) * 0.18 + scrollOffset
            let envelope = sin(.pi * CGFloat(index) / CGFloat(sampleCount - 1))
            let wave1 = 0.35 * sin(t)
            let wave2 = 0.15 * cos(t * 1.7 + 0.5)
            let wave3 = 0.08 * sin(t * 2.9 + 1.2)
            let combined = wave1 + wave2 + wave3
            let amplitude = baseAmplitude * envelope
            let y = middleY + combined * amplitude
            let x = CGFloat(index) * step

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        return path
    }

    private func formatTime(_ seconds: CGFloat) -> String {
        let s = Int(seconds)
        return String(format: "%d:%02d", s / 60, s % 60)
    }
}
