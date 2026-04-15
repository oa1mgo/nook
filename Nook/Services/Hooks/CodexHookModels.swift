//
//  CodexHookModels.swift
//  Nook
//
//  Minimal Codex hook payloads used by the V1 hook bridge.
//

import Foundation

/// Minimal Codex hook envelope.
///
/// We intentionally reject Claude-style hook payloads by failing decoding when
/// the Claude-only `status` field is present. That keeps Codex detection
/// separate from the existing Claude hook path.
struct CodexHookEnvelope: Decodable, Sendable {
    let event: String
    let sessionId: String
    let cwd: String
    let toolName: String?
    let toolUseId: String?
    let command: String?
    let prompt: String?

    enum CodingKeys: String, CodingKey {
        case event
        case hookEventName = "hook_event_name"
        case sessionId = "session_id"
        case sessionIdCamel = "sessionId"
        case cwd
        case toolName = "tool_name"
        case toolNameCamel = "toolName"
        case tool
        case toolUseId = "tool_use_id"
        case toolInput = "tool_input"
        case prompt
        case status
    }

    enum ToolInputCodingKeys: String, CodingKey {
        case command
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if container.contains(.status) {
            throw DecodingError.dataCorruptedError(
                forKey: .status,
                in: container,
                debugDescription: "Claude hook payloads are not Codex hooks"
            )
        }

        event = try Self.decodeString(container, keys: [.event, .hookEventName])
        sessionId = try Self.decodeString(container, keys: [.sessionId, .sessionIdCamel])
        cwd = try Self.decodeString(container, keys: [.cwd])
        toolName = Self.decodeOptionalString(container, keys: [.toolName, .toolNameCamel, .tool])
        toolUseId = Self.decodeOptionalString(container, keys: [.toolUseId])
        if let toolInput = try? container.nestedContainer(keyedBy: ToolInputCodingKeys.self, forKey: .toolInput) {
            command = try toolInput.decodeIfPresent(String.self, forKey: .command)
        } else {
            command = nil
        }
        prompt = Self.decodeOptionalString(container, keys: [.prompt])
    }

    var normalizedEventName: String {
        event
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
            .lowercased()
    }

    var isBashTool: Bool {
        toolName?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "bash"
    }

    private static func decodeString(
        _ container: KeyedDecodingContainer<CodingKeys>,
        keys: [CodingKeys]
    ) throws -> String {
        for key in keys {
            if let value = try container.decodeIfPresent(String.self, forKey: key) {
                return value
            }
        }

        throw DecodingError.keyNotFound(
            keys[0],
            DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Missing required Codex hook field"
            )
        )
    }

    private static func decodeOptionalString(
        _ container: KeyedDecodingContainer<CodingKeys>,
        keys: [CodingKeys]
    ) -> String? {
        for key in keys {
            if let value = try? container.decodeIfPresent(String.self, forKey: key) {
                return value
            }
        }
        return nil
    }
}

/// Narrow Codex event surface used by the V1 integration.
enum CodexSessionEvent: Sendable {
    case sessionStart(sessionId: String, cwd: String)
    case userPromptSubmit(sessionId: String, cwd: String, prompt: String?)
    case preBashTool(sessionId: String, cwd: String, toolName: String, toolUseId: String?, command: String?)
    case postBashTool(sessionId: String, cwd: String, toolName: String, toolUseId: String?, command: String?)
    case stop(sessionId: String, cwd: String)
}
