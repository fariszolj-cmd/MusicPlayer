import Foundation
import AVFoundation
import UniformTypeIdentifiers
import SwiftUI

@MainActor
class PlayerViewModel: NSObject, ObservableObject {
    @Published var songs: [Song] = []
    @Published var currentSong: Song?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 0.8

    private var player: AVAudioPlayer?
    private var timer: Timer?

    var progress: Double {
        duration > 0 ? currentTime / duration : 0
    }

    var currentTimeString: String {
        timeString(currentTime)
    }

    var durationString: String {
        timeString(duration)
    }

    private func timeString(_ interval: TimeInterval) -> String {
        let m = Int(interval) / 60
        let s = Int(interval) % 60
        return String(format: "%d:%02d", m, s)
    }

    func importSongs(from urls: [URL]) {
        let newSongs = urls.map { url -> Song in
            let title = url.deletingPathExtension().lastPathComponent
            return Song(url: url, title: title, artist: "Unknown")
        }
        songs.append(contentsOf: newSongs)
        if currentSong == nil, let first = songs.first {
            selectSong(first)
        }
    }

    func selectSong(_ song: Song) {
        currentSong = song
        stopTimer()
        playSong(song)
    }

    private func playSong(_ song: Song) {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)

            player = try AVAudioPlayer(contentsOf: song.url)
            player?.delegate = self
            player?.volume = volume
            duration = player?.duration ?? 0
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
            startTimer()
        } catch {
            print("Failed to play: \(error.localizedDescription)")
            isPlaying = false
        }
    }

    func togglePlayPause() {
        guard player != nil else { return }
        if isPlaying {
            player?.pause()
            isPlaying = false
            stopTimer()
        } else {
            player?.play()
            isPlaying = true
            startTimer()
        }
    }

    func nextSong() {
        guard let current = currentSong,
              let index = songs.firstIndex(of: current) else { return }
        let next = songs[(index + 1) % songs.count]
        selectSong(next)
    }

    func previousSong() {
        guard let current = currentSong,
              let index = songs.firstIndex(of: current) else { return }
        let prev = songs[(index - 1 + songs.count) % songs.count]
        selectSong(prev)
    }

    func seek(to progress: Double) {
        guard let player = player else { return }
        let time = progress * duration
        player.currentTime = time
        currentTime = time
    }

    func setVolume(_ vol: Float) {
        volume = vol
        player?.volume = vol
    }

    func deleteSong(_ song: Song) {
        songs.removeAll { $0.id == song.id }
        if currentSong?.id == song.id {
            if songs.isEmpty {
                currentSong = nil
                player?.stop()
                isPlaying = false
                currentTime = 0
                duration = 0
            } else {
                selectSong(songs[0])
            }
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let p = self.player else { return }
                self.currentTime = p.currentTime
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension PlayerViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            nextSong()
        }
    }
}
