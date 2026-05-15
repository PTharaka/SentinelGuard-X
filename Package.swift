// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SentinelGuardX",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(
            name: "SentinelGuardX",
            path: "Sources/SentinelGuardX",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
