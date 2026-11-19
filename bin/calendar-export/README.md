# calendar-export

Writes the events in selected calendars in the local Apple Calendar store to `~/notes/_assistant/calendar-export.json`, covering the past 14 days through the next 28 days. The output is meant for programs to read, not people.

The calendars are listed by identifier in `calendarIDs` at the top of `main.swift`. To add one, run `calendar-export --list`, copy its identifier into that list, and rebuild. An identifier that isn't found is reported in the error log, and the rest are still exported.

An optional argument overrides the output path: `calendar-export ~/tmp/cal.json`. `calendar-export --list` prints every calendar in the store, one per line, with its account, account type and identifier, then exits without writing anything.

It requires macOS 14 or later.

## What it includes

- Recurring events appear as individual occurrences. An occurrence you moved or edited on its own shows its new time and details and has `modified_occurrence: true`. A deleted occurrence is left out, just as in Calendar.
- Events the organizer canceled, and invitations you declined, are left out.
- An event on two calendars appears once for each calendar.
- It reports what this Mac's Calendar store has synced. A change made on your phone appears once iCloud has synced it to the Mac, and then at the next run.

## Output

Keys are sorted alphabetically. Optional fields are left out when they have no value.

```json
{
  "calendars": [{ "account": "iCloud", "id": "A61B0C38-…", "title": "Personal" }],
  "events": [
    {
      "all_day": true,
      "calendar": "Personal",
      "calendar_id": "A61B0C38-…",
      "days_in_range": ["2026-11-17", "2026-11-18", "2026-11-19"],
      "end": "2026-11-19T23:59:59-05:00",
      "first_day": "2026-11-17",
      "last_day": "2026-11-19",
      "modified_occurrence": false,
      "multi_day": true,
      "recurring": false,
      "start": "2026-11-17T00:00:00-05:00",
      "status": "confirmed",
      "title": "Conference",
      "uid": "…"
    }
  ],
  "generated_at": "2026-11-19T10:15:00-05:00",
  "range_first_day": "2026-11-05",
  "range_last_day": "2026-12-17",
  "time_zone": "America/New_York"
}
```

Each event:

| Field | Meaning |
| --- | --- |
| `title`, `calendar`, `calendar_id` | The event's title, and the name and identifier of its calendar. |
| `start`, `end` | ISO 8601 with UTC offset. For all-day events, use `first_day` and `last_day` instead. |
| `all_day` | Whether it is an all-day event. |
| `first_day`, `last_day` | Local dates the event starts and ends on, inclusive. |
| `multi_day` | True when the event continues past its first day, including a timed event that runs past midnight. |
| `days_in_range` | Every local date the event covers that falls inside the export range. An event that began before the range still lists the days it covers within it. |
| `status` | The organizer's status: `confirmed`, `tentative` or `none`. |
| `my_response` | Your answer if you were invited: `accepted`, `tentative`, `pending` (not answered) and so on. Absent if you weren't invited. |
| `recurring` | Whether the event is part of a recurring series, including an occurrence edited on its own. |
| `modified_occurrence` | True for a single occurrence edited apart from its series. |
| `original_start` | For a modified occurrence, when the series originally scheduled it. Compare it with `start` to see that an occurrence was moved. |
| `location`, `notes`, `url` | As entered. Notes are complete, newlines included, except that Fantastical's "This event is managed by Fantastical…" notice is removed. |
| `uid` | The iCalendar UID. Every occurrence of a series shares it, modified occurrences included. |

## Building

```
cd bin/calendar-export
make
```

This compiles with `swiftc` into `build/calendar-export`, embeds `Info.plist` in the binary (macOS needs the usage description there before it will grant calendar access to a command-line tool), and signs it ad hoc. The binary goes in `build/` because, with `Info.plist` beside it, `codesign` would treat the folder as a bundle and seal the source files as well; editing any of them would then break the signature.

Run it by hand as `build/calendar-export --list`.

## Calendar permission

macOS asks for calendar access the first time the program runs, and the grant belongs to whichever process launched it. Running it from Terminal grants Terminal access, not the launchd job. So approve it from a launchd run:

```
make launchd   # from the repository root
launchctl load ~/Library/LaunchAgents/com.lmullen.calendar-export.plist
```

`RunAtLoad` starts it at once and the permission prompt appears; click Allow. It then shows up under System Settings → Privacy & Security → Calendars.

An ad-hoc signature changes on every rebuild, and macOS then treats the binary as a new program. After rebuilding, reset and approve again:

```
tccutil reset Calendar com.lmullen.calendar-export
launchctl kickstart -k gui/$(id -u)/com.lmullen.calendar-export
```

To avoid that, sign with a real certificate: `make SIGN_IDENTITY="Apple Development: …"`.

## Scheduled execution with launchd

`launchd/com.lmullen.calendar-export.plist` runs it at load and then every 15 minutes.

To unload:

```
launchctl unload ~/Library/LaunchAgents/com.lmullen.calendar-export.plist
```

To trigger a single immediate run (the job must already be loaded):

```
launchctl start com.lmullen.calendar-export
```

## Logs

- `~/Library/Logs/calendar-export.log` gets one line per successful run.
- `~/Library/Logs/calendar-export.err` gets errors. A run that fails, for example because access was denied, leaves the existing JSON file alone.
