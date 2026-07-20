import CoreGraphics
import Foundation

enum MediaKey {
    case play
    case next
    case previous

    var nxKeyType: Int32 {
        switch self {
        case .play: return 16      // NX_KEYTYPE_PLAY
        case .next: return 17      // NX_KEYTYPE_NEXT
        case .previous: return 18  // NX_KEYTYPE_PREVIOUS
        }
    }
}

struct MediaKeySimulator {
    static func simulate(_ key: MediaKey) {
        let event = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: true)
        event?.setIntegerValueField(.keyboardEventKeycode, value: Int64(key.nxKeyType))
        event?.flags = .maskAlphaShift
        event?.post(tap: .cghidEventTap)

        let upEvent = CGEvent(keyboardEventSource: nil, virtualKey: 0, keyDown: false)
        upEvent?.setIntegerValueField(.keyboardEventKeycode, value: Int64(key.nxKeyType))
        upEvent?.flags = .maskAlphaShift
        upEvent?.post(tap: .cghidEventTap)
    }
}
