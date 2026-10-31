// MenuBar.swift: the fixed places in the menu bar (Star (Mantra) v10, 31.10.2026).
//
// Marko, 31.10.2026: "always make sure the Star menu is at the same position in my menu bar. I have date and time. I
// have something to connect to my Wi-Fi and Bluetooth. Then there is Star, and after Star I have sound source ...
// Please add this Star in the Swift application so that I can have all the icons opening on my bar and arrange them in
// some fixed orientation, and then the menu bar follows that. Now, when new buttons are added, they're going all over
// the place."
//
// HOW macOS PLACES AN ICON: each app keeps "NSStatusItem Preferred Position <autosaveName>" in its own defaults; the
// lower the value, the further right, after the pinned Clock and Control Centre (measured 31.10.2026: SoundSource 20 sits
// right of Battery 97, right of Hot 261). An icon with no value appears at the left end. The value is read when the app
// creates the icon, so a new value takes effect when the app starts again.
//
// The star writes its own value at every launch (STAR_VALUE, the lowest), so it is always right after Control Centre.
// The others follow the order he drags in the MENU BAR ORDER window; they are moved only by his REORDER click: the app is
// quit, its value written, and it is opened again (never SoundSource, Little Snitch or Hammerspoon, which only get the
// value for their next start). An icon he never placed stays where macOS puts new ones: the left end.

import AppKit

struct BarItem {
    var pid: pid_t
    var owner: String
    var bundleID: String?
    var name: String?          // the autosave name, when it can be known
    var nameFrom: String       // "window", "prefs", "assumed", ""
    var x: CGFloat
    var width: CGFloat
    var id: String { (bundleID ?? owner) + "#" + (name ?? "?") }
    var apple: Bool { (bundleID ?? "").hasPrefix("com.apple.") }
    var star: Bool { bundleID == "community.auroville.star" }
    // relaunching these would cut his sound, his firewall or the Lua rows mid-work: they get the value, and it counts
    // from their next start
    var protected: Bool {
        ["com.rogueamoeba.soundsource", "at.obdev.littlesnitch.agent", "org.hammerspoon.Hammerspoon"].contains(bundleID ?? "")
            || (bundleID ?? "").hasPrefix("at.obdev.littlesnitch")
    }
    var orderable: Bool { !apple && !star && bundleID != nil && name != nil }
    var why: String {
        if star { return "the star: first after Control Centre" }
        if apple { return "macOS places it" }
        if bundleID == nil { return "cannot: no app to write to" }
        if name == nil { return "cannot: its icon has no known name" }
        if protected { return "can order · counts from its next start" }
        return nameFrom == "assumed" ? "can order · name taken as Item-0" : "can order"
    }
}

enum MenuBarOrder {
    static let STAR_NAME = "star"
    static let STAR_VALUE: Double = 10
    static let ORDER_KEY = "menuBarOrder"   // the ids, right to left, as he dragged them
    static let PREFIX = "NSStatusItem Preferred Position "
    // icons whose name is known, for when the window names cannot be read (the star has no Screen Recording)
    static let KNOWN = ["com.rogueamoeba.soundsource": "SSMainAppMenuIcon", "org.hammerspoon.Hammerspoon": "Item-1",
                        "com.bjango.istatmenus.status": "com.bjango.istatmenus.network"]

    static func placeStar() {
        UserDefaults.standard.set(STAR_VALUE, forKey: PREFIX + STAR_NAME)
    }

    // the plist an app reads: its container's, when it is sandboxed
    static func prefsDomain(_ bid: String) -> String {
        let c = NSHomeDirectory() + "/Library/Containers/\(bid)/Data/Library/Preferences/\(bid).plist"
        return FileManager.default.fileExists(atPath: c) ? String(c.dropLast(6)) : bid
    }
    static func prefs(_ bid: String) -> [String: Any] {
        let c = NSHomeDirectory() + "/Library/Containers/\(bid)/Data/Library/Preferences/\(bid).plist"
        let p = FileManager.default.fileExists(atPath: c) ? c : NSHomeDirectory() + "/Library/Preferences/\(bid).plist"
        return (NSDictionary(contentsOfFile: p) as? [String: Any]) ?? [:]
    }
    static func positionKeys(_ bid: String) -> [String: Double] {
        var r: [String: Double] = [:]
        for (k, v) in prefs(bid) where k.hasPrefix(PREFIX) { r[String(k.dropFirst(PREFIX.count))] = (v as? NSNumber)?.doubleValue }
        return r
    }

