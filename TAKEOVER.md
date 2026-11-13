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

## 4.11.2026 (v14)
- Buckets row deleted. Companion rows: `with: <bundle id>` opens the app silently when that application opens and stops it
  when it quits; at the star's start a host already running gets its companions. Used by DaVinci Resolve Actions.
- Hammerspoon: stopped and restarted the same morning; it stays at login (Marko). The Lua rows (A1, MIDI ×2) keep working.


## From the former README (9.11.2026)

# Star (Mantra)

**The sign** (Marko, 13.10.2026): *"the logo is David Star or Yogic Star Shiva Shakti Balance Sri Aurobindo Ananda Marko Yoga"*. Two equal triangles interlaced, one up, one down: the six-pointed star, in soft white in the menu bar. Never a five-pointed star.

**The star menu as a Swift app: a launcher, and nothing else.** Marko, 13.10.2026: *"We are quitting the Lua, no
more Lua, only Swift ... we just use this start menu as a launcher. This launcher can also be a Swift application."*

`/Applications/Star (Mantra).app`, a David star in the menu bar (soft white, two equilateral triangles, as the Lua
star drew it). Under it, every app of the Mac's star, one row each, numbered in his order, in the same folders; a folder holding one app shows that app directly (v6, 22.10.2026).
**v5 (19.10.2026): a click opens the app's window and closes the menu; it never quits the app.** Running, the
click brings its window back. ON / OFF is the first row of every app's own window (OFF quits it); the tick only shows
what runs. The Lua rows (Hammerspoon) still toggle on a click.

**v8 (31.10.2026): RUNNING under Swift Matrix.** Swift Matrix is the first row; under it a line RUNNING (with the count,
or "none running") and every one of the star's rows that runs now, folders included, with its own number and the same
click. The app last opened from the star comes first (UserDefaults `pickedOrder`, newest first, like Stream Deck
Control); then the rest of the menu as before. Test without opening it: `"/Applications/Star (Mantra).app/Contents/MacOS/Star" --print-menu`
(`[R]` marks a RUNNING row; `--picked <key>` records a pick first, nothing opens).
**v9:** the menu never waits on Hammerspoon; the Lua rows show their state from a cache refreshed every 12 s in the background.

**v10 (31.10.2026): fixed places in the menu bar.** Right to left: Clock, Control Centre, the star, SoundSource. The star
writes its own "NSStatusItem Preferred Position star" (10, the lowest) at every launch, before its icon exists. The row
**Menu bar order…** opens a window with every icon in the bar: drag into your order, SAVE ORDER, then REORDER writes
each app's value and quits and reopens only the ones out of place (never SoundSource, Little Snitch or Hammerspoon,
whose place counts from their next start). New icons go to the left end. `Star --print-menubar` prints the bar;
`Star --menubar-shot <png>` draws the window off screen. Code: `app/MenuBar.swift`.

## Linux (linux/, from 5.11.2026): the star in the VM's status bar

Marko, 5.11.2026: *"make a Star Menu. We're going to slowly transfer Star Menu applications here. The first one is Macro
Recorder."* and *"Star control apps should be one more addition to our status monitor at the bottom ... It starts with
this: David Star through triangles ... I click, and it opens up from the bottom up."*

- The David star is the **first item of the VM status bar** (vm-chromium, `statusbar/chromium-vm-statusbar.py`). A click
  pops up `build_menu()` from `linux/star.py`, upwards: RUNNING, then the folders, then Quit for what runs.
- Rows: `linux/rows.linux.json` (installed by `linux/install.sh` as `~/.config/star-rows.linux.json`); kind `"service"` = a
  systemd user unit the star starts and stops, `"show"` brings its window. **Moving an app from the Mac star = one row
  here** plus its Linux build. First row: Macro Recorder (MANTRA_MACRO/linux).
- `python3 linux/star.py --print-menu` prints the menu without a screen.

## How it works

- **The rows are a table, not code:** `rows.json` (installed by `build.sh` as `~/.config/star-rows.json`). Each row
  has a key, a name, a folder and a kind:
  - `"app"`: a Swift .app. The star opens and quits it itself; the tick is whether its bundle id runs.
  - `"lua"`: an app still living in Hammerspoon (MANTRA_STAR). The star asks Hammerspoon
    (`hs -c "STAR.toggleKey('key')"`); the tick comes from `STAR.list()`.
  **Converting an app to Swift changes its row only**: `"kind": "app"`, `"app": "/Applications/<Name> (Mantra).app"`.
- **The same files as the Lua star:** his order (`~/.config/star-order.json`), the folders switch and moves
  (`star-groups.json`), what comes back (`star-running.json`) and the running time (`star-time.json`).
  **One writer at a time:** while Hammerspoon runs, the Lua star writes the last two (it sees every app); this app
  only asks it to remember after a direct open or quit. When Hammerspoon is gone, this app writes them once a
  minute and restores the remembered Swift apps at its own launch, half a second apart.
- **Rows:** Launcher (the ⌥Space box), Star Monitor, the folders, All off, folders or one list, Go to the folder,
  the version (`v1`, opens this repository), Quit everything (with Hammerspoon up: the Lua star's own quitAll writes
  the desk and quits Hammerspoon, then this star quits; without it: the desk is written, the Swift apps quit).
- A Lua row is grey with "(Hammerspoon is off)" when Hammerspoon is not running.

## Build

    ./build.sh          # swiftc, signed "Mantra Apps", installed in /Applications, rows to ~/.config
    swift icon/make_icon.swift icon && iconutil -c icns icon/AppIcon.iconset -o icon/AppIcon.icns   # the icon

## Asked from outside, without the mouse

    swiftc -O -o build/ask tools/ask.swift
    build/ask open | close | toggle <key>

Distributed notifications `community.auroville.star.open|close|toggle` (object: the key). A toggle goes through
the same code as a click. The menu opens on the display whose menu bar holds the star (here: the MacBook's own).

## Hammerspoon to Swift

The plan for the last Lua rows and for retiring Hammerspoon: [HAMMERSPOON_TO_SWIFT.md](HAMMERSPOON_TO_SWIFT.md)
(20.10.2026). Each step starts only at Marko's word.

**v12 (31.10.2026): an exclusive E16 group.** Marko: *"make an E16 category in the Start menu. Inside it will be all the apps that use E16, and only one can be selected at a time."* rows.json: E16 for DaVinci Resolve and DJ Mantra Ableton Remote for OXI E16 in group "E16"; `"exclusive": ["E16"]`: opening an app of an exclusive group from the star first quits every other running app of that group (Star.start).

## 13.11.2026: the a1 row is an app
rows.json `a1` (and ~/.config/star-rows.json): kind "app", /Applications/Ableton Live Actions (Mantra).app, bundle community.auroville.abletonliveactions (the A1 module of that app; the row `liveactions` opens the same app, so both ticks agree). MANTRA_STAR star.lua skips apps/a1.lua at the next load (LUA_ROWS). Rows left on "lua": mackie, midikeys.

## State at close, 13.11.2026

13.11.2026: rows: Ableton Live Actions (Mantra) as app (A1), Screen Copy (Mantra) added, MIDI to MK Control and MIDI to Key Stroke removed (MIDI Tools (Mantra) opens both), VM Machine Remote Viewer renamed Mantra Remote Viewing; every paid call asks the Cost Agent gate. icons6/out/sheet.png was modified by another process and is not committed here.
