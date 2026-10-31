// Star (Mantra): the star menu as a Swift app, a launcher and nothing else.
//
// Marko, 13.10.2026: "We are quitting the Lua, no more Lua, only Swift ... We don't use Lua, we just use
// this start menu as a launcher. This launcher can also be a Swift application."
//
// It owns no engine. Each row is an app: kind "app" is a Swift .app the star opens and quits itself; kind
// "lua" is an app still living in Hammerspoon, toggled through `hs` (STAR.toggleKey) until it is
// converted. The rows are ~/.config/star-rows.json (rows.json in the repo), so converting an app changes
// one row and no code.
//
// THE FILES ARE SHARED, EACH STAR WRITES ITS OWN KEYS (v2, 13.10.2026: "make a replacement for Luastar with
// Swiftstar"). This app is the only star in the menu bar and starts at login (LaunchAgent community.auroville.star).
// star-running.json (what comes back) and star-time.json (how long each runs) keep the Lua star's formats: this app
// writes and restores its kind-"app" rows, keeping the other keys as they are; Hammerspoon, headless now, hosts the
// kind-"lua" rows that are not converted yet and merges only their keys (MANTRA_STAR star.lua).

import AppKit

// v11 (31.10.2026, Marko: "Each needs to have the same user interface elements. On, off and top. Please build it in
// every application"): the star's one window, MENU BAR ORDER, gets the first row ON OFF … Star … TOP ✕ (TopRow.swift).
// The star itself still only opens: OFF quits the star alone, the rows' clicks are unchanged.
let VERSION = 12
let HOME = NSHomeDirectory()
let CONF = HOME + "/.config"
let ROWS_FILE = CONF + "/star-rows.json"
let ORDER_FILE = CONF + "/star-order.json"
let RUNNING_FILE = CONF + "/star-running.json"
let TIME_FILE = CONF + "/star-time.json"
let GROUPS_FILE = CONF + "/star-groups.json"
// v4 (14.10.2026): what Swift Matrix (Mantra) decides for the next login: ALWAYS starts whatever was open, NEVER stays away
let AUTOSTART_FILE = CONF + "/star-autostart.json"
let MATRIX_APP = "/Applications/Swift Matrix (Mantra).app"
let HS = "/opt/homebrew/bin/hs"
let HS_BUNDLE = "org.hammerspoon.Hammerspoon"
let REPO_URL = "https://github.com/markoboskoauroville/STAR_SWIFT"

struct Row: Codable {
    var key: String
    var name: String
    var group: String?
    var kind: String          // "app" | "lua"
    var app: String?          // the .app's path, for kind "app"
    var url: String?
    var about: String?
    var path: String? { app.map { NSString(string: $0).expandingTildeInPath } }
}
// v12 (Marko, 31.10.2026: "make an E16 category ... Inside it will be all the apps that use E16, and only one can be
// selected at a time"): `exclusive` names groups whose apps never run together; opening one quits the others first
struct RowsFile: Codable { var folders: [String]?; var rows: [Row]; var exclusive: [String]? }

func readJSON(_ path: String) -> Any? {
    guard let d = FileManager.default.contents(atPath: path) else { return nil }
    return try? JSONSerialization.jsonObject(with: d)
}
func writeJSON(_ obj: Any, _ path: String) {
    try? FileManager.default.createDirectory(atPath: CONF, withIntermediateDirectories: true)
    if let d = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys]) {
        try? d.write(to: URL(fileURLWithPath: path), options: .atomic)
    }
}

// MARK: Hammerspoon, while some apps still live there

// `hs -c` stops at 16 KB of output and hangs (measured 13.10.2026 on STAR.list(), 17.6 KB), so anything
// big comes back through a file the Lua side writes, and only "ok" through the pipe.
func hsAlive() -> Bool {
    NSRunningApplication.runningApplications(withBundleIdentifier: HS_BUNDLE).isEmpty == false
}
@discardableResult
func hs(_ lua: String, timeout: Double = 8) -> String? {
    guard hsAlive(), FileManager.default.isExecutableFile(atPath: HS) else { return nil }
    let p = Process()
    p.executableURL = URL(fileURLWithPath: HS)
    p.arguments = ["-t", String(Int(timeout)), "-c", lua]
    let out = Pipe(); p.standardOutput = out; p.standardError = Pipe()
    do { try p.run() } catch { return nil }
    // v8 (31.10.2026): `hs -t` does not always keep its word (STAR.list() hung past 2 minutes with -t 8, measured
    // 31.10.2026): a hard deadline ends it, so the menu never freezes on Hammerspoon
    DispatchQueue.global().asyncAfter(deadline: .now() + timeout + 2) { if p.isRunning { p.terminate() } }
    let data = out.fileHandleForReading.readDataToEndOfFile()
    p.waitUntilExit()
    return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
}
// every Lua app's on/off in one question, through a file
func hsStates() -> [String: Bool]? {
    let tmp = NSTemporaryDirectory() + "star-swift-list.json"
    guard hs("local f=io.open('\(tmp)','w'); f:write(STAR.list()); f:close(); return 'ok'") == "ok",
          let j = readJSON(tmp) as? [String: Any], let apps = j["apps"] as? [[String: Any]] else { return nil }
    var s: [String: Bool] = [:]
    for a in apps { if let k = a["key"] as? String { s[k] = (a["on"] as? Bool) ?? false } }
    return s
}

