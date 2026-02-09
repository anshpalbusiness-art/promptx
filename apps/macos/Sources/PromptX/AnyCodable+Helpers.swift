import PromptXKit
import PromptXProtocol
import Foundation

// Prefer the PromptXKit wrapper to keep gateway request payloads consistent.
typealias AnyCodable = PromptXKit.AnyCodable
typealias InstanceIdentity = PromptXKit.InstanceIdentity

extension AnyCodable {
    var stringValue: String? { self.value as? String }
    var boolValue: Bool? { self.value as? Bool }
    var intValue: Int? { self.value as? Int }
    var doubleValue: Double? { self.value as? Double }
    var dictionaryValue: [String: AnyCodable]? { self.value as? [String: AnyCodable] }
    var arrayValue: [AnyCodable]? { self.value as? [AnyCodable] }

    var foundationValue: Any {
        switch self.value {
        case let dict as [String: AnyCodable]:
            dict.mapValues { $0.foundationValue }
        case let array as [AnyCodable]:
            array.map(\.foundationValue)
        default:
            self.value
        }
    }
}

extension PromptXProtocol.AnyCodable {
    var stringValue: String? { self.value as? String }
    var boolValue: Bool? { self.value as? Bool }
    var intValue: Int? { self.value as? Int }
    var doubleValue: Double? { self.value as? Double }
    var dictionaryValue: [String: PromptXProtocol.AnyCodable]? { self.value as? [String: PromptXProtocol.AnyCodable] }
    var arrayValue: [PromptXProtocol.AnyCodable]? { self.value as? [PromptXProtocol.AnyCodable] }

    var foundationValue: Any {
        switch self.value {
        case let dict as [String: PromptXProtocol.AnyCodable]:
            dict.mapValues { $0.foundationValue }
        case let array as [PromptXProtocol.AnyCodable]:
            array.map(\.foundationValue)
        default:
            self.value
        }
    }
}
