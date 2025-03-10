# Pipe JSON logs to this function where there is a key `"level":"INFO"`.
# Intended for use with Go's log/slog package.
function colorize_logs --description="Colorize JSON structured logging from Go"
  # Colors drawn from Ghostty theme:
  # /Applications/Ghostty.app/Contents/Resources/ghostty/themes/GitHub-Light-Default

  # Define color variables using RGB values
  set -l color_debug "38;2;140;149;159"   # #8c959f - Palette 15 (Light Gray)
  set -l color_info "38;2;36;41;47"       # #24292f - Palette 0 (Dark Gray)
  set -l color_warn "38;2;33;139;255"     # #218bff - Palette 12 (Light Blue)
  set -l color_error "38;2;207;34;46"     # #cf222e - Palette 1 (Red)
  
  # Reset code
  set -l color_reset "0"
  
  # Apply colors based on log level
  jq -r '.level as $level | 
    if $level == "DEBUG" then "\u001b['"$color_debug"'m" + (. | tostring) + "\u001b['"$color_reset"'m"
    elif $level == "INFO" then "\u001b['"$color_info"'m" + (. | tostring) + "\u001b['"$color_reset"'m" 
    elif $level == "WARN" then "\u001b['"$color_warn"'m" + (. | tostring) + "\u001b['"$color_reset"'m"
    elif $level == "ERROR" then "\u001b['"$color_error"'m" + (. | tostring) + "\u001b['"$color_reset"'m"
    else . | tostring
    end'
end

abbr --add cl --position command "colorize_logs"
