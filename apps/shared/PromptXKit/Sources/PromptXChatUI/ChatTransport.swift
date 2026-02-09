import Foundation

public enum PromptXChatTransportEvent: Sendable {
    case health(ok: Bool)
    case tick
    case chat(PromptXChatEventPayload)
    case agent(PromptXAgentEventPayload)
    case seqGap
}

public protocol PromptXChatTransport: Sendable {
    func requestHistory(sessionKey: String) async throws -> PromptXChatHistoryPayload
    func sendMessage(
        sessionKey: String,
        message: String,
        thinking: String,
        idempotencyKey: String,
        attachments: [PromptXChatAttachmentPayload]) async throws -> PromptXChatSendResponse

    func abortRun(sessionKey: String, runId: String) async throws
    func listSessions(limit: Int?) async throws -> PromptXChatSessionsListResponse

    func requestHealth(timeoutMs: Int) async throws -> Bool
    func events() -> AsyncStream<PromptXChatTransportEvent>

    func setActiveSessionKey(_ sessionKey: String) async throws
}

extension PromptXChatTransport {
    public func setActiveSessionKey(_: String) async throws {}

    public func abortRun(sessionKey _: String, runId _: String) async throws {
        throw NSError(
            domain: "PromptXChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "chat.abort not supported by this transport"])
    }

    public func listSessions(limit _: Int?) async throws -> PromptXChatSessionsListResponse {
        throw NSError(
            domain: "PromptXChatTransport",
            code: 0,
            userInfo: [NSLocalizedDescriptionKey: "sessions.list not supported by this transport"])
    }
}
