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
— **Status:** written 20.10.2026. Nothing converted beyond Voices and Sister; each step waits for his word.

## 20.10.2026: the Elevate Media folder
Marko, through the Elevate Media V3 cloud session: "add a NEW ENTRY in his start menu ... called "Elevate Media". Inside it go the apps for working with Elevate Media; the first one is "Elevate Media Monitor"". Done: folder "Elevate Media" after Resolve in rows.json, row emmonitor.

## 21.10.2026: Freedom under Mac

Marko, 21.10.2026: *"Add it to the start menu under Mac"* (Freedom (Mantra), FREE_MAC).

## 22.10.2026: a folder with one app is the app itself

> Please fix my app Devon the Da Vinci Resolve Actions. There is a bug. Alt tick doesn't work to change my pages. Sometimes works, sometimes doesn't. So I'm confused what is that? You need to debug this application so it works. And eat category in the star menu, please change to Da Vinci Resolve Actions. But there is no need for category. If any category has only one entry. Actually, there should be direct access. If there is more than one, then we go to sub-menus. Fix everything.

1. A folder holding one app shows that app directly in the star (Resolve → DaVinci Resolve Actions); two or more stay a submenu. — **Status:** v6 built 22.10.2026; the menu read back: DaVinci Resolve Actions, Elevate Media Monitor, Spectral Analyzer, Yshai Afterman directly; Claude, Ableton Live, DJing, Keyboard and mouse, Mac as submenus. Restarted 680 → 27864.

## 24.10.2026: the Audio Mixing folder

> make a new entry in the Swift Stars menu called Audio Mixing. Then we can make actions for CQ Mix Pad. There will be two applications there: CQ Mixpad Tutorial and CQ Mixpad Actions.

**Status:** folder "Audio Mixing" (after Ableton Live) with CQ MixPad Tutorial (key cqtutorial); rows.json copied to ~/.config/star-rows.json (read at every menu open). CQ MixPad Actions comes when it exists.

## 25.10.2026: the Audio Production folder

> in the star menu, please make a folder called "Audio Production" and put inside: - CQ Tutorial - Audio Monitor They belong to the same category, please

**Status:** folders "Audio Mixing" and "Audio Tools" become one, "Audio Production" (where Audio Mixing was, after Ableton Live): CQ MixPad Tutorial and Spectral Analyzer (Mantra), the "Audio Monitor", confirmed by Marko the same day ("audio monitor is a spectral analyzer"). rows.json copied to ~/.config/star-rows.json.

## 26.10.2026: the OXI app in the star

> come on, make my Oxi application part of the Start Menu and put it in the Application folder. When I type "Oxi" to search, beside the original app, this one must come up

**Status:** done, 26.10.2026. rows.json has the row "oxi" in Ableton Live, after Ableton Live Actions; it is installed in ~/.config/star-rows.json, which the star reads each time its menu opens.

## 28.10.2026: Network Aggregate Connection Keeper in the star

> why don't I see Network Aggregate Application in my Star Menu Matrix, and rename it to Connection Aggregate Keeper so I can easily find it? Also, add Network in the name, so add everything so I can easily find it: Network Aggregate Connection Keeper

**Status:** done, 28.10.2026. rows.json has the row "netaggregate" in Mac, after Download Monitor, opening
/Applications/Network Aggregate Connection Keeper (Mantra).app (connection-keeper v20, renamed); installed in
~/.config/star-rows.json, which the star and Swift Matrix read.

## 28.10.2026: a DaVinci Resolve folder with the actions and the tutorial

> Please in the start menu make a category "DaVinci Resolve," add its DaVinci actions, and also add this tutorial.

**Status:** done, 28.10.2026. The folder Resolve is now "DaVinci Resolve" and holds two rows: DaVinci Resolve Actions
and DaVinci Grading Tutorial (/Applications/DaVinci Grading Tutorial (Mantra).app). Installed in ~/.config/star-rows.json,
which the star reads at every opening of its menu.

## 31.10.2026: Mantra Sound Recorder in Audio Production

> Please put this up under star menu in the category called audio production. Please, so I can run it from there.

**Status:** done, 31.10.2026. rows.json has the row "soundrecorder" in Audio Production, after Spectral Analyzer, opening
/Applications/Mantra Sound Recorder (Mantra).app; installed in ~/.config/star-rows.json, which the star reads at every
opening of its menu (menuNeedsUpdate → star.load()).

## 31.10.2026: RUNNING under Swift Matrix

> Then please enhance my star menu. All running application must be in category running under Swift matrix. Swift matrix must be always at the top and then there is a line running and then everything running is listed there.

- Swift Matrix always the first row of the star menu; under it a separator line titled RUNNING; under that every app running now (one row each, a click brings it to the front as usual); then the rest of the menu as it is. **Status:** done, 31.10.2026, Star (Mantra) v8: Swift Matrix first, RUNNING with the count (or "none running"), the star's running rows (folders included) with their numbers, rebuilt at every opening; checked with `Star --print-menu` against the running bundle ids (11 of 11). Opening the menu by hand is Marko's.

