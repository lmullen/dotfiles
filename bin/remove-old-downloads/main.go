// Move files older than a certain age from the ~/Downloads folder to the Trash
package main

import (
	"flag"
	"fmt"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"time"
)

// Files modified more recently than this value will not be moved
const ageThreshold = 1 * time.Hour

// Set the time for checking how recently a file was modified
var now = time.Now()

// A dry run uses more verbose logs and skips moving any files
var dryRun bool

// The path to the ~/Downloads directory
var downloadsDir string

// The path to the Trash directory
var trashDir string

func main() {
	flag.BoolVar(&dryRun, "dry-run", false, "Show what would be moved to the trash without actually moving files")
	flag.Parse()

	// We will only log files that are moved by default; in a dry run, we will log much more
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
	downloadsDir = filepath.Join(homeDir, "Downloads")
	trashDir = filepath.Join(homeDir, ".Trash")

	slog.Debug("checking for old downloads",
		"downloadsDir", downloadsDir,
		"trashDir", trashDir,
		"ageThreshold", ageThreshold.String(),
	)

	// Walk the downloads directory and decide what to do with the files inside it
	err = filepath.Walk(downloadsDir, visitPath)
	if err != nil {
		slog.Error("failed to walk directory", "error", err)
		os.Exit(1)
	}

}

// visitPath determines what to do with a given file
func visitPath(path string, info os.FileInfo, err error) error {
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

	if age < ageThreshold {
		slog.Debug("skipping file", attrs...)
		return nil
	}

	if dryRun {
		slog.Info("would move file to trash", attrs...)
		return nil
	}

	trashPath := filepath.Join(trashDir, info.Name())
	err = os.Rename(path, trashPath)
	if err != nil {
		slog.Error("failed to move file to trash", append(attrs, "error", err)...)
		return nil
	}
	slog.Info("moved file to trash", attrs...)

	return nil
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

// dirIsEmpty checks if a directory has no files
func dirIsEmpty(path string) (bool, error) {
	dir, err := os.Open(path)
	if err != nil {
		return false, err
	}
	defer dir.Close()

	_, err = dir.Readdirnames(1)
	if err == io.EOF {
		return true, nil
	}
	return false, err
}
