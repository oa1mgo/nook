import Foundation

struct PlaybackState: Equatable, Sendable {
    var bundleIdentifier: String?
    var isPlaying: Bool
    var title: String
    var artist: String
    var album: String
    var currentTime: TimeInterval
    var duration: TimeInterval
    var playbackRate: Double
    var lastUpdated: Date
    var artworkData: Data?

    init(
        bundleIdentifier: String? = nil,
        isPlaying: Bool = false,
        title: String = "",
        artist: String = "",
        album: String = "",
        currentTime: TimeInterval = 0,
        duration: TimeInterval = 0,
        playbackRate: Double = 1,
        lastUpdated: Date = .distantPast,
        artworkData: Data? = nil
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.isPlaying = isPlaying
        self.title = title
        self.artist = artist
        self.album = album
        self.currentTime = currentTime
        self.duration = duration
        self.playbackRate = playbackRate
        self.lastUpdated = lastUpdated
        self.artworkData = artworkData
    }

    var hasDisplayableContent: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !artist.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
