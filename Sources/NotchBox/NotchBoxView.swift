import SwiftUI

struct NotchBoxView: View {
    @State var trackName: String
    @State private var isAppeared = false

    var body: some View {
        VStack(spacing: 12) {
            Text(trackName)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity)

            HStack(spacing: 24) {
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
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(width: 300, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .offset(y: isAppeared ? 0 : -200)
        .animation(.spring(response: 0.5, dampingFraction: 0.3), value: isAppeared)
        .onAppear {
            isAppeared = true
        }
    }
}
