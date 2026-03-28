// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "PretextSwift",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "PretextCore", targets: ["PretextCore"]),
        .library(name: "PretextSwiftUIAdapter", targets: ["PretextSwiftUIAdapter"])
    ],
    targets: [
        .target(
            name: "PretextCore",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .target(
            name: "PretextSwiftUIAdapter",
            dependencies: ["PretextCore"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "PretextCoreTests",
            dependencies: ["PretextCore"],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        )
    ]
)
