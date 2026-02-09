// swift-tools-version: 6.2
// Package manifest for the PromptX macOS companion (menu bar app + IPC library).

import PackageDescription

let package = Package(
    name: "PromptX",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(name: "PromptXIPC", targets: ["PromptXIPC"]),
        .library(name: "PromptXDiscovery", targets: ["PromptXDiscovery"]),
        .executable(name: "PromptX", targets: ["PromptX"]),
        .executable(name: "promptx-mac", targets: ["PromptXMacCLI"]),
    ],
    dependencies: [
        .package(url: "https://github.com/orchetect/MenuBarExtraAccess", exact: "1.2.2"),
        .package(url: "https://github.com/swiftlang/swift-subprocess.git", from: "0.1.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.8.0"),
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.8.1"),
        .package(url: "https://github.com/steipete/Peekaboo.git", branch: "main"),
        .package(path: "../shared/PromptXKit"),
        .package(path: "../../Swabble"),
    ],
    targets: [
        .target(
            name: "PromptXIPC",
            dependencies: [],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .target(
            name: "PromptXDiscovery",
            dependencies: [
                .product(name: "PromptXKit", package: "PromptXKit"),
            ],
            path: "Sources/PromptXDiscovery",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "PromptX",
            dependencies: [
                "PromptXIPC",
                "PromptXDiscovery",
                .product(name: "PromptXKit", package: "PromptXKit"),
                .product(name: "PromptXChatUI", package: "PromptXKit"),
                .product(name: "PromptXProtocol", package: "PromptXKit"),
                .product(name: "SwabbleKit", package: "swabble"),
                .product(name: "MenuBarExtraAccess", package: "MenuBarExtraAccess"),
                .product(name: "Subprocess", package: "swift-subprocess"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Sparkle", package: "Sparkle"),
                .product(name: "PeekabooBridge", package: "Peekaboo"),
                .product(name: "PeekabooAutomationKit", package: "Peekaboo"),
            ],
            exclude: [
                "Resources/Info.plist",
            ],
            resources: [
                .copy("Resources/PromptX.icns"),
                .copy("Resources/DeviceModels"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .executableTarget(
            name: "PromptXMacCLI",
            dependencies: [
                "PromptXDiscovery",
                .product(name: "PromptXKit", package: "PromptXKit"),
                .product(name: "PromptXProtocol", package: "PromptXKit"),
            ],
            path: "Sources/PromptXMacCLI",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
            ]),
        .testTarget(
            name: "PromptXIPCTests",
            dependencies: [
                "PromptXIPC",
                "PromptX",
                "PromptXDiscovery",
                .product(name: "PromptXProtocol", package: "PromptXKit"),
                .product(name: "SwabbleKit", package: "swabble"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency"),
                .enableExperimentalFeature("SwiftTesting"),
            ]),
    ])