> And we have the same logic like in my stream deck. If I open that menu, select any of the applications to see them, their user interface of running applications, it automatically jumps to the top.

- RUNNING ordered like the Stream Deck: the app last opened from the menu jumps to the top of RUNNING (most recent first). **Status:** done, 31.10.2026, v8: UserDefaults `pickedOrder` (app paths, newest first, as Stream Deck Control's `pressedOrder`); never-picked apps after, in the star's order. Checked with `Star --picked g815 --print-menu`, then darken, then g815 again: each jumped to the top; the test picks deleted afterwards.

## 31.10.2026: every Swift app in the star; fixed places in the menu bar

> Please write in the manifest that any Swift application we are writing is actually going to start. Every Swift application starts, and it comes to the Star menu automatically. That's the thing.
>
> Second thing: when you start, always make sure the Star menu is at the same position in my menu bar. I have date and time. I have something to connect to my Wi-Fi and Bluetooth. Then there is Star, and after Star I have sound source. This is the fixed positioning on my menu bar.
>
> Please add this Star in the Swift application so that I can have all the icons opening on my bar and arrange them in some fixed orientation, and then the menu bar follows that. Now, when new buttons are added, they're going all over the place. I want to get used to my positioning of every software opening in my menu bar being at the same position always.

- Manifest rule: every Swift app we write is started when built and gets its row in the star automatically. **Status:** done, 31.10.2026: MANTRA_MANIFEST swift-apps.md "Every Swift app starts when it is built, and is in the star the same turn" (also: a fixed autosaveName for every menu-bar icon); star-menu.md has the v8-v10 section.
- The star's own icon always in the same place: (right to left) date/time, Control Centre (Wi-Fi/Bluetooth), the star, then SoundSource. **Status:** done, 31.10.2026, Star (Mantra) v10: the star writes "NSStatusItem Preferred Position star" = 10 at every launch before its icon exists (autosaveName `star`). Measured after relaunch: Clock, Control Centre, the star, SoundSource, on both screens (before, the MacBook's notch hid it). SoundSource untouched (its own value 20 already puts it just left of the star; pid 632 never restarted).
- In the star: a fixed order for all menu-bar icons he arranges once; new icons follow it. **Status:** built, 31.10.2026, v10: the star's menu row "Menu bar order…" opens a window listing every icon in the bar, right to left; drag into order, SAVE ORDER, REORDER (writes each app's value and quits/reopens only the apps out of place, never SoundSource, Little Snitch or Hammerspoon). A new icon goes to the left end. Checked: `--print-menubar` and the window drawn off screen (`--menubar-shot`); the drag and REORDER are Marko's to try.

## 31.10.2026: ON, OFF and TOP in every application

> Please go to all the interface of my applications. Each needs to have the same user interface elements. On, off and top. Please build it in every application.

(MANTRA_MANIFEST modules/swift-apps.md, "The first row of every app: ON OFF … TOP ✕"; reference MANTRA_SOUND_RECORDER `TopRow`.) **Status:** done 31.10.2026, v11: the star has one window of its own, MENU BAR ORDER (app/MenuBar.swift); it gets the first row ON OFF … Star · menu bar order … TOP ✕ in its title bar beside the traffic lights (new app/TopRow.swift, AppKit, as MANTRA_SOUND_RECORDER; the window gets .fullSizeContentView and a hidden title). Every word a real NSButton: OFF `off` quits the star alone (the apps it opened stay), TOP `top` floats that window (UserDefaults `onTop`, applied when it opens), ✕ `close` closes it only. No new window; the menu and its rows are unchanged, so the star still only opens. "Quit everything" stays in the menu: it is not a QUIT twin of OFF (it stops every app and Hammerspoon too). Checked: `--menubar-shot <png> --min` at 420 × 320 (the row whole, nothing overlapping; ids off top permissions close, PERMISSIONS hidden), `--print-menu` reads back. Relaunched: old pid 81409 quit through its own Apple Event quit, new pid 8877 (open -g); every remembered app was already running, so the restore opened nothing. Then the star opened Freedom through its toggle (pid 9977) and closed it again.

## 31.10.2026

> Let's sort out the E16 setup, with different applications driving it. Please make an E16 category in the Start menu.
> Inside it will be all the apps that use E16, and only one can be selected at a time.

- An E16 group: E16 for DaVinci Resolve + DJ Mantra Ableton Remote for OXI E16; exclusive (opening one quits the other). **Status:** done v12 (rows.json group E16, "exclusive": ["E16"]); Ableton Live Actions stays in Ableton Live (its MIDI to key stroke volume rule is the only E16 clash)

> I think all the MIDI applications need to be put in E16. There are only 2, or maybe more, and still my volume is occupied for the first knob.
> Pressing doesn't send space, because I guess another application is using this pressing. It's not working.
> You need to stop all MIDI applications and just use this one.

- Every app that reads MIDI goes into the exclusive E16 group (Ableton Live Actions too); the others stopped now, only E16 for DaVinci Resolve runs. **Status:** done: Live Actions quit and moved to E16 (rows.json); press did not play because E16 for DaVinci Resolve has no Accessibility (log: "accessibility OFF"): Marko switches it on
