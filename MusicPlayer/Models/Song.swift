import Foundation

struct Song: Identifiable, Equatable {
    let id = UUID()
    let url: URL
    var title: String
    var artist: String

    var filename: String {
        url.lastPathComponent
    }

    static func == (lhs: Song, rhs: Song) -> Bool {
        lhs.id == rhs.id
    }
}
