# syntax=docker/dockerfile:1

# Overlay recipe for the claude-config mixin: the status line script, on PATH.
#
# It lands in /usr/local/bin rather than the agent's home: an overlay's
# directory entries override the base's, so shipping /home/agent/.claude would
# also have to reproduce the ownership of every parent, and whatever is at
# /home/agent may be a mounted volume that hides the file altogether. The
# parents COPY creates here (/usr, /usr/local, /usr/local/bin) are root-owned
# 0755, which is what the base has. Without the executable bit Claude Code
# silently renders no status line, so the mode is set here.
FROM scratch
COPY --chmod=0755 files/statusline.sh /usr/local/bin/claude-statusline
