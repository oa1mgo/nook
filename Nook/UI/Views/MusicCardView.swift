import SwiftUI

struct MusicCardView: View {
    @ObservedObject var musicManager: MusicManager

    var body: some View {
        HStack(spacing: 12) {
            artworkColumn

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(primaryLineText)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text(secondaryLineText)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.55))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    controlsRow
                }

                TimelineView(.animation(minimumInterval: musicManager.playbackState.isPlaying ? 0.2 : 1.0)) { timeline in
                    let elapsedTime = displayedElapsedTime(at: timeline.date)

                    ProgressView(value: progressFraction(for: elapsedTime))
                        .tint(Color.white.opacity(0.9))

                    HStack {
                        Text(formatTime(elapsedTime))
                        Spacer()
                        Text(formatTime(musicManager.playbackState.duration))
                    }
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.35))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
        )
    }
}

private extension MusicCardView {
    var trimmedTitle: String? {
        trimmedPlaybackText(musicManager.playbackState.title)
    }

    var trimmedArtist: String? {
        trimmedPlaybackText(musicManager.playbackState.artist)
    }

    var trimmedAlbum: String? {
        trimmedPlaybackText(musicManager.playbackState.album)
    }

    var primaryLineText: String {
        trimmedTitle
            ?? trimmedArtist
            ?? "Nothing Playing"
    }

    var secondaryLineText: String {
        let secondaryCandidates = [trimmedArtist, trimmedAlbum]
            .compactMap { $0 }
            .filter { $0 != primaryLineText }

        if let secondaryText = secondaryCandidates.first {
            return secondaryText
        }

        return "Unknown Artist"
    }

    var artworkColumn: some View {
        VStack(spacing: 6) {
            artwork
            sourceBadge
        }
        .frame(width: 88)
    }

    var artwork: some View {
        Button(action: musicManager.openSourceApp) {
            Group {
                if let image = musicManager.albumArt {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: musicManager.fallbackSymbolName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                }
            }
            .frame(width: 56, height: 56)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    var sourceBadge: some View {
        if let sourceApp = musicManager.sourceApp {
            Button(action: musicManager.openSourceApp) {
                HStack(spacing: 5) {
                    if let icon = sourceApp.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }

                    Text(sourceApp.displayName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.72))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.07))
                )
            }
            .buttonStyle(.plain)
        }
    }

    var controlsRow: some View {
        HStack(spacing: 10) {
            transportButton(systemName: "backward.fill", action: musicManager.previousTrack)

            transportButton(
                systemName: musicManager.playbackState.isPlaying ? "pause.fill" : "play.fill",
                action: {
                    musicManager.togglePlayPause(displayedTime: displayedElapsedTime(at: Date()))
                },
                isPrimary: true
            )

            transportButton(systemName: "forward.fill", action: musicManager.nextTrack)
        }
    }

    func formatTime(_ time: TimeInterval) -> String {
        let totalSeconds = max(Int(time.rounded()), 0)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    func displayedElapsedTime(at date: Date) -> TimeInterval {
        let state = musicManager.playbackState
        guard state.isPlaying else {
            return clampedElapsedTime(state.currentTime, duration: state.duration)
        }

        let delta = max(0, date.timeIntervalSince(state.lastUpdated))
        return clampedElapsedTime(state.currentTime + (delta * state.playbackRate), duration: state.duration)
    }

    func progressFraction(for elapsedTime: TimeInterval) -> Double {
        guard musicManager.playbackState.duration > 0 else { return 0 }
        return min(max(elapsedTime / musicManager.playbackState.duration, 0), 1)
    }

    func clampedElapsedTime(_ elapsedTime: TimeInterval, duration: TimeInterval) -> TimeInterval {
        guard duration > 0 else { return max(0, elapsedTime) }
        return min(max(0, elapsedTime), duration)
    }

    func trimmedPlaybackText(_ text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    @ViewBuilder
    func transportButton(systemName: String, action: @escaping () -> Void, isPrimary: Bool = false) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: isPrimary ? 13 : 11, weight: .semibold))
                .foregroundColor(.white.opacity(isPrimary ? 0.98 : 0.82))
                .frame(width: isPrimary ? 28 : 24, height: isPrimary ? 28 : 24)
                .background(
                    Circle()
                        .fill(Color.white.opacity(isPrimary ? 0.12 : 0.05))
                )
        }
        .buttonStyle(.plain)
    }
}
