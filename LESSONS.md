# LESSONS: Star (Mantra)

1. **`hs -c` hangs past 16 KB of output** (13.10.2026). `hs -c 'return STAR.list()'` (17.6 KB) wrote exactly
   16384 bytes and never ended. Big answers come back through a file the Lua side writes; only "ok" goes
   through the pipe (`hsStates()`).
2. **`performClick` on a status-bar button opens the menu once, then never again** when asked from outside.
   `menu.popUp(positioning:at:in: button)` opens it every time.
3. **Two displays: `screencapture -x a.png` is the main display only.** The star's menu opened on the MacBook's
   own screen and the first screenshots showed nothing. `screencapture -x d1.png d2.png` takes both.
4. **A menu stays open after a click inside an item's own view.** Every app row is a `RowView` that toggles on
   mouseUp and redraws its tick; the Lua star had to reopen the whole menu after each tick.
5. **One writer for star-running.json and star-time.json.** While the Lua star runs, it already counts every
   app (the Swift ones through their wrappers); a second writer would count each minute twice.
