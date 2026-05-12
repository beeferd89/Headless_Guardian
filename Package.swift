// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HeadlessGuardian",
    platforms: [.macOS(.v13)],
    targets: [
        .target(name: "HeadlessGuardian", path: "Sources/HeadlessGuardian"),
        .testTarget(
            name: "HeadlessGuardianTests",
            dependencies: ["HeadlessGuardian"],
            path: "Tests/HeadlessGuardianTests"
        ),
    ]
)
