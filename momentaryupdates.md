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

## 18.10.2026, 08:40

Marko: "please check the latest screenshot. This is my desktop. Still something is opening automatically, so basically please compare the star menu of Hammerspoon, the star menu of Swift, and if everything works in both, stop running Hammerspoon. Please automatically put it to sleep"

## 19.10.2026: a click opens the app's window; ON / OFF lives at the top of every app, not in the tick
> please fix the behavior of the Swiftstar menu. When I select any of the apps, the user interface opens up. In the top of every user interface, there will now be an on/off switch. Should I activate or deactivate this engine, but the settings are opening up. If I say on, I close it's on very easily. We don't want any more this behavior. When I just switch the check mark, and that's how I activate it. This is gone. Let's work like this. This is the workflow now

Status: the star, v5 19.10.2026: a click on a Swift row opens the app (running: its window comes back) and closes the
menu; it never quits. Restarted (pid 728 → 11634). Then, the same day, ON / OFF and ✕ at the top of all 25 other
Swift apps' windows, each in its own repository (versions in the hub's HANDOVER, 19.10.2026); the Lua rows still toggle.
Marko to try OFF and ✕.

## 20.10.2026: the seven Lua rows become Swift apps; Hammerspoon retired

> (asked: the seven star rows that still need Hammerspoon — take them out of the star, or convert them to Swift?) convert them to Swift. In the meantime, I'm going to check the font

Buckets, Sister app (MANTRA CHAT), Macro Recorder, Voices, Ableton Assistant A1, MIDI to MK Control, MIDI to Key
Stroke: each a Swift app "(Mantra)" with its own repo, icon, ON / OFF row and ✕; its star row kind "app". When none
is left, Hammerspoon is retired. — **Status:** 2 of 7 done 20.10.2026:
   - Voices: retired; Voice of Claude (Mantra) v5 switches the same engine and now has THE PAGE link.
   - Sister app: Sister App (Mantra) v1 (repo SISTER_APP), row kind "app".
   - Left, by size of the Lua engine: MIDI to Key Stroke (~2,000 lines, a Swift window already in MANTRA_CONTROLS),
     MIDI to MK Control (~2,500, same), Ableton Assistant A1 (~4,600 + Python), Macro Recorder (~4,900), Buckets
     (~330 KB in BRAIN_BRAKE_KEYBOARD; its boot file is not on this Mac, so the row cannot start today).

## 20.10.2026: the plan in Markdown, no conversion now

> please lay out the whole plan for transferring to Swift in the MDS and don't do it now. I will trigger you where to do it. That's it

The plan goes in STAR_SWIFT/HAMMERSPOON_TO_SWIFT.md, one section per app, each one started only when Marko says so.
— **Status:** in progress
