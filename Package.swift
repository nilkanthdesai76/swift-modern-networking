// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ModernNetworking",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "ModernNetworking",
            targets: ["ModernNetworking"]
        )
    ],
    targets: [
        .target(
            name: "ModernNetworking",
            dependencies: []
        ),
        .testTarget(
            name: "ModernNetworkingTests",
            dependencies: ["ModernNetworking"]
        )
    ]
)
