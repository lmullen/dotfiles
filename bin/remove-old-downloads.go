package main

import (
	"flag"
	"fmt"
	"log/slog"
	"os"
	"path/filepath"
	"time"
)

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

func main() {
	dryRun := flag.Bool("dry-run", false, "Show what would be moved to the trash without actually moving files")
	flag.Parse()

	opts := &slog.HandlerOptions{
		Level:     slog.LevelInfo,
		AddSource: false,
	}
	logger := slog.New(slog.NewJSONHandler(os.Stdout, opts))
	slog.SetDefault(logger)

	homeDir, err := os.UserHomeDir()
	if err != nil {
		logger.Error("failed to get home directory", "error", err)
		return
	}

	downloadsDir := filepath.Join(homeDir, "Downloads")
	now := time.Now()
	ageThreshold := 24 * time.Hour

	logger.Info(fmt.Sprintf("checking ~/Downloads folder for files and moving files older than %v to trash", ageThreshold))

	var filesFound int
	var totalSize int64

	err = filepath.Walk(downloadsDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			logger.Error("failed to access path", "path", path, "error", err)
			return nil
		}

		if info.IsDir() {
			if path != downloadsDir {
				logger.Info("skipping directory", "name", info.Name())
			}
			return nil
		}

		if info.Name() == ".DS_Store" {
			logger.Info("skipping file", "name", info.Name())
			return nil
		}

		age := now.Sub(info.ModTime())
		attrs := []any{
			"name", info.Name(),
			"size", formatSize(info.Size()),
			"age", age.String(),
		}

		if age > ageThreshold {
			filesFound++
			totalSize += info.Size()

			if *dryRun {
				logger.Info("would move file", attrs...)
			} else {
				trashPath := filepath.Join(homeDir, ".Trash", info.Name())
				if err := os.Rename(path, trashPath); err != nil {
					logger.Error("failed to move file to trash", append(attrs, "error", err)...)
					return nil
				}
				logger.Info("moved file to trash", attrs...)
			}
		} else {
			logger.Info("skipping file", attrs...)
		}
		return nil
	})

	if err != nil {
		logger.Error("failed to walk directory", "error", err)
		return
	}

	summary := []any{
		"count", filesFound,
		"total_size", formatSize(totalSize),
	}
	if *dryRun {
		logger.Info("dry run complete", summary...)
	} else {
		logger.Info("cleanup complete", summary...)
	}
}
