import SwiftUI

struct NotchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 20

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

struct NotchBoxView: View {
    @State var trackName: String
    @State private var volume: Float = VolumeControl.volume
    @State private var weather: WeatherData?
    @State private var showVolume = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 45)

            HStack(spacing: 12) {
                if let weather = weather {
                    HStack(spacing: 4) {
                        Image(systemName: weather.icon)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.8))
                        Text("\(weather.temperature)°")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }

                Spacer()

                Text(trackName)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showVolume.toggle()
                    }
                }) {
                    Image(systemName: VolumeControl.volumeIcon(volume))
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 28)

            Spacer().frame(height: 6)

            if showVolume {
                HStack(spacing: 8) {
                    Image(systemName: "speaker.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))

                    Slider(value: $volume, in: 0...1)
                        .tint(.white)
                        .frame(height: 4)
                        .onChange(of: volume) { _, newValue in
                            VolumeControl.volume = newValue
                        }

                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 28)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            Spacer().frame(height: showVolume ? 4 : 6)

            HStack(spacing: 32) {
                Button(action: {
                    MediaKeySimulator.simulate(.previous)
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    MediaKeySimulator.simulate(.play)
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    MediaKeySimulator.simulate(.next)
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
            }

            Spacer().frame(height: 12)
        }
        .frame(width: 280, height: 120)
        .background(
            ZStack {
                NotchShape()
                    .fill(Color.black.opacity(0.85))
                NotchShape()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            }
        )
        .clipShape(NotchShape())
        .onAppear {
            WeatherService().fetchWeather { data in
                weather = data
            }
        }
    }
}
