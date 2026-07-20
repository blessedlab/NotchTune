import Foundation
import CoreAudio

struct VolumeControl {
    static var volume: Float {
        get {
            var deviceID = AudioDeviceID(0)
            var size = UInt32(MemoryLayout<AudioDeviceID>.size)

            var propertyAddress = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDefaultOutputDevice,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )

            AudioObjectGetPropertyData(
                AudioObjectID(kAudioObjectSystemObject),
                &propertyAddress,
                0, nil,
                &size,
                &deviceID
            )

            propertyAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyVolumeScalar,
                mScope: kAudioDevicePropertyScopeOutput,
                mElement: kAudioObjectPropertyElementMain
            )

            var vol: Float = 0
            AudioObjectGetPropertyData(
                deviceID,
                &propertyAddress,
                0, nil,
                &size,
                &vol
            )

            return vol
        }
        set {
            var deviceID = AudioDeviceID(0)
            var size = UInt32(MemoryLayout<AudioDeviceID>.size)

            var propertyAddress = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDefaultOutputDevice,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )

            AudioObjectGetPropertyData(
                AudioObjectID(kAudioObjectSystemObject),
                &propertyAddress,
                0, nil,
                &size,
                &deviceID
            )

            var volume = newValue
            propertyAddress = AudioObjectPropertyAddress(
                mSelector: kAudioDevicePropertyVolumeScalar,
                mScope: kAudioDevicePropertyScopeOutput,
                mElement: kAudioObjectPropertyElementMain
            )

            AudioObjectSetPropertyData(
                deviceID,
                &propertyAddress,
                0, nil,
                UInt32(MemoryLayout<Float>.size),
                &volume
            )
        }
    }

    static func volumeIcon(_ volume: Float) -> String {
        switch volume {
        case 0: return "speaker.fill"
        case 0..<0.33: return "speaker.wave.1.fill"
        case 0.33..<0.66: return "speaker.wave.2.fill"
        default: return "speaker.wave.3.fill"
        }
    }
}
