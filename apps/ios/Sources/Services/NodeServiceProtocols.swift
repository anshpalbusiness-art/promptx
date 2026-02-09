import CoreLocation
import Foundation
import PromptXKit
import UIKit

protocol CameraServicing: Sendable {
    func listDevices() async -> [CameraController.CameraDeviceInfo]
    func snap(params: PromptXCameraSnapParams) async throws -> (format: String, base64: String, width: Int, height: Int)
    func clip(params: PromptXCameraClipParams) async throws -> (format: String, base64: String, durationMs: Int, hasAudio: Bool)
}

protocol ScreenRecordingServicing: Sendable {
    func record(
        screenIndex: Int?,
        durationMs: Int?,
        fps: Double?,
        includeAudio: Bool?,
        outPath: String?) async throws -> String
}

@MainActor
protocol LocationServicing: Sendable {
    func authorizationStatus() -> CLAuthorizationStatus
    func accuracyAuthorization() -> CLAccuracyAuthorization
    func ensureAuthorization(mode: PromptXLocationMode) async -> CLAuthorizationStatus
    func currentLocation(
        params: PromptXLocationGetParams,
        desiredAccuracy: PromptXLocationAccuracy,
        maxAgeMs: Int?,
        timeoutMs: Int?) async throws -> CLLocation
}

protocol DeviceStatusServicing: Sendable {
    func status() async throws -> PromptXDeviceStatusPayload
    func info() -> PromptXDeviceInfoPayload
}

protocol PhotosServicing: Sendable {
    func latest(params: PromptXPhotosLatestParams) async throws -> PromptXPhotosLatestPayload
}

protocol ContactsServicing: Sendable {
    func search(params: PromptXContactsSearchParams) async throws -> PromptXContactsSearchPayload
    func add(params: PromptXContactsAddParams) async throws -> PromptXContactsAddPayload
}

protocol CalendarServicing: Sendable {
    func events(params: PromptXCalendarEventsParams) async throws -> PromptXCalendarEventsPayload
    func add(params: PromptXCalendarAddParams) async throws -> PromptXCalendarAddPayload
}

protocol RemindersServicing: Sendable {
    func list(params: PromptXRemindersListParams) async throws -> PromptXRemindersListPayload
    func add(params: PromptXRemindersAddParams) async throws -> PromptXRemindersAddPayload
}

protocol MotionServicing: Sendable {
    func activities(params: PromptXMotionActivityParams) async throws -> PromptXMotionActivityPayload
    func pedometer(params: PromptXPedometerParams) async throws -> PromptXPedometerPayload
}

extension CameraController: CameraServicing {}
extension ScreenRecordService: ScreenRecordingServicing {}
extension LocationService: LocationServicing {}
