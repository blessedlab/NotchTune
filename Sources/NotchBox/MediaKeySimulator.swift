import Foundation
import AppKit
import CoreGraphics

enum MediaKey {
    case play
    case next
    case previous
}

struct MediaKeySimulator {
    private static func postSystemDefinedKey(nxKeyCode: Int32) {
        let ts = ProcessInfo.processInfo.systemUptime

        let keyDown = NSEvent.otherEvent(
            with: .systemDefined,
            location: .zero,
            modifierFlags: NSEvent.ModifierFlags(rawValue: 0xa00),
            timestamp: ts,
            windowNumber: 0,
            context: nil,
            subtype: 8,
            data1: Int((nxKeyCode << 16) | (0xa << 8)),
            data2: -1
        )
        let keyUp = NSEvent.otherEvent(
            with: .systemDefined,
            location: .zero,
            modifierFlags: NSEvent.ModifierFlags(rawValue: 0xb00),
            timestamp: ts,
            windowNumber: 0,
            context: nil,
            subtype: 8,
            data1: Int((nxKeyCode << 16) | (0xb << 8)),
            data2: -1
        )

        keyDown?.cgEvent?.post(tap: .cgSessionEventTap)
        usleep(50000)
        keyUp?.cgEvent?.post(tap: .cgSessionEventTap)
    }

    static func simulate(_ key: MediaKey) {
        let nxCode: Int32
        switch key {
        case .play:     nxCode = 16  // NX_KEYTYPE_PLAY
        case .next:     nxCode = 17  // NX_KEYTYPE_NEXT
        case .previous: nxCode = 18  // NX_KEYTYPE_PREVIOUS
        }
        postSystemDefinedKey(nxKeyCode: nxCode)
    }
}
