import Foundation

public enum PromptXRemindersCommand: String, Codable, Sendable {
    case list = "reminders.list"
    case add = "reminders.add"
}

public enum PromptXReminderStatusFilter: String, Codable, Sendable {
    case incomplete
    case completed
    case all
}

public struct PromptXRemindersListParams: Codable, Sendable, Equatable {
    public var status: PromptXReminderStatusFilter?
    public var limit: Int?

    public init(status: PromptXReminderStatusFilter? = nil, limit: Int? = nil) {
        self.status = status
        self.limit = limit
    }
}

public struct PromptXRemindersAddParams: Codable, Sendable, Equatable {
    public var title: String
    public var dueISO: String?
    public var notes: String?
    public var listId: String?
    public var listName: String?

    public init(
        title: String,
        dueISO: String? = nil,
        notes: String? = nil,
        listId: String? = nil,
        listName: String? = nil)
    {
        self.title = title
        self.dueISO = dueISO
        self.notes = notes
        self.listId = listId
        self.listName = listName
    }
}

public struct PromptXReminderPayload: Codable, Sendable, Equatable {
    public var identifier: String
    public var title: String
    public var dueISO: String?
    public var completed: Bool
    public var listName: String?

    public init(
        identifier: String,
        title: String,
        dueISO: String? = nil,
        completed: Bool,
        listName: String? = nil)
    {
        self.identifier = identifier
        self.title = title
        self.dueISO = dueISO
        self.completed = completed
        self.listName = listName
    }
}

public struct PromptXRemindersListPayload: Codable, Sendable, Equatable {
    public var reminders: [PromptXReminderPayload]

    public init(reminders: [PromptXReminderPayload]) {
        self.reminders = reminders
    }
}

public struct PromptXRemindersAddPayload: Codable, Sendable, Equatable {
    public var reminder: PromptXReminderPayload

    public init(reminder: PromptXReminderPayload) {
        self.reminder = reminder
    }
}
