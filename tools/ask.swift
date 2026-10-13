// tools/ask.swift: tells the running Star (Mantra) to open | close | toggle <key>, without the mouse.
//   swift tools/ask.swift open      swift tools/ask.swift toggle spectral
import Foundation
let a = CommandLine.arguments
guard a.count > 1 else { print("open | close | toggle <key>"); exit(1) }
DistributedNotificationCenter.default().postNotificationName(.init("community.auroville.star." + a[1]),
    object: a.count > 2 ? a[2] : nil, userInfo: nil, deliverImmediately: true)