    // every icon now in the menu bar, right to left, read on the screen that shows the most of them (the MacBook's
    // notch hides the left part of the bar there)
    static func current() -> [BarItem] {
        guard let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] else { return [] }
        let screens = NSScreen.screens.map { $0.frame }
        var byScreen: [Int: [BarItem]] = [:]
        for w in list where (w[kCGWindowLayer as String] as? Int) == 25 {
            guard let b = w[kCGWindowBounds as String] as? [String: CGFloat], let x = b["X"], let wd = b["Width"], wd > 0,
                  let pid = w[kCGWindowOwnerPID as String] as? pid_t else { continue }
            let owner = (w[kCGWindowOwnerName as String] as? String) ?? "?"
            let wname = (w[kCGWindowName as String] as? String).flatMap { $0.isEmpty ? nil : $0 }
            let s = screens.firstIndex { x >= $0.minX && x < $0.maxX } ?? 0
            let ra = NSRunningApplication(processIdentifier: pid)
            let bid = ra?.bundleIdentifier
            let shown = ra?.localizedName ?? owner       // CGWindowList cuts long names at 31 characters
            byScreen[s, default: []].append(BarItem(pid: pid, owner: shown, bundleID: bid, name: wname,
                                                    nameFrom: wname == nil ? "" : "window", x: x, width: wd))
        }
        guard let best = byScreen.max(by: { $0.value.count < $1.value.count })?.value else { return [] }
        var items = best.sorted { $0.x > $1.x }
        // an icon without a window name (no Screen Recording): the name from its app's own prefs, or Item-0
        var perPid: [pid_t: Int] = [:]
        for it in items { perPid[it.pid, default: 0] += 1 }
        for i in items.indices where items[i].name == nil {
            guard let bid = items[i].bundleID, !items[i].apple else { continue }
            if items[i].star { items[i].name = STAR_NAME; items[i].nameFrom = "prefs"; continue }
            let keys = positionKeys(bid)
            if let k = KNOWN[bid], perPid[items[i].pid] == 1 { items[i].name = k; items[i].nameFrom = "known"; continue }
            if perPid[items[i].pid] == 1 {
                if keys.count == 1 { items[i].name = keys.keys.first; items[i].nameFrom = "prefs" }
                else if keys.isEmpty || keys["Item-0"] != nil { items[i].name = "Item-0"; items[i].nameFrom = keys.isEmpty ? "assumed" : "prefs" }
            }
        }
        return items
    }

    static var saved: [String] {
        get { UserDefaults.standard.stringArray(forKey: ORDER_KEY) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: ORDER_KEY) }
    }
    // his order applied to what is in the bar now: the ones he placed in his order, any new one after them (the left end)
    static func ordered(_ now: [BarItem]) -> [BarItem] {
        let third = now.filter { !$0.apple && !$0.star }
        let rank = Dictionary(saved.enumerated().map { ($1, $0) }, uniquingKeysWith: { a, _ in a })
        return third.enumerated().sorted { a, b in
            (rank[a.1.id] ?? 10000 + a.0) < (rank[b.1.id] ?? 10000 + b.0)
        }.map { $0.1 }
    }
    // the values: right to left, after the star's, each the last plus its width
    static func values(_ order: [BarItem]) -> [String: Double] {
        var v: [String: Double] = [:]
        var at = STAR_VALUE + 10
        for it in order where it.orderable { v[it.id] = at; at += Double(it.width) }
        return v
    }

    // REORDER (his click only): every orderable icon gets its value; the ones out of place are quit, written and
    // opened again, one after the other; the protected ones are written only
    static func apply(_ order: [BarItem], log: @escaping (String) -> Void) {
        let vals = values(order)
        let now = current().filter { !$0.apple && !$0.star }.map { $0.id }
        let want = order.map { $0.id }.filter { now.contains($0) }
        DispatchQueue.global().async {
            for (i, it) in order.enumerated() where it.orderable {
                guard let bid = it.bundleID, let name = it.name, let v = vals[it.id] else { continue }
                let inPlace = now.firstIndex(of: it.id) == want.firstIndex(of: it.id) && positionKeys(bid)[name] == v
                if inPlace { log("\(i + 1). \(it.owner): in place"); continue }
                let relaunch = !it.protected && now.firstIndex(of: it.id) != want.firstIndex(of: it.id)
                var url: URL?
                if relaunch, let app = NSRunningApplication(processIdentifier: it.pid) {
                    url = app.bundleURL
                    app.terminate()
                    for _ in 0..<40 where !app.isTerminated { Thread.sleep(forTimeInterval: 0.25) }
                    if !app.isTerminated { log("\(i + 1). \(it.owner): did not quit, left as it is"); continue }
                }
                write(prefsDomain(bid), PREFIX + name, v)
                if let url = url {
                    let c = NSWorkspace.OpenConfiguration(); c.activates = false; c.addsToRecentItems = false
                    NSWorkspace.shared.openApplication(at: url, configuration: c) { _, _ in }
                    Thread.sleep(forTimeInterval: 1.5)
                    log("\(i + 1). \(it.owner): moved (quit, placed, opened again)")
                } else {
                    log("\(i + 1). \(it.owner): placed" + (it.protected ? ", counts from its next start" : ""))
                }
            }
            log("done")
        }
    }
    static func write(_ domain: String, _ key: String, _ v: Double) {
        let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/bin/defaults")
        p.arguments = ["write", domain, key, "-float", String(v)]
        try? p.run(); p.waitUntilExit()
    }

    // `Star --print-menubar`: the bar now, right to left, and what can be ordered
    static func printBar() {
        let now = current()
        print("MENU BAR, right to left (\(now.count) icons):")
        for (i, it) in now.enumerated() {
            print(String(format: "%2d  %@  [%@%@]  x %.0f w %.0f  %@", i + 1, it.owner, it.bundleID ?? "no bundle",
                         it.name.map { " · " + $0 + (it.nameFrom == "assumed" ? "?" : "") } ?? "", it.x, it.width, it.why))
        }
        let o = ordered(now), v = values(o)
        print("HIS ORDER (saved \(saved.count)), right to left after the star:")
        for (i, it) in o.enumerated() { print(String(format: "%2d  %@  %@", i + 1, it.owner, v[it.id].map { String(format: "→ %.0f", $0) } ?? "-")) }
    }
}

