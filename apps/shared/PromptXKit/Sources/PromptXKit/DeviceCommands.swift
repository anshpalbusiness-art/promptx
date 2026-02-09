import Foundation

public enum PromptXDeviceCommand: String, Codable, Sendable {
    case status = "device.status"
    case info = "device.info"
}

public enum PromptXBatteryState: String, Codable, Sendable {
    case unknown
    case unplugged
    case charging
    case full
}

public enum PromptXThermalState: String, Codable, Sendable {
    case nominal
    case fair
    case serious
    case critical
}

public enum PromptXNetworkPathStatus: String, Codable, Sendable {
    case satisfied
    case unsatisfied
    case requiresConnection
}

public enum PromptXNetworkInterfaceType: String, Codable, Sendable {
    case wifi
    case cellular
    case wired
    case other
}

public struct PromptXBatteryStatusPayload: Codable, Sendable, Equatable {
    public var level: Double?
    public var state: PromptXBatteryState
    public var lowPowerModeEnabled: Bool

    public init(level: Double?, state: PromptXBatteryState, lowPowerModeEnabled: Bool) {
        self.level = level
        self.state = state
        self.lowPowerModeEnabled = lowPowerModeEnabled
    }
}

public struct PromptXThermalStatusPayload: Codable, Sendable, Equatable {
    public var state: PromptXThermalState

    public init(state: PromptXThermalState) {
        self.state = state
    }
}

public struct PromptXStorageStatusPayload: Codable, Sendable, Equatable {
    public var totalBytes: Int64
    public var freeBytes: Int64
    public var usedBytes: Int64

    public init(totalBytes: Int64, freeBytes: Int64, usedBytes: Int64) {
        self.totalBytes = totalBytes
        self.freeBytes = freeBytes
        self.usedBytes = usedBytes
    }
}

public struct PromptXNetworkStatusPayload: Codable, Sendable, Equatable {
    public var status: PromptXNetworkPathStatus
    public var isExpensive: Bool
    public var isConstrained: Bool
    public var interfaces: [PromptXNetworkInterfaceType]

    public init(
        status: PromptXNetworkPathStatus,
        isExpensive: Bool,
        isConstrained: Bool,
        interfaces: [PromptXNetworkInterfaceType])
    {
        self.status = status
        self.isExpensive = isExpensive
        self.isConstrained = isConstrained
        self.interfaces = interfaces
    }
}

public struct PromptXDeviceStatusPayload: Codable, Sendable, Equatable {
    public var battery: PromptXBatteryStatusPayload
    public var thermal: PromptXThermalStatusPayload
    public var storage: PromptXStorageStatusPayload
    public var network: PromptXNetworkStatusPayload
    public var uptimeSeconds: Double

    public init(
        battery: PromptXBatteryStatusPayload,
        thermal: PromptXThermalStatusPayload,
        storage: PromptXStorageStatusPayload,
        network: PromptXNetworkStatusPayload,
        uptimeSeconds: Double)
    {
        self.battery = battery
        self.thermal = thermal
        self.storage = storage
        self.network = network
        self.uptimeSeconds = uptimeSeconds
    }
}

public struct PromptXDeviceInfoPayload: Codable, Sendable, Equatable {
    public var deviceName: String
    public var modelIdentifier: String
    public var systemName: String
    public var systemVersion: String
    public var appVersion: String
    public var appBuild: String
    public var locale: String

    public init(
        deviceName: String,
        modelIdentifier: String,
        systemName: String,
        systemVersion: String,
        appVersion: String,
        appBuild: String,
        locale: String)
    {
        self.deviceName = deviceName
        self.modelIdentifier = modelIdentifier
        self.systemName = systemName
        self.systemVersion = systemVersion
        self.appVersion = appVersion
        self.appBuild = appBuild
        self.locale = locale
    }
}
