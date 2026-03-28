// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PretextSwift",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "PretextSwift", targets: ["PretextSwift"])
    ],
    targets: [
        .target(name: "PretextSwift"),
        .testTarget(name: "PretextSwiftTests", dependencies: ["PretextSwift"])
    ]
)
