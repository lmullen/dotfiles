# syntax=docker/dockerfile:1

# Overlay recipe for the claude-statusline mixin: one script, on PATH.
#
# v2 shipped the script through the kit's files/ tree to ~/.claude/statusline.sh.
# v3 has no files/ convention (a mixin's layers are its content), so the script
# is COPYed into the overlay. It lands in /usr/local/bin rather than the agent's
# home: an overlay's directory entries override the base's, so shipping
# /home/agent/.claude would also have to reproduce the ownership of every
# parent, and whatever is at /home/agent may be a mounted volume that hides the
# file altogether. The parents COPY creates here (/usr, /usr/local,
# /usr/local/bin) are root-owned 0755, which is what the base has.
FROM scratch
COPY --chmod=0755 files/statusline.sh /usr/local/bin/claude-statusline
