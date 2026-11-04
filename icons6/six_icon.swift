// six_icon.swift: the star apps' icons (Marko 4.11.2026): six letters, three on top and three below, over ONE
// symbolic picture, nothing else. swift six_icon.swift icons.json <outdir> [key]
// -> <outdir>/<key>/icon_1024.png and AppIcon.icns, and <outdir>/sheet.png (every icon at 128 and at 48 px).
import AppKit
let a = CommandLine.arguments
let table = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: a[1]))) as! [String: Any]
let out = a[2], only = a.count > 3 ? a[3] : nil
let groups = table["groups"] as! [String: String]
let rows = try! JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: NSString(string: "~/.config/star-rows.json").expandingTildeInPath))) as! [String: Any]
var groupOf: [String: String] = [:]
for r in rows["rows"] as! [[String: Any]] { groupOf[r["key"] as! String] = r["group"] as? String ?? "Mac" }
func hex(_ h: String) -> NSColor {
    let v = Int(h.dropFirst(), radix: 16)!
    return NSColor(srgbRed: CGFloat((v >> 16) & 255) / 255, green: CGFloat((v >> 8) & 255) / 255, blue: CGFloat(v & 255) / 255, alpha: 1)
}
func font(_ size: CGFloat) -> NSFont {
    let base = NSFont.systemFont(ofSize: size, weight: .black)
    return NSFont(descriptor: base.fontDescriptor.withDesign(.rounded) ?? base.fontDescriptor, size: size) ?? base
}
func draw(_ px: Int, top: String, bottom: String, symbol: String, color: NSColor) -> NSBitmapImageRep {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSGraphicsContext.current!.imageInterpolation = .high
    // the tile: Apple's grid, 824 of 1024, corner 185
    let m = s * 100 / 1024, box = NSRect(x: m, y: m, width: s - 2 * m, height: s - 2 * m)
    let tile = NSBezierPath(roundedRect: box, xRadius: s * 185 / 1024, yRadius: s * 185 / 1024)
    NSGradient(starting: color.blended(withFraction: 0.18, of: .white)!, ending: color.blended(withFraction: 0.35, of: .black)!)!
        .draw(in: tile, angle: -90)
    // the one picture: the symbol, large, behind the letters
    tile.addClip()
    let cfg = NSImage.SymbolConfiguration(pointSize: s * 0.62, weight: .bold)
    if let img = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)?.withSymbolConfiguration(cfg) {
        let tinted = NSImage(size: img.size, flipped: false) { r in
            img.draw(in: r); NSColor(white: 1, alpha: 0.30).set(); r.fill(using: .sourceAtop); return true }
        let k = min(box.width * 0.86 / img.size.width, box.height * 0.86 / img.size.height)
        let w = img.size.width * k, h = img.size.height * k
        tinted.draw(in: NSRect(x: (s - w) / 2, y: (s - h) / 2, width: w, height: h))
    } else { FileHandle.standardError.write("no symbol \(symbol)\n".data(using: .utf8)!) }
    // the six letters: one size for both rows, the wider row fills 76 % of the tile
    var fs = s * 0.40
    let shadow = NSShadow(); shadow.shadowColor = NSColor(white: 0, alpha: 0.45)
    shadow.shadowOffset = NSSize(width: 0, height: -s * 0.008); shadow.shadowBlurRadius = s * 0.015
    func attrs(_ f: CGFloat) -> [NSAttributedString.Key: Any] {
        [.font: font(f), .foregroundColor: NSColor.white, .shadow: shadow, .kern: f * 0.02] }
    let wmax = max((top as NSString).size(withAttributes: attrs(fs)).width, (bottom as NSString).size(withAttributes: attrs(fs)).width)
    fs *= box.width * 0.68 / wmax
    fs = min(fs, s * 0.34)
    let f = font(fs), cap = f.capHeight, gap = cap * 0.42
    let y0 = s / 2 - (2 * cap + gap) / 2           // baseline of the bottom row
    for (str, base) in [(bottom, y0), (top, y0 + cap + gap)] {
        let w = (str as NSString).size(withAttributes: attrs(fs)).width
        (str as NSString).draw(at: NSPoint(x: (s - w) / 2 + fs * 0.01, y: base + f.descender), withAttributes: attrs(fs))
    }
    NSGraphicsContext.restoreGraphicsState()
    return rep
}
func png(_ r: NSBitmapImageRep) -> Data { r.representation(using: .png, properties: [:])! }
var made: [(String, NSBitmapImageRep)] = []
for e in table["icons"] as! [[String]] {
    let key = e[0]; if let o = only, o != key { continue }
    let col = hex(groups[groupOf[key] ?? "Mac"] ?? "#2C323E")
    let dir = "\(out)/\(key)", set = "\(dir)/AppIcon.iconset"
    try? FileManager.default.removeItem(atPath: set)
    try! FileManager.default.createDirectory(atPath: set, withIntermediateDirectories: true)
    for (n, p) in [("16x16", 16), ("16x16@2x", 32), ("32x32", 32), ("32x32@2x", 64), ("128x128", 128), ("128x128@2x", 256),
                   ("256x256", 256), ("256x256@2x", 512), ("512x512", 512), ("512x512@2x", 1024)] {
        try! png(draw(p, top: e[1], bottom: e[2], symbol: e[3], color: col)).write(to: URL(fileURLWithPath: "\(set)/icon_\(n).png"))
    }
    let big = draw(1024, top: e[1], bottom: e[2], symbol: e[3], color: col)
    try! png(big).write(to: URL(fileURLWithPath: "\(dir)/icon_1024.png"))
    let p = Process(); p.launchPath = "/usr/bin/iconutil"; p.arguments = ["-c", "icns", set, "-o", "\(dir)/AppIcon.icns"]
    p.launch(); p.waitUntilExit()
    try? FileManager.default.removeItem(atPath: set)
    made.append((key, big))
}
// the contact sheet: each icon at 128 and beside it at 48, on a light and a dark band
let cols = 8, cell = 200, rowsN = (made.count + cols - 1) / cols
let W = cols * cell, H = rowsN * cell
let sheet = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: W, pixelsHigh: H, bitsPerSample: 8, samplesPerPixel: 4,
                             hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.saveGraphicsState(); NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: sheet)
NSColor(white: 0.93, alpha: 1).setFill(); NSRect(x: 0, y: 0, width: W, height: H).fill()
for (i, (key, rep)) in made.enumerated() {
    let x = CGFloat((i % cols) * cell), y = CGFloat(H - (i / cols + 1) * cell)
    let img = NSImage(size: NSSize(width: 1024, height: 1024)); img.addRepresentation(rep)
    img.draw(in: NSRect(x: x + 4, y: y + 50, width: 128, height: 128))
    img.draw(in: NSRect(x: x + 140, y: y + 50, width: 48, height: 48))
    (key as NSString).draw(at: NSPoint(x: x + 8, y: y + 22), withAttributes: [.font: NSFont.systemFont(ofSize: 15), .foregroundColor: NSColor.black])
}
NSGraphicsContext.restoreGraphicsState()
try! png(sheet).write(to: URL(fileURLWithPath: "\(out)/sheet.png"))
print("made \(made.count) icons in \(out)")
