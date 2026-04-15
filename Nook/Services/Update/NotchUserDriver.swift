import Combine
import Foundation

enum UpdateState: Equatable {
    case idle
    case checking
    case upToDate
    case found(version: String, releaseNotes: String?)
    case downloading(progress: Double)
    case extracting(progress: Double)
    case readyToInstall(version: String)
    case installing
    case error(message: String)

    var isActive: Bool { false }
}

@MainActor
class UpdateManager: NSObject, ObservableObject {
    static let shared = UpdateManager()

    @Published var state: UpdateState = .idle
    @Published var hasUnseenUpdate: Bool = false

    func checkForUpdates() {}
    func downloadAndInstall() {}
    func installAndRelaunch() {}
    func skipUpdate() {}
    func dismissUpdate() {}
    func cancelDownload() {}
    func markUpdateSeen() { hasUnseenUpdate = false }
}

class NotchUserDriver: NSObject {}
