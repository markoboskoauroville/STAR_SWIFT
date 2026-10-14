# TAKEOVER: Star (Mantra)

**State, 14.10.2026: v4.** Silent login (apps brought back hidden, `--login`), the memory no longer loses apps (unknown
keys kept, pending restores kept, frozen at power-off), `~/.config/star-autostart.json` from Swift Matrix (ALWAYS /
NEVER), and Swift Matrix (Mantra) as the first row. Restarted 14.10.2026: old pid 715, new pid 23351; Ableton Live
Actions came back hidden. **Marko to check after his next restart:** no window pops up from the star's apps, Speechify's
Home window is closed within seconds, Ableton Live Actions and the splash closer are running.


**State, 13.10.2026: v1 built, installed, running beside the Lua star.** Hammerspoon is untouched, no .lua deleted,
no login item changed. Marko decides when the Swift star replaces the Lua one.

Verified 13.10.2026: the menu opens (folders, and one list with all 27 rows and their ticks agreeing with the Lua
star); `build/ask toggle spectral` opened Spectral Analyzer and closed it again, the Lua star agreed each time
(`STAR.isOnKey`). Not yet verified: a Lua row toggled from here (same `STAR.toggleKey` the Star Launcher uses), Quit
everything, the restore with Hammerspoon gone.

## Next

1. Marko tries it: click rows, see the menu stay open.
2. Convert the Lua apps one by one (the order is in MANTRA_STAR momentaryupdates.md, 13.10.2026); each conversion
   = a Swift app in /Applications "(Mantra)" + its row's kind here.
3. Not in v1: the per-app settings submenus of running Lua apps (`app.menu`), the star's colour (red while a macro
   records, green while it plays: `STAR.tint`), Reorder (the Star Monitor page reorders), Reload Hammerspoon.
   Each comes when its app is Swift: a Swift app shows its own settings.
4. When the last row is `"app"`: login item for this app, Hammerspoon quits for good.
