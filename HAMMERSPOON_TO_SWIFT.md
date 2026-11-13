# Hammerspoon to Swift: the plan

Marko, 20.10.2026: *"convert them to Swift"*, then: *"please lay out the whole plan for transferring to Swift in
the MDS and don't do it now. I will trigger you where to do it."*

**Nothing in this file is started without his word.** Each step below begins only when Marko names it ("convert
MIDI to Key Stroke", "step 3", …). Then: his words go into that repo's `momentaryupdates.md` and are pushed first,
the work follows this plan, and the status line here is updated the same day.

## Where it stands (20.10.2026)

The star has 34 rows. 29 are Swift apps. **5 still need Hammerspoon** (kind "lua" in `rows.json`).

| Row | Status |
|---|---|
| Voices | **done 20.10.2026**: retired; Voice of Claude (Mantra) v5 switches the same engine and has THE PAGE link |
| Sister app (MANTRA CHAT) | **done 20.10.2026**: Sister App (Mantra) v1, repo SISTER_APP |
| MIDI to Key Stroke | waiting, step 1 |
| MIDI to MK Control | waiting, step 2 |
| Ableton Assistant A1 | **done 13.11.2026**: the A1 module of Ableton Live Actions (Mantra) (repo ABLETON_LIVE_ACTIONS, Swift since 13.10.2026); the row is kind app, a1.lua unloaded from Hammerspoon |
| Macro Recorder | waiting, step 4 |
| Buckets | waiting, step 5 |
| Hammerspoon itself | waiting, step 6 (after 1–5) |

Hammerspoon is already out of the login items (18.10.2026) and is not running; nothing starts it by itself.

## The same for every app (MANTRA_MANIFEST swift-apps.md)

- A Swift app named "… (Mantra)" in /Applications, swiftc, signed "Mantra Apps", its own icon drawn in code.
- Its own private repository with README, TAKEOVER, LESSONS, momentaryupdates.md (an existing repo is kept: the
  Swift goes beside the Lua, the Lua is kept until he says it can go).
- The first row is ON / OFF (named after what it switches), ✕ at the far upper right, closing the window leaves it
  on, `--login` starts it without a window. Nothing starts by itself.
- Its settings and its tables are read from the files the Lua version already writes, so nothing he set up is lost.
- The web page it had (a port on 127.0.0.1) is replaced by the Swift window; the port is freed in `ports.md`.
- The star row becomes kind "app" with its path; the Lua file in MANTRA_STAR/apps stays until step 6.
- Checked: built, launched on the **MacBook Pro screen** with `open -g` (never the BenQ: modules/the-benq-is-marko-s.md),
  a window screenshot; then **Marko's test by hand**, asked by voice (marko-tests.md). Not done until he says so.
- Registry (~/Downloads/API), handover, this file: updated in the same turn.

## Step 1: MIDI to Key Stroke (the smallest, ~2,000 lines of Lua)

Repo MIDI_TO_KEYSTROKE (Lua: midikeys.lua 649, midiwatch 194, tablekeep 235, rules 209, volume 100, e16led 354,
page 242). A Swift window for it already exists (MANTRA_CONTROLS, v3), but it only talks to the Lua over :8853.

What the Swift app does itself:
1. **CoreMIDI**: list the sources, DETECT DEVICE (the first CC locks its source by name), UNLOCK, the last message
   heard (port, CC, value, channel, how long ago).
2. **The table**: CC, VALUE (a number or any), KEY, WHAT IT IS (KEY or VOLUME), ON, LEARN, ✗; kept in the same file
   tablekeep.lua writes.
3. **The key capture**: press the cell, the next key anywhere is taken with its modifiers and swallowed (a CGEventTap,
   Esc cancels, 15 s timeout).
4. **Sending**: the key posted to the front application (CGEvent); VOLUME presses the Mac's own volume keys so the
   system's own volume blob shows (as volume.lua does), the silent way behind a tick.
5. **The E16's LEDs** (e16led.lua) sent back over CoreMIDI.
6. ON / OFF stops listening without losing the table.

Needs from Marko: the OXI E16 plugged in, Accessibility and Input Monitoring granted to the new app (his clicks).
Then the MANTRA_CONTROLS window for it is retired.

## Step 2: MIDI to MK Control (~2,500 lines)

Repo MANTRA_MACKIE (mackie.lua 973, mcu.lua 478, rules 348, page 330, blob 214, live 145). A Swift window exists in
MANTRA_CONTROLS (talks to :8855).

What the Swift app does itself:
1. **CoreMIDI in and out**: the E16 in; a virtual output port Live sees as the Mackie Control surface (or the IAC bus
   it uses now; whichever the TAKEOVER says Live is set to).
2. **The translation** (mcu.lua): button = note on ch 1 (127 press, 0 release), jog = CC 60 relative, V-Pots CC
   16–23, faders = 14-bit pitch bend; PLAY / STOP as one button with the insert point as the master; INVERT on
   relative rows, jog born inverted.
3. **The rules table** (rules.lua) and its file, as now.
4. **The blob** (blob.lua): drawn as a small borderless Swift window.
5. **Live's state** (live.lua): what it reads from Live, over the same route.
6. The Mac volume shared with step 1 (one Swift file, used by both).

Needs from Marko: Live open with the Mackie surface set, the E16, and a knob turned at each check (one action per
message: one-task-at-a-time).

## Step 3: Ableton Assistant A1 (~4,600 lines of Lua + Python)

MANTRA_STAR: apps/a1.lua 3,225, a1_blob 206, a1_e16blob 275, a1_osc 182, a1_pick; Python a1_ears.py 167 and
a1_transients.py 493. The biggest and the most used; done in four parts, each tried by him before the next.

- **3a The filter**: a CGEventTap active only while Live is in front: Space continues and the insert point follows,
  Shift+Space the jump back, 1 / 2 zoom, Shift+1 / 2 track height, h split, 7 8 9 markers, ↓ ↑ transients,
  ⌘↓ ⌘↑ track selection, ⌥↓ ⌥↑ moves the track (the header drag through AX, the one mouse move), F2 F3 F4 views,
  ⌘F browser, I O L the loop; every override with its tick; typing in a field passes through. Live's menu items
  pressed through Accessibility (AXUIElement), as now.
- **3b The memory and the ears**: AbletonOSC over UDP straight from Swift (Network.framework, port 11001; a1_ears.py
  retires); the insert point written to "<set>.txt" beside the .als every time it moves, put back when Live starts,
  the newest recent set opened (a1_pick).
- **3c The blob and the markers**: the half-transparent clock at the bottom middle of Live's screen (font, size,
  unit, visible, dragged where he wants), the E16 blob, the markers row with two ticks = Live's loop.
