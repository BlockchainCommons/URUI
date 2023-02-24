// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "URUI",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "URUI",
            targets: ["URUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/BlockchainCommons/URKit.git", from: "11.0.0"),
    ],
    targets: [
        .target(
            name: "URUI",
            dependencies: ["URKit"])
    ]
)