// MARK: The apps

final class Star {
    var rows: [Row] = []
    var exclusiveGroups = Set<String>()        // v12: groups whose apps never run together (the E16)
    var folders: [String] = []
    var luaOn: [String: Bool] = [:]
    var hsUp = false

    func load() {
        let path = FileManager.default.fileExists(atPath: ROWS_FILE) ? ROWS_FILE
            : (Bundle.main.path(forResource: "rows", ofType: "json") ?? ROWS_FILE)
        if let d = FileManager.default.contents(atPath: path), let f = try? JSONDecoder().decode(RowsFile.self, from: d) {
            rows = f.rows; folders = f.folders ?? []; exclusiveGroups = Set(f.exclusive ?? [])
        }
        // HIS ORDER (star-order.json, the Lua star's file): the keys he placed first, the rest after, in the table's order
        if let o = readJSON(ORDER_FILE) as? [String: Any], let keys = o["order"] as? [String] {
            var rank: [String: Int] = [:]
            for (i, k) in keys.enumerated() where rank[k] == nil { rank[k] = i }
            let base = Dictionary(uniqueKeysWithValues: rows.enumerated().map { ($1.key, $0) })
            rows.sort { (rank[$0.key] ?? 10000 + base[$0.key]!) < (rank[$1.key] ?? 10000 + base[$1.key]!) }
        }
    }
    // v9 (31.10.2026): the menu never waits on Hammerspoon. The Lua rows' state is a cache, refreshed off the main
    // thread at launch and every 12 s (hs with its hard deadline), and written to LUA_CACHE so `--print-menu` reads the
    // same; refresh(), called by menuNeedsUpdate, only reads it. A Lua row never known shows off.
    static let LUA_CACHE = NSTemporaryDirectory() + "star-swift-lua-states.json"
    private var luaBusy = false
    func refresh() {
        hsUp = hsAlive()
        if !hsUp { luaOn = [:] }
    }
    func loadLuaCache() {
        if let c = readJSON(Star.LUA_CACHE) as? [String: Bool] { luaOn = c }
    }
    func refreshLuaInBackground() {
        guard !luaBusy else { return }
        guard hsAlive() else { luaOn = [:]; return }
        luaBusy = true
        DispatchQueue.global(qos: .utility).async {
            let s = hsStates()
            DispatchQueue.main.async {
                self.luaBusy = false
                if let s = s {
                    self.luaOn = s
                    if let d = try? JSONSerialization.data(withJSONObject: s) { try? d.write(to: URL(fileURLWithPath: Star.LUA_CACHE), options: .atomic) }
                }
            }
        }
    }
    func bundleID(_ r: Row) -> String? {
        guard let p = r.path else { return nil }
        return Bundle(url: URL(fileURLWithPath: p))?.bundleIdentifier
    }
    func running(_ r: Row) -> [NSRunningApplication] {
        guard let id = bundleID(r) else { return [] }
        return NSRunningApplication.runningApplications(withBundleIdentifier: id)
    }
    func isOn(_ r: Row) -> Bool {
        r.kind == "app" ? !running(r).isEmpty : (luaOn[r.key] ?? false)
    }
    func usable(_ r: Row) -> Bool {
        r.kind == "app" ? (r.path.map { FileManager.default.fileExists(atPath: $0) } ?? false) : hsUp
    }

