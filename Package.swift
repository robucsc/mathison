// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SimpleRunnerDriver",
    platforms: [.macOS(.v13)],
    products: [
        .library(
            name: "SimpleRunnerDriver",
            type: .dynamic,
            targets: ["SimpleRunnerDriver"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftGodot", branch: "main")
    ],
    targets: [
        .target(
            name: "SimpleRunnerDriver",
            dependencies: [
                    "SwiftGodot",
            ],
        swiftSettings: [.unsafeFlags(["-suppress-warnings"])]
    ),
    .testTarget(
            name: "SimpleRunnerDriverTests",
            dependencies: ["SimpleRunnerDriver"]),
    ]
)
