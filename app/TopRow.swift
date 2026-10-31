// v11 (31.10.2026, Marko: "Please go to all the interface of my applications. Each needs to have the same user interface
// elements. On, off and top. Please build it in every application."): the first row ON OFF … Star … TOP
// ✕, in the title bar of its one window (MENU BAR ORDER) beside the traffic lights, as MANTRA_SOUND_RECORDER's TopRow (MANTRA_MANIFEST
// swift-apps.md, "The first row of every app"), here in AppKit. Every word is a real NSButton, so Accessibility presses
// it by its identifier: `off`, `top`, `close`. The star needs no permission, so PERMISSIONS stays hidden. OFF quits the
// star only (no app it opened is touched); "Quit everything" in its menu is the other, wider way out.
import AppKit

enum Ink {
    static let green = NSColor(red: 0x33/255, green: 0xD1/255, blue: 0x7A/255, alpha: 1)
    static let grey = NSColor(red: 0x7A/255, green: 0x80/255, blue: 0x87/255, alpha: 1)
    static let amber = NSColor(red: 0xE8/255, green: 0xA3/255, blue: 0x3D/255, alpha: 1)
}

final class TopRow: NSView {
    static let height: CGFloat = 30
    let on = NSTextField(labelWithString: "ON")
    let off = NSButton(title: "OFF", target: nil, action: nil)
    let top = NSButton(title: "TOP", target: nil, action: nil)
    let perm = NSButton(title: "PERMISSIONS", target: nil, action: nil)
    let close = NSButton(title: "", target: nil, action: nil)
    let name = NSTextField(labelWithString: "")

    init(bold: String, rest: String, windowTitle: String, offHelp: String, onPermissions: @escaping () -> Void = {}) {
        self.windowTitle = windowTitle
        self.onPermissions = onPermissions
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let t = NSMutableAttributedString(string: bold, attributes: [.font: NSFont.systemFont(ofSize: 15, weight: .bold), .foregroundColor: NSColor.labelColor])
        t.append(NSAttributedString(string: rest, attributes: [.font: NSFont.systemFont(ofSize: 15), .foregroundColor: NSColor.labelColor]))
        name.attributedStringValue = t
        on.font = Self.font; on.textColor = Ink.green
        word(off, "OFF", Ink.grey, "Off", "off", offHelp, #selector(pressOff))
        word(top, "TOP", Ink.grey, "Top", "top", "Always on top: green, the window stays above every other window", #selector(pressTop))
        word(perm, "PERMISSIONS", Ink.amber, "Permissions", "permissions", "A permission is missing: this opens its page in System Settings", #selector(pressPermissions))
        close.image = NSImage(systemSymbolName: "xmark", accessibilityDescription: "Close window")?
            .withSymbolConfiguration(.init(pointSize: 12, weight: .semibold))
        close.contentTintColor = Ink.grey; close.isBordered = false; close.imagePosition = .imageOnly
        close.target = self; close.action = #selector(pressClose)
        close.setAccessibilityLabel("Close window"); close.setAccessibilityIdentifier("close")
        close.widthAnchor.constraint(equalToConstant: 28).isActive = true; close.heightAnchor.constraint(equalToConstant: 28).isActive = true

        let gap = NSView(); gap.setContentHuggingPriority(.init(1), for: .horizontal)
        let pad = NSView(); pad.widthAnchor.constraint(equalToConstant: 64 - 10).isActive = true   // the traffic lights
        let row = NSStackView(views: [pad, on, off, gap, top, perm, close]); row.orientation = .horizontal; row.spacing = 10
        row.translatesAutoresizingMaskIntoConstraints = false
        name.translatesAutoresizingMaskIntoConstraints = false
        addSubview(name); addSubview(row)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Self.height),
            row.leadingAnchor.constraint(equalTo: leadingAnchor), row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            row.centerYAnchor.constraint(equalTo: centerYAnchor),
            name.centerXAnchor.constraint(equalTo: centerXAnchor), name.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        paintTop(); showPermissions(false)
    }
    required init?(coder: NSCoder) { fatalError() }

    static let font = NSFont.monospacedSystemFont(ofSize: 12, weight: .bold)
    let onPermissions: () -> Void
    let windowTitle: String
    var onTop: Bool { UserDefaults.standard.bool(forKey: "onTop") }

    private func word(_ b: NSButton, _ text: String, _ colour: NSColor, _ label: String, _ id: String, _ tip: String, _ sel: Selector) {
        b.isBordered = false; b.target = self; b.action = sel; b.toolTip = tip
        b.attributedTitle = NSAttributedString(string: text, attributes: [.font: Self.font, .foregroundColor: colour])
        b.setAccessibilityLabel(label); b.setAccessibilityIdentifier(id)
    }
    func paintTop() {
        word(top, "TOP", onTop ? Ink.green : Ink.grey, "Top", "top", top.toolTip ?? "", #selector(pressTop))
        top.setAccessibilityValue(onTop ? "on" : "off")
    }
    func showPermissions(_ missing: Bool) { perm.isHidden = !missing }

    // OFF answers the press first, then quits (MANTRA_MANIFEST "Accessibility built in" 2)
    @objc func pressOff() { DispatchQueue.main.async { NSApp.terminate(nil) } }
    @objc func pressTop() { UserDefaults.standard.set(!onTop, forKey: "onTop"); TopRow.float(onTop, windowTitle); paintTop() }
    @objc func pressPermissions() { onPermissions() }
    @objc func pressClose() { window?.performClose(nil) }

    static func float(_ on: Bool, _ title: String) {
        for w in NSApp.windows where w.title == title { w.level = on ? .floating : .normal }
    }
}
