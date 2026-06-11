import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @EnvironmentObject var playerVM: PlayerViewModel
    @State private var showPicker = false

    var body: some View {
        VStack(spacing: 0) {
            header

            if playerVM.songs.isEmpty {
                emptyState
            } else {
                songList
            }
        }
        .background(Color.black.ignoresSafeArea())
        .fileImporter(
            isPresented: $showPicker,
            allowedContentTypes: [.audio, .mp3, .wav, .mpeg4Audio, .aiff],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                playerVM.importSongs(from: urls)
            case .failure(let error):
                print("Import failed: \(error)")
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Library")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Spacer()

            Button(action: { showPicker = true }) {
                Image(systemName: "plus")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.purple.opacity(0.8))
                    .clipShape(Circle())
            }
        }
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Songs Yet")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text("Tap + to import songs from your files")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
        }
    }

    private var songList: some View {
        List {
            ForEach(playerVM.songs) { song in
                Button {
                    playerVM.selectSong(song)
                } label: {
                    songRow(song)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
            .onDelete { indexSet in
                for i in indexSet {
                    playerVM.deleteSong(playerVM.songs[i])
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private func songRow(_ song: Song) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 48, height: 48)
                Image(systemName: "music.note")
                    .foregroundColor(.purple)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.body.bold())
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(song.filename)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            if playerVM.currentSong?.id == song.id && playerVM.isPlaying {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.purple)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(playerVM.currentSong?.id == song.id ? 0.08 : 0.03))
        )
    }
}
