#!/bin/sh

# Set up Solarized in Gnome Terminal
# http://unix.stackexchange.com/questions/66579/how-do-i-get-the-solarized-colour-scheme-working-with-gnome-terminal-tmux-and-v
# See also
# https://github.com/sigurdga/gnome-terminal-colors-solarized

DARK_BG='#00002B2B3636'
LIGHTEST='#FDFDF6F6E3E3'

gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_background" --type bool false
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/use_theme_colors" --type bool false
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/palette" --type string "#070736364242:#D3D301010202:#858599990000:#B5B589890000:#26268B8BD2D2:#D3D336368282:#2A2AA1A19898:#EEEEE8E8D5D5:$DARK_BG:#CBCB4B4B1616:#58586E6E7575:#65657B7B8383:#838394949696:#6C6C7171C4C4:#9393A1A1A1A1:$LIGHTEST"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/background_color" --type string "$DARK_BG"
gconftool-2 --set "/apps/gnome-terminal/profiles/Default/foreground_color" --type string "#65657B7B8383"
