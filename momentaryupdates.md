# Momentary updates: Marko's requests, word for word, saved before any code

## 14.10.2026 — startup housekeeping lost in the move from Lua to Swift; the Swift Matrix

> Also work on my transition for star menu from Swift. From Lua to Swift, actually. When the computer is starting my Specify is not killed and other startup. Functions from Lua which were doing. Um Housekeeping when the computer starts are not working. Seems like there is no keeping of the same Of the same. Behavior. And you need to develop one more Swift in the star menu, which is the which will be the first one. We call it a Swift matrix. In the Swift matrix, I can just see the list, it's like a task manager of all Applications which are auto-starting and open right now. And I can from this one point I can close them or make them start with the computer. So it's like kind of dashboard which is very simple. It can display everything that's running from my star, and I can close it remotely from here or put it to auto-run. Sometimes or what's happening now the the there are some random apps are opening every time I'm starting Starting my computer and I need to manually click on each window and close it, which is very annoying. It should not do something like this. It should listen and behave and be silent.

("Specify" = Speechify.)

1. Startup housekeeping: everything the Lua star did at login (Speechify killed, splash windows closed, the other
   jobs) done again, now from Swift, silently. — **Status:** done 14.10.2026, Star v4 (see below)
2. Find why random apps open at login (login items, LaunchAgents, reopen-windows) and list them. — **Status:** listed 14.10.2026 (below); nothing removed, the Swift Matrix is his switch
3. **Swift Matrix (Mantra)**, the first row of the star: a simple task manager of every app running now and everything
   that starts with the Mac; from it, close any of them or switch its auto-start; mark what comes from the star.
   Silent: it opens only when chosen. Own repo SWIFT_MATRIX. — **Status:** built, v2, the star's first row

### What was found (14.10.2026)

- The Lua star did one thing at login: bring back what was open (star-running.json); the Speechify splash closer and
  A1 were among them, so Speechify's Home window was closed at every start. In the move to Swift two keys fell out of
  the file: `speechify` (the Swift closer was not running when the Swift star first wrote the file) and `liveactions`
  (added to the rows while the old star process ran; it dropped keys it did not know). So at login 14.10 nothing closed
  Speechify's window and Ableton Live Actions (A1) did not come back. Both put back.
- The Swift star opened the apps it brought back in front, each with its window (Automated Mouse Actions, Dock
  Switcher, Claude to Marko Voice): the "windows I click to close".
- Star v4: restore opens hidden and in the background (`--login`); keys it does not know are kept; an app being
  restored stays wanted until seen or closed; nothing is written once the Mac powers off (macOS quits the apps first);
  `~/.config/star-autostart.json` (ALWAYS / NEVER, from Swift Matrix) on top of what was open; Swift Matrix the first row.
