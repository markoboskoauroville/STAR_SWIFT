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