    func start(_ r: Row) {
        guard let p = r.path else { return }
        // v12: an exclusive group (the E16): every other app of the group that runs is quit first
        if let g = r.group, exclusiveGroups.contains(g) {
            for o in rows where o.group == g && o.key != r.key && o.kind == "app" && isOn(o) { stop(o) }
        }
        let c = NSWorkspace.OpenConfiguration(); c.activates = true
        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: p), configuration: c) { _, err in
            if let err = err { NSLog("star: %@ did not open: %@", r.key, err.localizedDescription) }
        }
    }
    func stop(_ r: Row) {
        pending.remove(r.key)                     // a real close: it is not wanted back
        let apps = running(r)
        apps.forEach { $0.terminate() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { apps.filter { !$0.isTerminated }.forEach { $0.forceTerminate() } }
    }

    // v5 (19.10.2026). Marko: "When I select any of the apps, the user interface opens up. In the top of every user
    // interface, there will now be an on/off switch ... When I just switch the check mark, and that's how I activate
    // it. This is gone." A click on a Swift row opens the app, or, running, brings its window (the reopen); it never
    // quits it. OFF is the switch at the top of the app's own window. The tick only shows what runs.
    func open(_ r: Row) {
        picked(r)
        start(r)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.recorded() }
    }

    // a click: open or close, then the right owner writes it down (v5: only the Lua rows and `ask toggle` still toggle)
    func toggle(_ r: Row, done: @escaping () -> Void) {
        if r.kind == "app" {
            isOn(r) ? stop(r) : start(r)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.recorded(); done() }
        } else {
            picked(r)
            DispatchQueue.global().async {
                _ = hs("return STAR.toggleKey('\(r.key)')", timeout: 20)
                let s = hsStates()
                DispatchQueue.main.async { if let s = s { self.luaOn = s }; done() }
            }
        }
    }
    // v8 (31.10.2026, Marko: "the same logic like in my stream deck ... select any of the applications to see ... their
    // user interface of running applications, it automatically jumps to the top"): RUNNING is ordered by the last pick
    // from the star, newest first. UserDefaults `pickedOrder`: the app paths (a Lua row: "lua:<key>"), newest first, as
    // Stream Deck Control keeps `pressedOrder`. Apps never picked come after, in the star's own order.
    static let PICKED = "pickedOrder"
    func pickID(_ r: Row) -> String { r.path ?? "lua:" + r.key }
    func picked(_ r: Row) {
        var o = UserDefaults.standard.stringArray(forKey: Star.PICKED) ?? []
        o.removeAll { $0 == pickID(r) }
        o.insert(pickID(r), at: 0)
        UserDefaults.standard.set(Array(o.prefix(60)), forKey: Star.PICKED)
    }
    func byPick(_ rs: [Row]) -> [Row] {
        let o = UserDefaults.standard.stringArray(forKey: Star.PICKED) ?? []
        var rank: [String: Int] = [:]
        for (i, id) in o.enumerated() where rank[id] == nil { rank[id] = i }
        return rs.enumerated().sorted { a, b in
            (rank[pickID(a.1)] ?? 1000 + a.0) < (rank[pickID(b.1)] ?? 1000 + b.0)
        }.map { $0.1 }
    }
    func recorded() {
        // v2 (13.10.2026, the Swift star is the only star): its own apps are always its to write; the Lua star merges
        // its Lua keys into the same file and leaves these alone
        remember(); clock()
        if hsAlive() { DispatchQueue.global().async { hs("STAR.remember()") } }
    }

    // MARK: the files, when Hammerspoon is gone

    // what is open stays open: the keys that are on; a Lua app's wish is kept while Hammerspoon cannot run it
    //
    // v4 (14.10.2026, Marko: "the housekeeping when the computer starts is not working"): three ways this lost an app,
    // each closed here.
    //  1. A key this star did not know (a row added to star-rows.json while it ran: Ableton Live Actions on 13.10) was
    //     dropped. Now the rows are read fresh, and a key that is not a row is kept as it is.
    //  2. An app restored at login but not up yet (or that failed to open) was written off at the first minute. Now it
    //     stays wanted (pending) until it is seen running or he closes it (the Lua star's "stuck").
    //  3. At log out, restart or shut down macOS quits the apps before this star; the minute's tick then wrote them all
    //     off. Now nothing is written once the Mac says it is powering off.
    var pending = Set<String>()
    var poweringOff = false
    func remember() {
        if poweringOff { return }
        load()
        let before = (readJSON(RUNNING_FILE) as? [String]) ?? []
        let known = Set(rows.map { $0.key })
        var on: [String] = []
        for r in rows {
            if r.kind == "app" {
                if isOn(r) { pending.remove(r.key); on.append(r.key) } else if pending.contains(r.key) { on.append(r.key) }
            } else if before.contains(r.key) { on.append(r.key) }
        }
        for k in before where !known.contains(k) && !on.contains(k) { on.append(k) }
        writeJSON(on, RUNNING_FILE)
    }
    // Swift Matrix's word on the next login: (what was open + ALWAYS) - NEVER
    func wanted() -> Set<String> {
        let a = (readJSON(AUTOSTART_FILE) as? [String: Any]) ?? [:]
        let always = Set((a["always"] as? [String]) ?? []), never = Set((a["never"] as? [String]) ?? [])
        return Set((readJSON(RUNNING_FILE) as? [String]) ?? []).union(always).subtracting(never)
    }
    // the time an app runs, the Lua star's ledger: { key: { days: { "YYYY-MM-DD": s }, starts, last_start, last_stop } }
    var lastLook = Date().timeIntervalSince1970
    var wasOn: [String: Bool] = [:]
    func clock() {
        var L = (readJSON(TIME_FILE) as? [String: Any]) ?? [:]
        let now = Date().timeIntervalSince1970
        var dt = now - lastLook; lastLook = now
        if dt < 0 || dt > 180 { dt = 0 }             // the Mac slept or the clock jumped
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        let day = f.string(from: Date())
        for r in rows where r.kind == "app" {
            let on = isOn(r)
            var e = (L[r.key] as? [String: Any]) ?? [:]
            var days = (e["days"] as? [String: Any]) ?? [:]
            var starts = (e["starts"] as? Int) ?? 0
            if on { days[day] = ((days[day] as? Double) ?? Double((days[day] as? Int) ?? 0)) + dt }
            if on && !(wasOn[r.key] ?? false) { starts += 1; e["last_start"] = Int(now) }
            if !on && (wasOn[r.key] ?? false) { e["last_stop"] = Int(now) }
            wasOn[r.key] = on
            e["days"] = days; e["starts"] = starts
            L[r.key] = e
        }
        writeJSON(L, TIME_FILE)
    }
    // at launch, with Hammerspoon gone: the remembered Swift apps come back, half a second apart
    // v4: SILENT. Marko, 14.10.2026: "random apps are opening every time I'm starting my computer and I need to manually
    // click on each window and close it ... It should listen and behave and be silent." An app brought back here opens
    // hidden and does not take the front: its engine runs, its window waits until he opens it from the star or the Dock.
    func restore() {
        load()
        let want = wanted()
        let queue = rows.filter { $0.kind == "app" && want.contains($0.key) && !isOn($0) && usable($0) }
        pending = Set(queue.map { $0.key })
        for (i, r) in queue.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 * Double(i)) { self.startSilently(r) }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 * Double(queue.count) + 2) { self.clock() }
        // the Lua rows Swift Matrix switched ALWAYS or NEVER, once Hammerspoon's own restore has run
        let a = (readJSON(AUTOSTART_FILE) as? [String: Any]) ?? [:]
        let always = Set((a["always"] as? [String]) ?? []), never = Set((a["never"] as? [String]) ?? [])
        let lua = rows.filter { $0.kind == "lua" && (always.contains($0.key) || never.contains($0.key)) }
        if !lua.isEmpty {
            DispatchQueue.global().asyncAfter(deadline: .now() + 20) {
                guard let s = hsStates() else { return }
                for r in lua {
                    let on = s[r.key] ?? false
                    if never.contains(r.key) && on { hs("STAR.command('\(r.key)','stop')", timeout: 20) }
                    else if always.contains(r.key) && !on { hs("STAR.command('\(r.key)','start')", timeout: 20) }
                }
            }
        }
    }
    func startSilently(_ r: Row) {
        guard let p = r.path else { return }
        let c = NSWorkspace.OpenConfiguration()
        c.activates = false; c.hides = true; c.addsToRecentItems = false
        c.arguments = ["--login"]
        NSWorkspace.shared.openApplication(at: URL(fileURLWithPath: p), configuration: c) { _, err in
            if let err = err { NSLog("star: %@ did not come back: %@", r.key, err.localizedDescription) }
        }
    }
    func allOff(done: @escaping () -> Void) {
        let on = rows.filter { isOn($0) }
        DispatchQueue.global().async {
            for r in on {
                if r.kind == "app" { DispatchQueue.main.sync { self.stop(r) } }
                else { hs("STAR.command('\(r.key)','stop')", timeout: 20) }
            }
            Thread.sleep(forTimeInterval: 1.5)
            if hsAlive() { hs("STAR.remember()") }
            DispatchQueue.main.async {
                self.remember(); self.clock()
                self.refresh(); self.refreshLuaInBackground(); done()
            }
        }
    }
    // the desk is written down first, then everything stops; tomorrow it comes back
    func quitEverything() {
        // v2: the desk is written first (the Swift apps here, the Lua ones by the Lua star), then everything stops
        remember(); clock()
        poweringOff = true                         // v4: the desk is written; the apps quitting now must not change it
        for r in rows where r.kind == "app" && r.key != "launcher" && isOn(r) { stop(r) }
        if hsAlive() {
            DispatchQueue.global().async {
                hs("STAR.quitAll()", timeout: 30)    // the Lua star writes its own keys, stops its apps, quits Hammerspoon
                DispatchQueue.main.async { NSApp.terminate(nil) }
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { NSApp.terminate(nil) }
        }
    }
    var foldersOn: Bool {
        ((readJSON(GROUPS_FILE) as? [String: Any])?["folders"] as? Bool) ?? true
    }
    func setFolders(_ on: Bool) {
        var g = (readJSON(GROUPS_FILE) as? [String: Any]) ?? [:]
        g["folders"] = on
        writeJSON(g, GROUPS_FILE)
    }
    func group(_ r: Row) -> String {
        if let g = (readJSON(GROUPS_FILE) as? [String: Any])?[r.key] as? String, !g.isEmpty { return g }
        return r.group ?? "Other"
    }
}

