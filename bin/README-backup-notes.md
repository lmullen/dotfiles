# backup-notes.sh

Backs up `~/notes` into a timestamped zip file stored in `~/backups/notes/`. The zip filename uses an ISO 8601 UTC timestamp: `notes-backup-2026-02-26T020000Z.zip`.

The script exits with an error if `~/notes` does not exist. It creates `~/backups/notes/` if it doesn't already exist. Old backups are not cleaned up automatically.

## Running manually

```
./bin/backup-notes.sh
```

## Scheduled execution with launchd

A launchd plist at `launchd/com.lmullen.backup-notes.plist` runs the script daily at 2:00 AM. If the computer is asleep at that time, macOS runs it at next wake.

Symlink the plist and load it:

```
make launchd
launchctl load ~/Library/LaunchAgents/com.lmullen.backup-notes.plist
```

To unload:

```
launchctl unload ~/Library/LaunchAgents/com.lmullen.backup-notes.plist
```

To trigger a single immediate run (the job must already be loaded):

```
launchctl start com.lmullen.backup-notes
```

To check that the job is registered:

```
launchctl list | grep backup-notes
```

## Logs

Stdout and stderr are written to `~/backups/notes/`:

- `backup-notes.log` — success messages
- `backup-notes.err` — error output
