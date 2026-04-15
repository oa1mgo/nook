import Combine
import Foundation

protocol MediaControllerProtocol: AnyObject {
    var playbackStatePublisher: AnyPublisher<PlaybackState, Never> { get }
    func refresh()
    func togglePlayPause(displayedTime: TimeInterval?)
    func nextTrack()
    func previousTrack()
    func openSourceApp()
}
