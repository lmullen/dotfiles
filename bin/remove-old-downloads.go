package main

import (
	"flag"
	"fmt"
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

func formatDuration(d time.Duration) string {
	days := int(d.Hours() / 24)
	hours := int(d.Hours()) % 24
	if days > 0 {
		if hours > 0 {
			return fmt.Sprintf("%dd %dh old", days, hours)
		}
		return fmt.Sprintf("%dd old", days)
	}
	return fmt.Sprintf("%dh old", hours)
}

func main() {
	dryRun := flag.Bool("dry-run", false, "Show what would be moved without actually moving files")
	flag.Parse()

	homeDir, err := os.UserHomeDir()
	if err != nil {
		fmt.Printf("Error getting home directory: %v\n", err)
		return
	}

	downloadsDir := filepath.Join(homeDir, "Downloads")

	if *dryRun {
		fmt.Println("DRY RUN MODE - No files will be moved")
		fmt.Println("----------------------------------------")
	}

	now := time.Now()
	var filesFound int
	var totalSize int64

	err = filepath.Walk(downloadsDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			if path != downloadsDir {
				fmt.Printf("Skipping directory: %s\n", info.Name())
			}
			return nil
		}

		age := now.Sub(info.ModTime())
		if age > 24*time.Hour {
			filesFound++
			totalSize += info.Size()

			if *dryRun {
				fmt.Printf("Would move: %s (size: %s, age: %s)\n",
					info.Name(),
					formatSize(info.Size()),
					formatDuration(age))
			} else {
				trashPath := filepath.Join(homeDir, ".Trash", info.Name())
				err := os.Rename(path, trashPath)
				if err != nil {
					fmt.Printf("Error moving %s to trash: %v\n", info.Name(), err)
					return nil
				}
				fmt.Printf("Moved: %s (size: %s, age: %s)\n",
					info.Name(),
					formatSize(info.Size()),
					formatDuration(age))
			}
		} else {
			fmt.Printf("Skipping: %s (size: %s, age: %s)\n",
				info.Name(),
				formatSize(info.Size()),
				formatDuration(age))
		}

		return nil
	})

	if err != nil {
		fmt.Printf("Error walking through Downloads directory: %v\n", err)
		return
	}

	fmt.Println("----------------------------------------")
	if *dryRun {
		fmt.Printf("Found %d files that would be moved to trash (total size: %s)\n",
			filesFound, formatSize(totalSize))
	} else {
		fmt.Printf("Moved %d files to trash (total size: %s)\n",
			filesFound, formatSize(totalSize))
	}
}
