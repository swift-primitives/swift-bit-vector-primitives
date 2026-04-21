// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-bit-vector-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        // MARK: - Core
        .library(
            name: "Bit Vector Primitives Core",
            targets: ["Bit Vector Primitives Core"]
        ),
        // MARK: - Variants
        .library(
            name: "Bit Vector Static Primitives",
            targets: ["Bit Vector Static Primitives"]
        ),
        .library(
            name: "Bit Vector Bounded Primitives",
            targets: ["Bit Vector Bounded Primitives"]
        ),
        .library(
            name: "Bit Vector Inline Primitives",
            targets: ["Bit Vector Inline Primitives"]
        ),
        .library(
            name: "Bit Vector Dynamic Primitives",
            targets: ["Bit Vector Dynamic Primitives"]
        ),
        // MARK: - Umbrella
        .library(
            name: "Bit Vector Primitives",
            targets: ["Bit Vector Primitives"]
        ),
        // MARK: - Test Support
        .library(
            name: "Bit Vector Primitives Test Support",
            targets: ["Bit Vector Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-bit-primitives"),
        .package(path: "../swift-bit-pack-primitives"),
        .package(path: "../swift-property-primitives"),
        .package(path: "../swift-sequence-primitives"),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "Bit Vector Primitives Core",
            dependencies: [
                .product(name: "Bit Primitives", package: "swift-bit-primitives"),
                .product(name: "Bit Pack Primitives", package: "swift-bit-pack-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
            ]
        ),

        // MARK: - Variants
        .target(
            name: "Bit Vector Static Primitives",
            dependencies: [
                "Bit Vector Primitives Core",
            ]
        ),
        .target(
            name: "Bit Vector Bounded Primitives",
            dependencies: [
                "Bit Vector Primitives Core",
            ]
        ),
        .target(
            name: "Bit Vector Inline Primitives",
            dependencies: [
                "Bit Vector Primitives Core",
            ]
        ),
        .target(
            name: "Bit Vector Dynamic Primitives",
            dependencies: [
                "Bit Vector Primitives Core",
                "Bit Vector Bounded Primitives",
                "Bit Vector Inline Primitives",
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Bit Vector Primitives",
            dependencies: [
                "Bit Vector Primitives Core",
                "Bit Vector Static Primitives",
                "Bit Vector Bounded Primitives",
                "Bit Vector Inline Primitives",
                "Bit Vector Dynamic Primitives",
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Bit Vector Primitives Test Support",
            dependencies: [
                "Bit Vector Primitives",
                .product(name: "Bit Pack Primitives Test Support", package: "swift-bit-pack-primitives"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Bit Vector Primitives Tests",
            dependencies: [
                "Bit Vector Primitives",
                "Bit Vector Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
