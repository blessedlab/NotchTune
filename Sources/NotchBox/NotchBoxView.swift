import SwiftUI

struct NotchShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 18

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

    var body: some View {
        VStack(spacing: 10) {
            Text(trackName)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)

            HStack(spacing: 32) {
                Button(action: {
                    MediaKeySimulator.simulate(.previous)
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
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
                        .foregroundColor(.white.opacity(0.9))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 28)
        .padding(.top, 8)
        .padding(.bottom, 14)
        .frame(width: 280, height: 80)
        .background(
            NotchShape()
                .fill(Color(red: 0.11, green: 0.11, blue: 0.118))
        )
        .shadow(color: .black.opacity(0.6), radius: 20, x: 0, y: 8)
    }
}