// MARK: the window

final class MenuBarWindow: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    static var shared: MenuBarWindow?
    var window: NSWindow!
    let table = NSTableView()
    let status = NSTextField(wrappingLabelWithString: "")
    var rows: [BarItem] = []
    let drag = NSPasteboard.PasteboardType("community.auroville.star.baritem")

    static func show() {
        if shared == nil { shared = MenuBarWindow() }
        shared!.reload()
        shared!.window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    override init() {
        super.init()
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 720, height: 560),
                          styleMask: [.titled, .closable, .resizable, .miniaturizable], backing: .buffered, defer: false)
        window.title = "Menu bar order (Star)"
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 420, height: 320)
        window.center()
        let v = window.contentView!

        let head = NSTextField(wrappingLabelWithString: "Right to left, as in the menu bar: Clock and Control Centre (macOS, pinned), the star, then yours. Drag the rows into your order, press SAVE ORDER. REORDER quits and reopens only the apps that are out of place. A new icon goes to the left end.")
        head.font = .systemFont(ofSize: 12); head.textColor = .secondaryLabelColor

        for (id, title, w) in [("n", "#", 30.0), ("app", "App", 260.0), ("can", "Can it be ordered", 340.0)] {
            let c = NSTableColumn(identifier: .init(id)); c.title = title; c.width = CGFloat(w)
            c.resizingMask = id == "can" ? .autoresizingMask : .userResizingMask
            table.addTableColumn(c)
        }
        table.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        table.dataSource = self; table.delegate = self
        table.registerForDraggedTypes([drag])
        table.draggingDestinationFeedbackStyle = .gap
        table.usesAlternatingRowBackgroundColors = true
        table.rowHeight = 22
        let scroll = NSScrollView(); scroll.documentView = table; scroll.hasVerticalScroller = true; scroll.borderType = .bezelBorder

        let save = NSButton(title: "SAVE ORDER", target: self, action: #selector(saveOrder))
        let apply = NSButton(title: "REORDER", target: self, action: #selector(reorder))
        let again = NSButton(title: "READ THE BAR AGAIN", target: self, action: #selector(readAgain))
        apply.keyEquivalent = ""
        status.font = .systemFont(ofSize: 11); status.textColor = .secondaryLabelColor
        let buttons = NSStackView(views: [again, NSView(), save, apply]); buttons.orientation = .horizontal

        let stack = NSStackView(views: [head, scroll, buttons, status])
        stack.orientation = .vertical; stack.alignment = .leading; stack.spacing = 10
        stack.edgeInsets = NSEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)
        stack.translatesAutoresizingMaskIntoConstraints = false
        v.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: v.leadingAnchor), stack.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            stack.topAnchor.constraint(equalTo: v.topAnchor), stack.bottomAnchor.constraint(equalTo: v.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 16),
            scroll.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -16),
            head.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 16),
            head.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -16),
            buttons.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 16),
            buttons.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -16),
            status.leadingAnchor.constraint(equalTo: stack.leadingAnchor, constant: 16),
            status.trailingAnchor.constraint(equalTo: stack.trailingAnchor, constant: -16),
        ])
    }

    func reload() {
        let now = MenuBarOrder.current()
        rows = MenuBarOrder.ordered(now)
        table.reloadData()
        let fixed = now.filter { $0.apple || $0.star }.map { $0.star ? "the star" : $0.owner }
        status.stringValue = "Fixed on the right: " + fixed.joined(separator: ", ") + "."
    }
    @objc func readAgain() { reload() }
    @objc func saveOrder() {
        MenuBarOrder.saved = rows.map { $0.id }
        status.stringValue = "Saved: \(rows.count) icons in your order."
    }
    @objc func reorder() {
        saveOrder()
        status.stringValue = "Reordering…"
        var lines: [String] = []
        MenuBarOrder.apply(rows) { line in
            DispatchQueue.main.async {
                lines.append(line); self.status.stringValue = lines.joined(separator: "   ")
                if line == "done" { DispatchQueue.main.asyncAfter(deadline: .now() + 2) { self.reload(); self.status.stringValue = lines.joined(separator: "   ") } }
            }
        }
    }

    func numberOfRows(in t: NSTableView) -> Int { rows.count }
    func tableView(_ t: NSTableView, viewFor c: NSTableColumn?, row: Int) -> NSView? {
        let it = rows[row]
        let f = NSTextField(labelWithString: "")
        f.lineBreakMode = .byTruncatingTail
        switch c?.identifier.rawValue {
        case "n": f.stringValue = "\(row + 1)"; f.textColor = .secondaryLabelColor
        case "app": f.stringValue = it.owner
        default: f.stringValue = it.why; f.textColor = it.orderable ? .secondaryLabelColor : .systemOrange
        }
        return f
    }
    func tableView(_ t: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let p = NSPasteboardItem(); p.setString(String(row), forType: drag); return p
    }
    func tableView(_ t: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation op: NSTableView.DropOperation) -> NSDragOperation {
        if op == .on { t.setDropRow(row, dropOperation: .above) }
        return .move
    }
    func tableView(_ t: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation op: NSTableView.DropOperation) -> Bool {
        guard let s = info.draggingPasteboard.pasteboardItems?.first?.string(forType: drag), let from = Int(s) else { return false }
        let it = rows.remove(at: from)
        rows.insert(it, at: from < row ? row - 1 : row)
        t.reloadData()
        status.stringValue = "Moved \(it.owner). SAVE ORDER keeps it; REORDER applies it."
        return true
    }
}
