//
//  SessionProvider.swift
//  Nook
//
//  Provider metadata for sessions.
//

import Foundation

enum SessionProvider: String, Codable, Equatable, Sendable {
    case claude
    case codex

    var displayName: String {
        switch self {
        case .claude:
            return "Claude"
        case .codex:
            return "Codex"
        }
    }
}
