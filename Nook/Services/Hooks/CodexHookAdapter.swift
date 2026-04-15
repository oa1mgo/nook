//
//  CodexHookAdapter.swift
//  Nook
//
//  Maps Codex hook envelopes to the small event set used by V1.
//

import Foundation

enum CodexHookAdapter {
    static func adapt(_ envelope: CodexHookEnvelope) -> CodexSessionEvent? {
        switch envelope.normalizedEventName {
        case "sessionstart":
            return .sessionStart(sessionId: envelope.sessionId, cwd: envelope.cwd)

        case "userpromptsubmit":
            return .userPromptSubmit(
                sessionId: envelope.sessionId,
                cwd: envelope.cwd,
                prompt: envelope.prompt
            )

        case "pretooluse", "prebashtool":
            guard envelope.isBashTool, let toolName = envelope.toolName else { return nil }
            return .preBashTool(
                sessionId: envelope.sessionId,
                cwd: envelope.cwd,
                toolName: toolName,
                toolUseId: envelope.toolUseId,
                command: envelope.command
            )

        case "posttooluse", "postbashtool":
            guard envelope.isBashTool, let toolName = envelope.toolName else { return nil }
            return .postBashTool(
                sessionId: envelope.sessionId,
                cwd: envelope.cwd,
                toolName: toolName,
                toolUseId: envelope.toolUseId,
                command: envelope.command
            )

        case "stop":
            return .stop(sessionId: envelope.sessionId, cwd: envelope.cwd)

        default:
            return nil
        }
    }
}
