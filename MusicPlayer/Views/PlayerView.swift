import SwiftUI

struct PlayerView: View {
    @EnvironmentObject var playerVM: PlayerViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            albumArt

            VStack(spacing: 6) {
                Text(playerVM.currentSong?.title ?? "No Song")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(playerVM.currentSong?.artist ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            progressSlider

            HStack {
                Text(playerVM.currentTimeString)
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.gray)
                Spacer()
                Text(playerVM.durationString)
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)

            playbackControls

            volumeSlider

            Spacer()
        }
        .padding(30)
        .background {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple, Color.blue.opacity(0.8), Color.black]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        }
    }

    private var albumArt: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .frame(width: 260, height: 260)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

            Image(systemName: "music.note")
                .font(.system(size: 80))
                .foregroundColor(.white.opacity(0.6))
        }
    }

    private var progressSlider: some View {
        Slider(
            value: Binding(
                get: { playerVM.progress },
                set: { playerVM.seek(to: $0) }
            ),
            in: 0...1
        )
        .accentColor(.white)
    }

    private var playbackControls: some View {
        HStack(spacing: 40) {
            Button(action: playerVM.previousSong) {
                Image(systemName: "backward.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }

            Button(action: playerVM.togglePlayPause) {
                Image(systemName: playerVM.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.white)
            }

            Button(action: playerVM.nextSong) {
                Image(systemName: "forward.fill")
                    .font(.title)
                    .foregroundColor(.white)
            }
        }
    }

    private var volumeSlider: some View {
        HStack(spacing: 12) {
            Image(systemName: "speaker.fill")
                .foregroundColor(.gray)
            Slider(
                value: Binding(
                    get: { playerVM.volume },
                    set: { playerVM.setVolume($0) }
                ),
                in: 0...1
            )
            .accentColor(.white)
            Image(systemName: "speaker.wave.3.fill")
                .foregroundColor(.gray)
        }
    }
}
