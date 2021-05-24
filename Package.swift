// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "GAppAuth",
    platforms: [
        .macOS(.v10_11),
        .iOS(.v11)
    ],
    products: [
        .library(name: "GAppAuth-iOS", targets: ["GAppAuth-iOS"]),
        .library(name: "GAppAuth-macOS", targets: ["GAppAuth-macOS"])
    ],
    dependencies: [
        .package(url: "https://github.com/google/GTMAppAuth.git", from: "1.0.0"),
        .package(url: "https://github.com/openid/AppAuth-iOS.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "GAppAuth-iOS", dependencies: ["GTMAppAuth", "AppAuth"], path: "Sources/iOS"),
        .target(name: "GAppAuth-macOS", dependencies: ["GTMAppAuth", "AppAuth"], path: "Sources/macOS")
    ]
)
