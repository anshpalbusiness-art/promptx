import AppKit
import PromptXChatUI
import Foundation
import Testing
@testable import PromptX

@Suite(.serialized)
@MainActor
struct WebChatSwiftUISmokeTests {
    private struct TestTransport: PromptXChatTransport, Sendable {
        func requestHistory(sessionKey: String) async throws -> PromptXChatHistoryPayload {
            let json = """
            {"sessionKey":"\(sessionKey)","sessionId":null,"messages":[],"thinkingLevel":"off"}
            """
            return try JSONDecoder().decode(PromptXChatHistoryPayload.self, from: Data(json.utf8))
        }

        func sendMessage(
            sessionKey _: String,
            message _: String,
            thinking _: String,
            idempotencyKey _: String,
            attachments _: [PromptXChatAttachmentPayload]) async throws -> PromptXChatSendResponse
        {
            let json = """
            {"runId":"\(UUID().uuidString)","status":"ok"}
            """
            return try JSONDecoder().decode(PromptXChatSendResponse.self, from: Data(json.utf8))
        }

        func requestHealth(timeoutMs _: Int) async throws -> Bool { true }

        func events() -> AsyncStream<PromptXChatTransportEvent> {
            AsyncStream { continuation in
                continuation.finish()
            }
        }

        func setActiveSessionKey(_: String) async throws {}
    }

    @Test func windowControllerShowAndClose() {
        let controller = WebChatSwiftUIWindowController(
            sessionKey: "main",
            presentation: .window,
            transport: TestTransport())
        controller.show()
        controller.close()
    }

    @Test func panelControllerPresentAndClose() {
        let anchor = { NSRect(x: 200, y: 400, width: 40, height: 40) }
        let controller = WebChatSwiftUIWindowController(
            sessionKey: "main",
            presentation: .panel(anchorProvider: anchor),
            transport: TestTransport())
        controller.presentAnchored(anchorProvider: anchor)
        controller.close()
    }
}
