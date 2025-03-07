// Move files older than a certain age from the ~/Downloads folder to the Trash
package main

import (
	"flag"
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"time"
)

// Files modified more recently than this value will not be moved
const ageThreshold = 1 * time.Hour

// A dry run uses more verbose logs and skips moving any files
var dryRun bool

func main() {
	flag.BoolVar(&dryRun, "dryrun", false, "Show what would be moved to the trash without actually moving files")
	flag.Parse()

	loglevel := slog.LevelInfo
	if dryRun {
		loglevel = slog.LevelDebug
	}

	opts := &slog.HandlerOptions{
		Level: loglevel,
	}
	slog.SetDefault(slog.New(slog.NewJSONHandler(os.Stdout, opts)))

	homeDir, err := os.UserHomeDir()
	if err != nil {
		slog.Error("failed to get home directory", "error", err)
		os.Exit(1)
	}

	downloadsDir := filepath.Join(homeDir, "Downloads")
	now := time.Now()

	slog.Debug(fmt.Sprintf("checking %s folder for files older than %v", downloadsDir, ageThreshold))

	err = filepath.Walk(downloadsDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			slog.Error("failed to access path", "path", path, "error", err)
			return nil
		}

		if info.IsDir() {
			if path != downloadsDir {
				slog.Debug("skipping directory", "name", info.Name())
			}
			return nil
		}

		if info.Name() == ".DS_Store" {
			slog.Debug("skipping file", "name", info.Name())
			return nil
		}

		age := now.Sub(info.ModTime())
		attrs := []any{
			"name", info.Name(),
			"size", formatSize(info.Size()),
			"age", age.String(),
		}

		if age > ageThreshold {

			if dryRun {
				slog.Info("would move file", attrs...)
			} else {
				trashPath := filepath.Join(homeDir, ".Trash", info.Name())
				err = os.Rename(path, trashPath)
				if err != nil {
					slog.Error("failed to move file to trash", append(attrs, "error", err)...)
					return nil
				}
				slog.Info("moved file to trash", attrs...)
			}
		} else {
			slog.Debug("skipping file", attrs...)
		}
		return nil
	})

	if err != nil {
		slog.Error("failed to walk directory", "error", err)
		os.Exit(1)
	}

}

// formatSize returns a human-readable string for the size of a file
func formatSize(bytes int64) string {
	const unit = 1024
	if bytes < unit {
		return fmt.Sprintf("%d B", bytes)
	}
	div, exp := int64(unit), 0
	for n := bytes / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	return fmt.Sprintf("%.1f %cB", float64(bytes)/float64(div), "KMGTPE"[exp])
}
