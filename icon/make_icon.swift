// make_icon.swift: the star's icon, drawn in code (MANTRA_MANIFEST swift-apps.md rule 4).
// What the app IS: the David star of the menu bar, soft white on a dark ground, and under it a row of
// small ticks, the menu's on/off switches.  swift icon/make_icon.swift icon  ->  icon/AppIcon.icns
import AppKit
let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon"
let set = out + "/AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: set, withIntermediateDirectories: true)
func draw(_ px: Int) -> Data {
    let s = CGFloat(px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: px, pixelsHigh: px, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let m = s * 0.1, box = NSRect(x: m, y: m, width: s - 2 * m, height: s - 2 * m)
    NSColor(calibratedRed: 0.09, green: 0.09, blue: 0.1, alpha: 1).setFill()
    NSBezierPath(roundedRect: box, xRadius: s * 0.18, yRadius: s * 0.18).fill()
    let R = s * 0.25, cx = s / 2, cy = s * 0.56, c30: CGFloat = 0.8660254
    func tri(_ p: [NSPoint]) {
        let b = NSBezierPath(); b.move(to: p[0]); b.line(to: p[1]); b.line(to: p[2]); b.close()
        b.lineWidth = max(1, s * 0.03); b.lineJoinStyle = .round
        NSColor(white: 1, alpha: 0.85).setStroke(); b.stroke()
    }
    tri([NSPoint(x: cx, y: cy + R), NSPoint(x: cx - c30 * R, y: cy - R / 2), NSPoint(x: cx + c30 * R, y: cy - R / 2)])
    tri([NSPoint(x: cx, y: cy - R), NSPoint(x: cx + c30 * R, y: cy + R / 2), NSPoint(x: cx - c30 * R, y: cy + R / 2)])
    // three switches under the star: on, off, on
    for (i, on) in [true, false, true].enumerated() {
        let w = s * 0.13, h = s * 0.06, x = s * 0.27 + CGFloat(i) * s * 0.17, y = s * 0.17
        let pill = NSBezierPath(roundedRect: NSRect(x: x, y: y, width: w, height: h), xRadius: h / 2, yRadius: h / 2)
        (on ? NSColor(calibratedRed: 0.3, green: 0.85, blue: 0.4, alpha: 1) : NSColor(white: 1, alpha: 0.25)).setFill(); pill.fill()
    }
    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}
for (name, px) in [("16x16", 16), ("16x16@2x", 32), ("32x32", 32), ("32x32@2x", 64), ("128x128", 128), ("128x128@2x", 256),
                   ("256x256", 256), ("256x256@2x", 512), ("512x512", 512), ("512x512@2x", 1024)] {
    try! draw(px).write(to: URL(fileURLWithPath: "\(set)/icon_\(name).png"))
}
try! draw(1024).write(to: URL(fileURLWithPath: out + "/icon_1024.png"))
