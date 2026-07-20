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
        var path = Path()
        let maxRadius: CGFloat = 20
        let radius = min(maxRadius, rect.height / 2, rect.width / 2)

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addArc(center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
                    radius: radius,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)

        return path
    }
}

struct NotchBoxView: View {
    @State var trackName: String
    @State private var volume: Float = VolumeControl.volume

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 48)

            Text(trackName)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 28)

            Spacer().frame(height: 10)

            HStack(spacing: 8) {
                Image(systemName: "speaker.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))

                Slider(value: $volume, in: 0...1)
                    .tint(.white)
                    .frame(height: 4)
                    .onChange(of: volume) { _, newValue in
                        VolumeControl.volume = newValue
                    }

                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 28)

            Spacer().frame(height: 10)

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
        .frame(width: 280, height: 140)
        .background(
            NotchShape()
                .fill(Color.black)
        )
        .overlay(
            NotchBorderShape()
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .clipShape(NotchShape())
    }
}
