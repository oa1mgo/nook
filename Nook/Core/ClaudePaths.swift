//
//  ClaudePaths.swift
//  Nook
//
//  Single source of truth for all Claude config directory paths.
//  Resolves automatically via CLAUDE_CONFIG_DIR env var or filesystem detection,
//  with an optional user override via AppSettings.claudeDirectoryName.
//

import Foundation

enum ClaudePaths {

    /// Cached resolved directory to avoid filesystem checks on every access
    private nonisolated(unsafe) static var _cachedDir: URL?

    /// Guards reads/writes to _cachedDir — accessed from the main actor
    /// (UI settings), the ConversationParser actor, and background watcher
    /// queues, so cross-thread access needs synchronization.
    private nonisolated static let cacheLock = NSLock()

    /// Root Claude config directory, resolved once and cached.
    ///
    /// Resolution order:
    /// 1. CLAUDE_CONFIG_DIR environment variable (if set and exists)
    /// 2. AppSettings.claudeDirectoryName override (if changed from default)
    /// 3. ~/.config/claude/ (new default since Claude Code v2.1.30+, if projects/ exists)
    /// 4. ~/.claude/ (legacy fallback)
    nonisolated static var claudeDir: URL {
        cacheLock.lock()
        if let cached = _cachedDir {
            cacheLock.unlock()
            return cached
        }
        cacheLock.unlock()

        // Resolve outside the lock — involves filesystem and settings reads
        // that shouldn't block other threads.
        let resolved = resolveClaudeDir()

        cacheLock.lock()
        // Another thread may have populated the cache while we were resolving;
        // prefer theirs for consistency, but either value is correct.
        if let existing = _cachedDir {
            cacheLock.unlock()
            return existing
        }
        _cachedDir = resolved
        cacheLock.unlock()
        return resolved
    }

    nonisolated static var hooksDir: URL {
        claudeDir.appendingPathComponent("hooks")
    }

    nonisolated static var settingsFile: URL {
        claudeDir.appendingPathComponent("settings.json")
    }

    nonisolated static var projectsDir: URL {
        claudeDir.appendingPathComponent("projects")
    }

    /// Shell-safe absolute path for hook commands in settings.json.
    /// Absolute paths keep custom directories and ~/.config/claude working;
    /// quoting keeps paths with spaces from being split by the shell.
    nonisolated static var hookScriptShellPath: String {
        shellQuote(claudeDir.appendingPathComponent("hooks/nook-state.py").path)
    }

    /// Invalidate the cached directory so the next access re-resolves.
    /// Call this when the user changes AppSettings.claudeDirectoryName.
    nonisolated static func invalidateCache() {
        cacheLock.lock()
        _cachedDir = nil
        cacheLock.unlock()
    }

    private nonisolated static func resolveClaudeDir() -> URL {
        let fm = FileManager.default
        let home = fm.homeDirectoryForCurrentUser

        // 1. CLAUDE_CONFIG_DIR env var takes highest priority
        if let envDir = Foundation.ProcessInfo.processInfo.environment["CLAUDE_CONFIG_DIR"] {
            let expanded = (envDir as NSString).expandingTildeInPath
            let url = URL(fileURLWithPath: expanded)
            if fm.fileExists(atPath: url.path) {
                return url
            }
        }

        // 2. User override via settings — accepts either an absolute path (chosen
        //    via the folder picker) or a legacy directory name under ~/
        let settingsValue = AppSettings.claudeDirectoryName
        if !settingsValue.isEmpty && settingsValue != ".claude" {
            if settingsValue.hasPrefix("/") {
                return URL(fileURLWithPath: settingsValue)
            } else {
                return home.appendingPathComponent(settingsValue)
            }
        }

        // 3. New default ~/.config/claude/ (if projects/ exists there)
        let newDefault = home.appendingPathComponent(".config/claude")
        if fm.fileExists(atPath: newDefault.appendingPathComponent("projects").path) {
            return newDefault
        }

        // 4. Legacy fallback
        return home.appendingPathComponent(".claude")
    }

    private nonisolated static func shellQuote(_ path: String) -> String {
        "'" + path.replacingOccurrences(of: "'", with: "'\\''") + "'"
    }
}
