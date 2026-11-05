#!/bin/sh
# install.sh (Linux star): the star's rows, and the systemd user units of the apps it starts. The star itself is drawn
# by the VM status bar (vm-chromium), which reads star.py from this folder.
set -e
cd "$(dirname "$0")"
U="$HOME/.config/systemd/user"; mkdir -p "$U" "$HOME/.config"
cp rows.linux.json "$HOME/.config/star-rows.linux.json"
# Macro Recorder: quitting it from the star must stay quit, so it restarts only after a crash
cat > "$U/mantra-macro.service" <<UNIT
[Unit]
Description=Macro Recorder (Mantra) for Linux
[Service]
Environment=DISPLAY=:1
ExecStart=/usr/bin/python3 %h/.local/share/mantra_macro/mantra_macro.pyz --hidden
Restart=on-failure
RestartSec=3
[Install]
WantedBy=default.target
UNIT
systemctl --user daemon-reload
systemctl --user enable mantra-macro.service >/dev/null 2>&1
# the star had its own corner window in its first hour; it lives in the status bar now
systemctl --user disable --now mantra-star.service >/dev/null 2>&1 || true
rm -f "$U/mantra-star.service"; systemctl --user daemon-reload
echo "star rows installed: $HOME/.config/star-rows.linux.json"
