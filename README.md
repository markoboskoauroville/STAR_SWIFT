# Star (Mantra)

**The sign** (Marko, 13.10.2026): *"the logo is David Star or Yogic Star Shiva Shakti Balance Sri Aurobindo Ananda Marko Yoga"*. Two equal triangles interlaced, one up, one down: the six-pointed star, in soft white in the menu bar. Never a five-pointed star.

**The star menu as a Swift app: a launcher, and nothing else.** Marko, 13.10.2026: *"We are quitting the Lua, no
more Lua, only Swift ... we just use this start menu as a launcher. This launcher can also be a Swift application."*

`/Applications/Star (Mantra).app`, a David star in the menu bar (soft white, two equilateral triangles, as the Lua
star drew it). Under it, every app of the Mac's star, one row each, numbered in his order, in the same folders.
**A click opens or closes the app and the menu stays open**, so he can switch several in a row; the tick is the
app's real running state.

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
