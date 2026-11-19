// calendar-export: write events from selected calendars in the local Apple
// Calendar store to a JSON file, covering the past two weeks and the upcoming
// four weeks. Meant to be run unattended by launchd.
//
// Usage: calendar-export [output-path]
//        calendar-export --list    (print every calendar with its account, then exit)
// Default output: ~/notes/_assistant/calendar-export.json

import EventKit
import Foundation

let pastDays = 14
let futureDays = 28

// The calendars to export, by identifier (from `calendar-export --list`).
// Identifiers survive renaming a calendar. The comments are just for humans.
let calendarIDs: [String] = [
    "2431D02E-6826-47A9-A669-A44325164A68",  // iCloud: Deb/Lincoln
    "C929D128-B6F4-43B6-B617-9846868BF2EE",  // iCloud: Information
    "4066AC94-130B-4EF5-BE79-08298C5A121A",  // iCloud: Maggie
    "26D8A5FB-073C-456C-9FA9-A51BCE4323DA",  // iCloud: Mullen children
    "B7CCD2BD-3156-4545-865F-1D971C9428E4",  // iCloud: Paul's calendar
    "A61B0C38-A8A7-44BE-A780-EE57E9A97EF3",  // iCloud: Personal
]

func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data("calendar-export: \(message)\n".utf8))
    exit(1)
}

func accountKind(_ type: EKSourceType) -> String {
    switch type {
    case .local: return "On My Mac"
    case .exchange: return "Exchange"
    case .calDAV: return "CalDAV"
    case .mobileMe: return "iCloud (MobileMe)"
    case .subscribed: return "Subscribed"
    case .birthdays: return "Birthdays"
    @unknown default: return "Other"
    }
}

/// How the account owner answered the invitation, or nil if they weren't invited.
func myStatus(_ event: EKEvent) -> EKParticipantStatus? {
    event.attendees?.first(where: \.isCurrentUser)?.participantStatus
}

func statusName(_ status: EKEventStatus) -> String {
    switch status {
    case .none: return "none"
    case .confirmed: return "confirmed"
    case .tentative: return "tentative"
    case .canceled: return "canceled"
    @unknown default: return "unknown"
    }
}

func responseName(_ status: EKParticipantStatus) -> String {
    switch status {
    case .unknown: return "unknown"
    case .pending: return "pending"
    case .accepted: return "accepted"
    case .declined: return "declined"
    case .tentative: return "tentative"
    case .delegated: return "delegated"
    case .completed: return "completed"
    case .inProcess: return "in_process"
    @unknown default: return "unknown"
    }
}

func nonEmpty(_ s: String?) -> String? {
    guard let t = s?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
    return t
}

/// Fantastical adds this to the notes of every event it syncs; it says nothing
/// about the event.
let fantasticalNotice = "This event is managed by Fantastical. Do not edit it, changes will be overwritten."

func cleanNotes(_ s: String?) -> String? {
    nonEmpty(s?.replacingOccurrences(of: fantasticalNotice, with: ""))
}

/// The series UID. An occurrence edited on its own has "/RID=<original date>"
/// appended to its external identifier; drop it so every occurrence matches.
func seriesUID(_ s: String?) -> String? {
    guard let s = nonEmpty(s) else { return nil }
    if let r = s.range(of: "/RID=") { return String(s[..<r.lowerBound]) }
    return s
}

/// Day arithmetic and date strings, all in the user's current time zone.
struct Dates {
    let calendar = Calendar.current
    let day: DateFormatter
    let instant: ISO8601DateFormatter

    init() {
        day = DateFormatter()
        day.locale = Locale(identifier: "en_US_POSIX")
        day.timeZone = TimeZone.current
        day.dateFormat = "yyyy-MM-dd"
        instant = ISO8601DateFormatter()
        instant.timeZone = TimeZone.current
        instant.formatOptions = [.withInternetDateTime]
    }

    func startOfDay(_ date: Date) -> Date { calendar.startOfDay(for: date) }

    func addDays(_ n: Int, to date: Date) -> Date {
        calendar.date(byAdding: .day, value: n, to: date)!
    }

    /// The last day an event touches. EventKit end dates are exclusive in
    /// practice (midnight, or 23:59:59 for all-day events), so step back a second.
    func lastDay(of event: EKEvent) -> Date {
        let end = max(event.endDate, event.startDate)
        return startOfDay(end == event.startDate ? end : end.addingTimeInterval(-1))
    }
}

// MARK: - JSON shape (keys are written in snake_case)

struct ExportCalendar: Encodable {
    let id: String
    let title: String
    let account: String
}

struct ExportEvent: Encodable {
    let title: String
    let calendar: String
    let calendarId: String
    /// ISO 8601 with UTC offset. For all-day events, use first_day and last_day.
    let start: String
    let end: String
    let allDay: Bool
    /// Local dates, inclusive. Equal unless the event continues past its first day.
    let firstDay: String
    let lastDay: String
    let multiDay: Bool
    /// Every local date the event covers that falls inside the export range.
    let daysInRange: [String]
    /// Organizer's status: confirmed, tentative or none. Canceled events are omitted.
    let status: String
    /// The account owner's answer to an invitation; absent if not invited.
    /// Declined invitations are omitted.
    let myResponse: String?
    /// True for any occurrence of a recurring series, edited or not.
    let recurring: Bool
    /// True for a single occurrence edited apart from its series.
    let modifiedOccurrence: Bool
    /// For a modified occurrence, when the series originally scheduled it.
    let originalStart: String?
    let location: String?
    let notes: String?
    let url: String?
    /// The event's iCalendar UID; the same for every occurrence of a series.
    let uid: String?
}