// MARK: A row that does not close the menu

// A macOS menu closes on a click, but not on a click inside an item's own view: so every app row is a
// view, the click toggles, and the tick changes in place while the menu stays open (the Lua star had to
// reopen the whole menu to get the same).
final class RowView: NSView {
    let row: Row
    let number: Int
    weak var star: Star?
    var busy = false
    private var hover = false
    init(row: Row, number: Int, star: Star) {
        self.row = row; self.number = number; self.star = star
        super.init(frame: NSRect(x: 0, y: 0, width: 470, height: 22))
        addTrackingArea(NSTrackingArea(rect: .zero, options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect], owner: self))
        toolTip = row.about
    }
    required init?(coder: NSCoder) { fatalError() }
    override func mouseEntered(with e: NSEvent) { hover = true; needsDisplay = true }
    override func mouseExited(with e: NSEvent) { hover = false; needsDisplay = true }
    override func mouseUp(with e: NSEvent) {
        guard let star = star, !busy, star.usable(row) else { NSSound.beep(); return }
        if row.kind == "app" { enclosingMenuItem?.menu?.supermenu?.cancelTracking(); enclosingMenuItem?.menu?.cancelTracking(); star.open(row); return }
        busy = true; needsDisplay = true
        star.toggle(row) { [weak self] in self?.busy = false; self?.needsDisplay = true }
    }
    override func draw(_ dirty: NSRect) {
        guard let star = star else { return }
        let usable = star.usable(row)
        if hover && usable {
            NSColor.selectedContentBackgroundColor.setFill()
            NSBezierPath(roundedRect: bounds.insetBy(dx: 5, dy: 0), xRadius: 4, yRadius: 4).fill()
        }
        let ink: NSColor = !usable ? .disabledControlTextColor : (hover ? .white : .labelColor)
        let font = NSFont.menuFont(ofSize: 0)
        let at: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: ink]
        let tick = busy ? "…" : (star.isOn(row) ? "✓" : "")
        (tick as NSString).draw(at: NSPoint(x: 12, y: 3), withAttributes: at)
        let num = number > 0 ? String(format: "%2d", number) : ""
        (num as NSString).draw(at: NSPoint(x: 30, y: 3), withAttributes: [.font: NSFont.monospacedDigitSystemFont(ofSize: font.pointSize, weight: .regular), .foregroundColor: ink.withAlphaComponent(0.6)])
        var title = row.name
        if row.kind == "lua" { title += star.hsUp ? "" : "   (Hammerspoon is off)" }
        let r = NSRect(x: 56, y: 3, width: bounds.width - 66, height: 17)
        let p = NSMutableParagraphStyle(); p.lineBreakMode = .byTruncatingTail
        (title as NSString).draw(with: r, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                                 attributes: at.merging([.paragraphStyle: p]) { $1 })
    }
}

