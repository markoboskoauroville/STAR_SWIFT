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

- (14.10.2026) **The memory file lost apps three ways**: a key not among the rows the process had loaded was dropped
  (a row added while it ran); an app being restored was written off at the first minute; at log out the apps quit
  before the star and were written off. v4: read rows fresh, keep unknown keys, keep pending, freeze on
  `NSWorkspace.willPowerOffNotification`.
- (14.10.2026) **Bring apps back hidden**: `OpenConfiguration.activates = false, hides = true`. A SwiftUI WindowGroup
  app otherwise opens its window at every login.
