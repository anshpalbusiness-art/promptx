import Foundation

public enum PromptXCameraCommand: String, Codable, Sendable {
    case list = "camera.list"
    case snap = "camera.snap"
    case clip = "camera.clip"
}

public enum PromptXCameraFacing: String, Codable, Sendable {
    case back
    case front
}

public enum PromptXCameraImageFormat: String, Codable, Sendable {
    case jpg
    case jpeg
}

public enum PromptXCameraVideoFormat: String, Codable, Sendable {
    case mp4
}

public struct PromptXCameraSnapParams: Codable, Sendable, Equatable {
    public var facing: PromptXCameraFacing?
    public var maxWidth: Int?
    public var quality: Double?
    public var format: PromptXCameraImageFormat?
    public var deviceId: String?
    public var delayMs: Int?

    public init(
        facing: PromptXCameraFacing? = nil,
        maxWidth: Int? = nil,
        quality: Double? = nil,
        format: PromptXCameraImageFormat? = nil,
        deviceId: String? = nil,
        delayMs: Int? = nil)
    {
        self.facing = facing
        self.maxWidth = maxWidth
        self.quality = quality
        self.format = format
        self.deviceId = deviceId
        self.delayMs = delayMs
    }
}

public struct PromptXCameraClipParams: Codable, Sendable, Equatable {
    public var facing: PromptXCameraFacing?
    public var durationMs: Int?
    public var includeAudio: Bool?
    public var format: PromptXCameraVideoFormat?
    public var deviceId: String?

    public init(
        facing: PromptXCameraFacing? = nil,
        durationMs: Int? = nil,
        includeAudio: Bool? = nil,
        format: PromptXCameraVideoFormat? = nil,
        deviceId: String? = nil)
    {
        self.facing = facing
        self.durationMs = durationMs
        self.includeAudio = includeAudio
        self.format = format
        self.deviceId = deviceId
    }
}
