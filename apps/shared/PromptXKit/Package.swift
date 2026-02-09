// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "PromptXKit",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
    ],
    products: [
        .library(name: "PromptXProtocol", targets: ["PromptXProtocol"]),
        .library(name: "PromptXKit", targets: ["PromptXKit"]),
        .library(name: "PromptXChatUI", targets: ["PromptXChatUI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/steipete/ElevenLabsKit", exact: "0.1.0"),
        .package(url: "https://github.com/gonzalezreal/textual", exact: "0.3.1"),
    ],
    targets: [
        .target(
            name: "PromptXProtocol",
            path: "Sources/PromptXProtocol",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "PromptXKit",
            dependencies: [
                "PromptXProtocol",
                .product(name: "ElevenLabsKit", package: "ElevenLabsKit"),
            ],
            path: "Sources/PromptXKit",
            resources: [
                .process("Resources"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "PromptXChatUI",
            dependencies: [
                "PromptXKit",
                .product(
                    name: "Textual",
                    package: "textual",
                    condition: .when(platforms: [.macOS, .iOS])),
            ],
            path: "Sources/PromptXChatUI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "PromptXKitTests",
            dependencies: ["PromptXKit", "PromptXChatUI"],
            path: "Tests/PromptXKitTests",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
