# TAKEOVER: Star (Mantra)

**State, 31.10.2026: v10.** Fixed places in the menu bar (app/MenuBar.swift). Relaunched: old pid 81209, new pid 81409
(v10's first relaunch: 45468 → 80076). Measured: Clock, Control Centre, the star, SoundSource, on both screens.
**Marko to try:** Menu bar order… in the star; drag, SAVE ORDER, REORDER. **Can be ordered:** Hot, Tailscale,
BetterDisplay, AutoRaise, Speechify, Network Aggregate Connection Keeper, iStat Menus, DaVinci Resolve Actions, Claude,
Mantra Code Filler (relaunched when out of place); SoundSource, Hammerspoon, Little Snitch (value written, counts from
their next start). **Cannot:** Clock, Control Centre, Battery (macOS). Without Screen Recording the star cannot read the
icons' names; it uses the app's one stored key, a known name (SoundSource, Hammerspoon, iStat), or assumes Item-0.

**State, 31.10.2026: v9.** The menu never waits on Hammerspoon: the Lua rows' state is a cache refreshed off the main
thread at launch and every 12 s (written to $TMPDIR/star-swift-lua-states.json, which `--print-menu` reads too);
menuNeedsUpdate calls no `hs`. All off's `STAR.remember()` moved off the main thread. `--print-menu`: 0.08-0.11 s.
Relaunched: old pid 43816, new pid 45468. STAR.list()'s hang of 07:45 did not come back (0 s alone and four at once,
3.6 KB); cause not found, MANTRA_STAR not touched.

**State, 31.10.2026: v8.** RUNNING under Swift Matrix, last picked first (`pickedOrder`); `--print-menu` / `--picked`;
`hs()` has a hard deadline. Relaunched 31.10.2026: old pid 631, new pid 43816. Tested with --print-menu only (11 running
rows = the 11 running bundle ids). **Marko to check:** open the star, RUNNING is under Swift Matrix; open an app from
it, reopen the menu, that app is first. 
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
- v11 (31.10.2026): app/TopRow.swift, ON OFF … TOP ✕ in AppKit in MENU BAR ORDER's title bar; ids `off` (quits the star only), `top` (UserDefaults `onTop`), `close`; `Star --menubar-shot <png> --min` draws it at 420 × 320 and prints the identifiers.

## 31.10.2026, v12
rows.json `"exclusive": ["E16"]`: Star.start quits every other running app of an exclusive group first. Group E16: e16resolve (E16 for DaVinci Resolve), oxi (E16 Ableton Remote, app renamed from DJ Mantra Ableton Remote for OXI E16), liveactions (E16 Ableton Live Actions). Row names: "Mantra" only inside parentheses. Relaunch: the star has no OFF the relaunch tool can press: NSRunningApplication.terminate, then open.
- 31.10.2026: the Macro Recorder row ("macro") removed from rows.json and ~/.config/star-rows.json: Marko, "It is not part of the Start menu anymore. It is now released as an independent release" (mantramacrorecorder.pages.dev, its own menu-bar icon from v7).

## 4.11.2026

icons6/: every star app icon is six letters over one background, coloured by category. Change icons.json, run `swift six_icon.swift icons.json out` and `python3 install_icons.py`, then commit each repo. Rule: MANTRA_MANIFEST six-letter-icon.md.