// MARK: The menu

final class Controller: NSObject, NSMenuDelegate {
    let star = Star()
    // lazy: `--print-menu` builds the menu without a second star in the menu bar
    lazy var item: NSStatusItem = {
        // v10 (31.10.2026, Marko: "I have date and time. I have something to connect to my Wi-Fi and Bluetooth. Then
        // there is Star, and after Star I have sound source. This is the fixed positioning on my menu bar."): the star's
        // place is asserted at every launch, before the item exists, so a drag or a new app never moves it for good
        MenuBarOrder.placeStar()
        let it = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        it.autosaveName = MenuBarOrder.STAR_NAME
        return it
    }()
    let menu = NSMenu()

    func setup() {
        star.load()
        star.loadLuaCache(); star.refreshLuaInBackground()
        let lt = Timer(timeInterval: 12, repeats: true) { _ in self.star.refreshLuaInBackground() }
        RunLoop.main.add(lt, forMode: .common)
        item.button?.image = Controller.starImage()
        item.button?.toolTip = "Star (Mantra) v\(VERSION): every app, a click opens its window; ON / OFF is at the top of the window"
        menu.delegate = self
        menu.autoenablesItems = false
        item.menu = menu
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self.star.restore() }
        // v4: from the moment the Mac logs out, restarts or shuts down, nothing is written (macOS quits the apps first)
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.willPowerOffNotification, object: nil, queue: .main) { _ in
            self.star.poweringOff = true
        }
        // once a minute, as the Lua star did: its own apps (v2: always; the Lua star counts only its Lua ones)
        let t = Timer(timeInterval: 60, repeats: true) { _ in
            self.star.remember(); self.star.clock()
        }
        RunLoop.main.add(t, forMode: .common)
        // asked from outside, without the mouse (a test, the launcher):
        //   open / close the menu, toggle one row by its key, through the same code as a click
        let dnc = DistributedNotificationCenter.default()
        // not performClick: on a status button it opened the menu once and then never again (13.10.2026)
        dnc.addObserver(forName: .init("community.auroville.star.open"), object: nil, queue: .main) { _ in
            guard let b = self.item.button else { return }
            NSLog("star: open asked, button window %@", NSStringFromRect(b.window?.frame ?? .zero))
            DispatchQueue.main.async {
                self.menu.popUp(positioning: nil, at: NSPoint(x: 0, y: b.bounds.height + 5), in: b)
            }
        }
        dnc.addObserver(forName: .init("community.auroville.star.tint"), object: nil, queue: .main) { n in
            self.item.button?.image = Controller.starImage(n.object as? String ?? "")
        }
        dnc.addObserver(forName: .init("community.auroville.star.close"), object: nil, queue: .main) { _ in
            self.menu.cancelTracking()
        }
        dnc.addObserver(forName: .init("community.auroville.star.toggle"), object: nil, queue: .main) { n in
            self.star.load(); self.star.refresh()
            guard let key = n.object as? String, let r = self.star.rows.first(where: { $0.key == key }) else { return }
            self.star.toggle(r) { NSLog("star: toggled %@, on=%d", key, self.star.isOn(r) ? 1 : 0) }
        }
    }

    // the David star: two equilateral triangles, one up one down, soft white at 60 % (star.lua's drawing)
    // THE SIGN (Marko, 13.10.2026): "the logo is David Star or Yogic Star Shiva Shakti Balance Sri Aurobindo Ananda
    // Marko Yoga". Two equal triangles, one pointing up and one down, interlaced: the six-pointed star, never a
    // five-pointed one.
    // v7 (30.10.2026, Marko: "Let it be red"): the star is red while a macro records and green while one plays, as the
    // Lua star was; Macro Recorder (Mantra) posts community.auroville.star.tint with "red", "green" or "" (back to white)
    static func starImage(_ tint: String = "") -> NSImage {
        let ink = tint == "red" ? NSColor(srgbRed: 1, green: 0.23, blue: 0.19, alpha: 1)
                : tint == "green" ? NSColor(srgbRed: 0x33/255.0, green: 0xD1/255.0, blue: 0x7A/255.0, alpha: 1)
                : NSColor(white: 1, alpha: 0.6)
        let s: CGFloat = 18
        let img = NSImage(size: NSSize(width: s, height: s), flipped: false) { _ in
            let R = s / 2 - 1.5, cx = s / 2, cy = s / 2, c30: CGFloat = 0.8660254
            func tri(_ pts: [NSPoint]) {
                let p = NSBezierPath(); p.move(to: pts[0]); p.line(to: pts[1]); p.line(to: pts[2]); p.close()
                p.lineWidth = tint.isEmpty ? 1.05 : 1.6; p.lineJoinStyle = .round
                ink.setStroke(); p.stroke()
            }
            tri([NSPoint(x: cx, y: cy + R), NSPoint(x: cx - c30 * R, y: cy - R / 2), NSPoint(x: cx + c30 * R, y: cy - R / 2)])
            tri([NSPoint(x: cx, y: cy - R), NSPoint(x: cx + c30 * R, y: cy + R / 2), NSPoint(x: cx - c30 * R, y: cy + R / 2)])
            return true
        }
        img.isTemplate = false
        return img
    }

    func menuNeedsUpdate(_ m: NSMenu) {
        star.load()
        star.refresh()
        m.removeAllItems()
        // v4: the first row, Swift Matrix (Marko, 14.10.2026: "one more Swift in the star menu, which will be the first one")
        add(m, "▦   Swift Matrix  (what runs, what starts with the Mac)") { self.openPath(MATRIX_APP) }
            .isEnabled = FileManager.default.fileExists(atPath: MATRIX_APP)
        // v8 (31.10.2026, Marko: "All running application must be in category running under Swift matrix. Swift matrix
        // must be always at the top and then there is a line running and then everything running is listed there."):
        // under Swift Matrix a line RUNNING, then every one of the star's rows (folders included) that runs now, one row
        // each with its own number and the same click as its normal row. Built afresh at every opening.
        m.addItem(.separator())
        let all = star.rows.filter { $0.key != "monitor" && $0.key != "matrix" }
        var numberOf: [String: Int] = [:]
        for (i, r) in all.enumerated() { numberOf[r.key] = i + 1 }
        let runningNow = star.byPick(star.rows.filter { $0.key != "matrix" && star.isOn($0) })
        m.addItem(heading(runningNow.isEmpty ? "RUNNING   none running" : "RUNNING   \(runningNow.count)"))
        for r in runningNow {
            let it = rowItem(r, numberOf[r.key] ?? 0)
            it.representedObject = "running"
            m.addItem(it)
        }
        m.addItem(.separator())
        add(m, "⌕   Launcher  (search · favourites · ⌥Space)") { self.openPath(HOME + "/Developer/STAR_LAUNCHER/Star Menu.app") }
        if let mon = star.rows.first(where: { $0.key == "monitor" }) {
            // v3: Star Monitor is a Swift app (13.10.2026), opened like any app row
            let it = add(m, "✡   Star Monitor") { self.star.picked(mon); self.openPath(mon.app ?? "/Applications/Star Monitor (Mantra).app") }
            it.isEnabled = star.usable(mon)
        }
        m.addItem(.separator())

        let apps = star.rows.filter { $0.key != "monitor" && $0.key != "matrix" }
        let numbered = apps.enumerated().map { ($0 + 1, $1) }
        if star.foldersOn {
            var order = star.folders
            for r in apps where !order.contains(star.group(r)) { order.append(star.group(r)) }
            if let i = order.firstIndex(of: "Other") { order.remove(at: i); order.append("Other") }
            for g in order {
                let members = numbered.filter { star.group($0.1) == g }
                if members.isEmpty { continue }
                // v6 (22.10.2026, Marko: "there is no need for category. If any category has only one entry ... there
                // should be direct access. If there is more than one, then we go to sub-menus"): a folder of one is its app
                if members.count == 1 { m.addItem(rowItem(members[0].1, members[0].0)); continue }
                let on = members.filter { star.isOn($0.1) }.count
                let sub = NSMenu(); sub.autoenablesItems = false
                for (n, r) in members { sub.addItem(rowItem(r, n)) }
                let it = NSMenuItem(title: on > 0 ? "\(g)   \(on) on" : g, action: nil, keyEquivalent: "")
                it.submenu = sub
                m.addItem(it)
            }
        } else {
            for (n, r) in numbered { m.addItem(rowItem(r, n)) }
        }

        m.addItem(.separator())
        let anyOn = star.rows.contains { star.isOn($0) }
        add(m, "All off") { self.star.allOff {} }.isEnabled = anyOn
        add(m, star.foldersOn ? "Show the apps as one list" : "Show the apps in folders") { self.star.setFolders(!self.star.foldersOn) }
        add(m, "Menu bar order…  (your icons in a fixed order)") { MenuBarWindow.show() }
        add(m, "Go to the folder (STAR_SWIFT, the rows)") { self.openPath(HOME + "/Developer/STAR_SWIFT") }
        if !star.hsUp {
            let it = add(m, "Hammerspoon is off: the Lua apps wait for it") { self.openPath("/Applications/Hammerspoon.app") }
            it.toolTip = "Starts Hammerspoon, whose star still runs the apps not yet converted to Swift"
        }
        let v = add(m, "Star (Mantra)  v\(VERSION)") { NSWorkspace.shared.open(URL(string: REPO_URL)!) }
        v.attributedTitle = NSAttributedString(string: v.title, attributes: [.foregroundColor: NSColor.tertiaryLabelColor, .font: NSFont.menuFont(ofSize: 11)])
        m.addItem(.separator())
        add(m, star.hsUp ? "Quit everything (the apps, Hammerspoon, this star)" : "Quit everything (the apps, then this star)") { self.star.quitEverything() }
    }

    // a heading: grey, small capitals, not clickable
    func heading(_ t: String) -> NSMenuItem {
        let it = NSMenuItem(title: t, action: nil, keyEquivalent: "")
        it.isEnabled = false
        it.attributedTitle = NSAttributedString(string: t, attributes: [.foregroundColor: NSColor.secondaryLabelColor,
            .font: NSFont.systemFont(ofSize: 11, weight: .semibold), .kern: 0.8])
        return it
    }

    // `Star --print-menu`: the menu's titles in order, as menuNeedsUpdate builds them, without opening it on his screen.
    // "[R]" marks a row under RUNNING, "✓" a row whose app runs, "  >" an item inside a folder.
    func printMenu() {
        let m = NSMenu(); m.autoenablesItems = false
        star.load(); star.loadLuaCache()
        menuNeedsUpdate(m)
        func walk(_ m: NSMenu, _ depth: Int) {
            for it in m.items {
                let ind = String(repeating: "  > ", count: depth)
                if it.isSeparatorItem { print(ind + "----"); continue }
                var line = it.title
                if let v = it.view as? RowView {
                    line = (star.isOn(v.row) ? "✓ " : "  ") + (v.number > 0 ? String(format: "%2d ", v.number) : "   ") + v.row.name
                }
                if (it.representedObject as? String) == "running" { line = "[R] " + line }
                print(ind + line)
                if let sub = it.submenu { walk(sub, depth + 1) }
            }
        }
        walk(m, 0)
    }

    func rowItem(_ r: Row, _ n: Int) -> NSMenuItem {
        let it = NSMenuItem(title: r.name, action: nil, keyEquivalent: "")
        it.view = RowView(row: r, number: n, star: star)
        return it
    }

    private var actions: [NSMenuItem: () -> Void] = [:]
    @discardableResult
    func add(_ m: NSMenu, _ title: String, _ fn: @escaping () -> Void) -> NSMenuItem {
        let it = NSMenuItem(title: title, action: #selector(fire(_:)), keyEquivalent: "")
        it.target = self
        actions[it] = fn
        m.addItem(it)
        return it
    }
    @objc func fire(_ it: NSMenuItem) { actions[it]?() }
    func openPath(_ p: String) { NSWorkspace.shared.open(URL(fileURLWithPath: p)) }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let controller = Controller()
// `--picked <key>`: a test pick, recorded as a click would record it, without opening anything
if let i = CommandLine.arguments.firstIndex(of: "--picked"), i + 1 < CommandLine.arguments.count {
    controller.star.load()
    if let r = controller.star.rows.first(where: { $0.key == CommandLine.arguments[i + 1] }) { controller.star.picked(r) }
}
if CommandLine.arguments.contains("--print-menubar") { MenuBarOrder.printBar(); exit(0) }
// `--menubar-shot <png>`: the MENU BAR ORDER window drawn off screen into a picture, never shown
if let i = CommandLine.arguments.firstIndex(of: "--menubar-shot"), i + 1 < CommandLine.arguments.count {
    let w = MenuBarWindow(); w.window.appearance = NSAppearance(named: .aqua); w.reload()
    // v11: `--menubar-shot <png> --min` draws it at its minimum width
    if CommandLine.arguments.contains("--min") { w.window.setContentSize(w.window.minSize) }
    let v = w.window.contentView!; v.layoutSubtreeIfNeeded(); w.table.layoutSubtreeIfNeeded()
    func ids(_ x: NSView) -> [String] { [x.accessibilityIdentifier()].filter { !$0.isEmpty } + x.subviews.flatMap(ids) }
    print("menubar-shot \(Int(v.bounds.width))x\(Int(v.bounds.height)) ids:", ids(v).joined(separator: " "))
    if let rep = v.bitmapImageRepForCachingDisplay(in: v.bounds) {
        v.cacheDisplay(in: v.bounds, to: rep)
        try? rep.representation(using: .png, properties: [:])?.write(to: URL(fileURLWithPath: CommandLine.arguments[i + 1]))
    }
    exit(0)
}
if CommandLine.arguments.contains("--print-menu") { controller.printMenu(); exit(0) }
controller.setup()
app.run()
