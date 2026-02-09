import Foundation

public enum PromptXChatCommand: String, Codable, Sendable {
    case push = "chat.push"
}

public struct PromptXChatPushParams: Codable, Sendable, Equatable {
    public var text: String
    public var speak: Bool?

    public init(text: String, speak: Bool? = nil) {
        self.text = text
        self.speak = speak
    }
}

public struct PromptXChatPushPayload: Codable, Sendable, Equatable {
    public var messageId: String?

    public init(messageId: String? = nil) {
        self.messageId = messageId
    }
}
