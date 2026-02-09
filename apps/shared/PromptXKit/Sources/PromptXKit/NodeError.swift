import Foundation

public enum PromptXNodeErrorCode: String, Codable, Sendable {
    case notPaired = "NOT_PAIRED"
    case unauthorized = "UNAUTHORIZED"
    case backgroundUnavailable = "NODE_BACKGROUND_UNAVAILABLE"
    case invalidRequest = "INVALID_REQUEST"
    case unavailable = "UNAVAILABLE"
}

public struct PromptXNodeError: Error, Codable, Sendable, Equatable {
    public var code: PromptXNodeErrorCode
    public var message: String
    public var retryable: Bool?
    public var retryAfterMs: Int?

    public init(
        code: PromptXNodeErrorCode,
        message: String,
        retryable: Bool? = nil,
        retryAfterMs: Int? = nil)
    {
        self.code = code
        self.message = message
        self.retryable = retryable
        self.retryAfterMs = retryAfterMs
    }
}
