// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ATSFrameworkSwiftui",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "CoreUtilities", targets: ["CoreUtilities"]),
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "Navigation", targets: ["Navigation"]),
        .library(name: "Storage", targets: ["Storage"]),
        .library(name: "UIComponents", targets: ["UIComponents"]),
        // Umbrella product — import everything at once.
        .library(
            name: "ATSFrameworkSwiftui",
            targets: ["CoreUtilities", "Networking", "Navigation", "Storage", "UIComponents"]
        )
    ],
    targets: [
        .target(name: "CoreUtilities"),
        .target(name: "Networking", dependencies: ["CoreUtilities"]),
        .target(name: "Navigation", dependencies: ["CoreUtilities"]),
        .target(name: "Storage", dependencies: ["CoreUtilities"]),
        .target(name: "UIComponents", dependencies: ["CoreUtilities"])
    ],
    swiftLanguageModes: [.v6]
)
