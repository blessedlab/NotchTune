// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NotchBox",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "NotchBox",
            path: "Sources/NotchBox",
            linkerSettings: [
                .linkedFramework("Cocoa"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("ApplicationServices"),
            ]
        )
    ]
)
