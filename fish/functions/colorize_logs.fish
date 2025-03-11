# Pipe JSON logs to this function where there is a key `"level":"INFO"`.
# Intended for use with Go's log/slog package.
function colorize_logs --description="Colorize JSON structured logging from Go"
    # Colors drawn from Ghostty theme:
    # /Applications/Ghostty.app/Contents/Resources/ghostty/themes/GitHub-Dark-Default
    # /Applications/Ghostty.app/Contents/Resources/ghostty/themes/GitHub-Light-Default
    if test "$(defaults read $HOME/Library/Preferences/.GlobalPreferences.plist AppleInterfaceStyle 2>/dev/null)" = Dark
        # theme is dark
        set -f color_debug "38;2;110;118;129" # #6e7681 - Palette 8 (Dark Gray)
        set -f color_info "38;2;177;186;196" # #8c959f - Palette 7 (Light Gray)
        set -f color_warn "38;2;210;153;34" # #d29922 - Palette 3 (Light Yellow)
        set -f color_error "38;2;255;123;114" # #ff7b72 - Palette 1 (Red)
        set -f color_reset "38;2;230;237;243" # #e6edf3 - Foreground
    else
        # theme is light
        # Define color variables using RGB values
        set -f color_debug "38;2;140;149;159" # #8c959f - Palette 15 (Light Gray)
        set -f color_info "38;2;36;41;47" # #24292f - Palette 0 (Dark Gray)
        set -f color_warn "38;2;33;139;255" # #218bff - Palette 12 (Light Blue)
        set -f color_error "38;2;207;34;46" # #cf222e - Palette 1 (Red)
        set -f color_reset "38;2;36;41;47" # #24292f - Palette 0 (Dark Gray)
    end

    # Apply colors based on log level
    jq -r '.level as $level | 
    if $level == "DEBUG" then "\u001b['"$color_debug"'m" + (. | tostring) + "\u001b['"$color_reset"'m"
    elif $level == "INFO" then "\u001b['"$color_info"'m" + (. | tostring) + "\u001b['"$color_reset"'m" 
    elif $level == "WARN" then "\u001b['"$color_warn"'m" + (. | tostring) + "\u001b['"$color_reset"'m"
    elif $level == "ERROR" then "\u001b['"$color_error"'m" + (. | tostring) + "\u001b['"$color_reset"'m"
    else . | tostring
    end'
end

abbr --add cl --position command colorize_logs