- **3d The window**: what was the page at :8849: every override with its tick, ADD A MAPPING from Live's own menu (the
  265 commands, searchable), the transient sensitivity (EVERY HIT / NORMAL / STRONG). a1_transients.py stays Python
  (numpy, ffmpeg) and is called as a helper, as today; its tests keep running.

Settings stay in ~/.config/ableton-assistant-a1.json. Needs from Marko: Live and a set, Accessibility for the new app,
his hands on Space, the markers and I / O / L (one key per message).

## Step 4: Macro Recorder (~4,900 lines)

Repo MANTRA_MACRO (macro.lua 1,579, script.lua 1,777, settings_page 905, editor_page 452, slots 146).

1. **Recording**: a CGEventTap for mouse and keys, written down as an AutoHotkey v2 script
   (~/.mantra_macro/macros/<name>.ahk), the same format, so every macro he has keeps working.
2. **The script language** (script.lua): Click, Send, Sleep, loops, ifs, variables, ImageSearch (the button found on
   screen from a picture: ScreenCaptureKit + a template match in Swift / Vision).
3. **The keys**: ⌃⌥⌘R record, ⌃⌥⌘P play, ⌃⌥⌘. stop, ⌃⌥⌘N new, ⌃⌥⌘M settings, ⌥1..0 load a slot, ⌃1..0 run it; all
   changeable, never a key bound twice.
4. **The red and green**: REC and PLAY dots bottom right; the star's colour (now the Swift star) red while recording,
   green while playing.
5. **The editor** (was editor_page): a script editor with the next-command suggestions and docs/SCRIPT.md.

Needs from Marko: Accessibility, Input Monitoring and Screen Recording for the new app; one of his own macros played
back while he watches.

## Step 5: Buckets (~330 KB of Lua in BRAIN_BRAKE_KEYBOARD)

The repo is on GitHub (last push 6.9.2026); **its boot file is not on this Mac** (the star looks for
~/Developer/brain_break/tools/keyboard/keyboard_boot.lua), so the row cannot start even today. First: clone it once
(small, SIM data rule), read it, and ask Marko **which parts he still uses** before converting anything. The parts:
paste_queue (the clipboard dispenser: imgtoimg, Suno lyrics / style / exclude), web_menu, hand (the extended hand on
imgtoimg.ai), deck (SCREENSHOT TEST PLAY STOP), mouse_to_button, trackball, type_words, shortcuts, the F keys
(f3_click, f4_use_url, f6_save), holdkeys, voice, toast. What he no longer uses is not converted.

## Step 6: Hammerspoon retired (after 1–5)

1. No row of kind "lua" left in rows.json; STAR_SWIFT drops the Lua code paths (hs, STAR.command, "Hammerspoon is
   off", the 20 s Lua restore) and the word Hammerspoon from its menu.
2. Star Monitor, Star Menu (STAR_LAUNCHER: "Start the star menu" opens Hammerspoon today), Installation Logger,
   G815 Lights, MANTRA_CONTROLS: every call to `hs` and every Hammerspoon check taken out.
3. MANTRA_STAR (the Lua star) archived: README says retired, the date, where each app went.
4. ~/.hammerspoon/init.lua left empty, Hammerspoon quit. Removing the Hammerspoon app itself is his decision.
5. MANTRA_MANIFEST: hammerspoon-app.md marked retired; swift-apps.md says the star has no Lua rows.

## The order, and why

1 and 2 first: smallest, and both already have a Swift window to build on. 3 is the most used and the biggest, so it
goes in four tried parts. 4 is large but self-contained. 5 waits for his list of what is still used. 6 only when
nothing needs Hammerspoon.