struct Export: Encodable {
    let generatedAt: String
    let timeZone: String
    let rangeFirstDay: String
    let rangeLastDay: String
    let calendars: [ExportCalendar]
    let events: [ExportEvent]
}

// MARK: - Main

let listOnly = CommandLine.arguments.dropFirst().first == "--list"

let outputURL: URL = CommandLine.arguments.count > 1 && !listOnly
    ? URL(fileURLWithPath: (CommandLine.arguments[1] as NSString).expandingTildeInPath)
    : FileManager.default.homeDirectoryForCurrentUser
        .appendingPathComponent("notes/_assistant/calendar-export.json")

var store = EKEventStore()

switch EKEventStore.authorizationStatus(for: .event) {
case .fullAccess:
    break
case .notDetermined:
    // Shows the macOS permission prompt once. When run by launchd, the grant
    // belongs to this binary, so approve the prompt from a launchd run.
    do {
        guard try await store.requestFullAccessToEvents() else {
            fail("calendar access was denied")
        }
    } catch {
        fail("requesting calendar access failed: \(error.localizedDescription)")
    }
    // A store created before the grant can come back empty; start fresh.
    store = EKEventStore()
default:
    fail("""
        no full access to calendars. Allow it in System Settings → Privacy & \
        Security → Calendars, or reset with `tccutil reset Calendar \
        com.lmullen.calendar-export` and run again.
        """)
}

if listOnly {
    let all = store.calendars(for: .event)
        .sorted { ($0.source.title, $0.title) < ($1.source.title, $1.title) }
    print("Account\tAccount type\tCalendar\tIdentifier")
    for c in all {
        print("\(c.source.title)\t\(accountKind(c.source.sourceType))\t\(c.title)\t\(c.calendarIdentifier)")
    }
    exit(0)
}

let dates = Dates()
let now = Date()
let today = dates.startOfDay(now)
let rangeStart = dates.addDays(-pastDays, to: today)
let rangeEnd = dates.addDays(futureDays + 1, to: today)  // exclusive: through the 28th day
let lastRangeDay = dates.addDays(-1, to: rangeEnd)

let calendars = store.calendars(for: .event)
    .filter { calendarIDs.contains($0.calendarIdentifier) }
    .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }

// Keep going with whatever was found, but say so in the error log.
let missing = Set(calendarIDs).subtracting(calendars.map(\.calendarIdentifier))
if !missing.isEmpty {
    FileHandle.standardError.write(Data(
        "calendar-export: calendars not found (run --list): \(missing.sorted().joined(separator: ", "))\n".utf8))
}

// The predicate returns every event that overlaps the range, with recurring
// series expanded into individual occurrences. An occurrence edited on its own
// comes back with its edited time and details, and a deleted occurrence is left
// out, so the store's own recurrence rules and exceptions are what we report.
// The same event on two calendars comes back once per calendar, and is kept.
// An empty calendar list must not reach the predicate: nil there means "all calendars".
let fetched: [EKEvent] = calendars.isEmpty ? [] : store.events(
    matching: store.predicateForEvents(withStart: rangeStart, end: rangeEnd, calendars: calendars))

// Leave out what isn't happening: events the organizer canceled, and
// invitations the account owner declined.
let events = fetched
    .filter { $0.status != .canceled && myStatus($0) != .declined }
    .sorted {
        ($0.startDate, $0.calendar.title, $0.title ?? "")
            < ($1.startDate, $1.calendar.title, $1.title ?? "")
    }

let exported: [ExportEvent] = events.map { event in
    let first = dates.startOfDay(event.startDate)
    let last = dates.lastDay(of: event)
    var inRange: [String] = []
    var day = max(first, rangeStart)
    while day <= min(last, lastRangeDay) {
        inRange.append(dates.day.string(from: day))
        day = dates.addDays(1, to: day)
    }
    return ExportEvent(
        title: nonEmpty(event.title) ?? "(No title)",
        calendar: event.calendar.title,
        calendarId: event.calendar.calendarIdentifier,
        start: dates.instant.string(from: event.startDate),
        end: dates.instant.string(from: event.endDate),
        allDay: event.isAllDay,
        firstDay: dates.day.string(from: first),
        lastDay: dates.day.string(from: last),
        multiDay: last > first,
        daysInRange: inRange,
        status: statusName(event.status),
        myResponse: myStatus(event).map(responseName),
        // A detached occurrence carries no recurrence rules of its own.
        recurring: event.hasRecurrenceRules || event.isDetached,
        modifiedOccurrence: event.isDetached,
        originalStart: event.isDetached
            ? event.occurrenceDate.map { dates.instant.string(from: $0) } : nil,
        location: nonEmpty(event.location),
        notes: cleanNotes(event.notes),
        url: event.url?.absoluteString,
        uid: seriesUID(event.calendarItemExternalIdentifier))
}

let export = Export(
    generatedAt: dates.instant.string(from: now),
    timeZone: TimeZone.current.identifier,
    rangeFirstDay: dates.day.string(from: rangeStart),
    rangeLastDay: dates.day.string(from: lastRangeDay),
    calendars: calendars.map {
        ExportCalendar(id: $0.calendarIdentifier, title: $0.title, account: $0.source.title)
    },
    events: exported)

let encoder = JSONEncoder()
encoder.keyEncodingStrategy = .convertToSnakeCase
encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

do {
    let data = try encoder.encode(export)
    try FileManager.default.createDirectory(
        at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: outputURL, options: .atomic)
} catch {
    fail("writing \(outputURL.path) failed: \(error.localizedDescription)")
}

print("\(export.generatedAt): wrote \(exported.count) events from \(calendars.count) calendars to \(outputURL.path)")
