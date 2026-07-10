// swift-tools-version: 6.3.3

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
        // MARK: - Base
        .library(
            name: "Bit Vector Storage Primitives",
            targets: ["Bit Vector Storage Primitives"]
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
        .package(url: "https://github.com/swift-primitives/swift-bit-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-bit-pack-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-index-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-property-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-sequence-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-iterator-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-affine-primitives.git", branch: "main"),
    ],
    targets: [
        // MARK: - Base
        // Owns `Bit.Vector` (extends upstream `Bit_Primitives.Bit`), its protocol,
        // ops, and the Ones/Zeros View+Sequence machinery. Replaces the dissolved
        // internal-only Core target (L1 core-dissolution sweep 2026-06-23).
        .target(
            name: "Bit Vector Storage Primitives",
            dependencies: [
                .product(name: "Bit Primitives", package: "swift-bit-primitives"),
                .product(name: "Bit Pack Primitives", package: "swift-bit-pack-primitives"),
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
                .product(name: "Iterable", package: "swift-iterator-primitives"),
                .product(name: "Iterator Primitive", package: "swift-iterator-primitives"),
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
            ]
        ),

        // MARK: - Variants
        .target(
            name: "Bit Vector Static Primitives",
            dependencies: [
                "Bit Vector Storage Primitives",
                .product(name: "Bit Primitives", package: "swift-bit-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
                .product(name: "Iterator Primitive", package: "swift-iterator-primitives"),
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
            ]
        ),
        .target(
            name: "Bit Vector Bounded Primitives",
            dependencies: [
                "Bit Vector Storage Primitives",
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
                .product(name: "Iterator Primitive", package: "swift-iterator-primitives"),
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
            ]
        ),
        .target(
            name: "Bit Vector Inline Primitives",
            dependencies: [
                "Bit Vector Storage Primitives",
                .product(name: "Index Primitives", package: "swift-index-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
                .product(name: "Iterator Primitive", package: "swift-iterator-primitives"),
                .product(name: "Iterator Chunk Primitives", package: "swift-iterator-primitives"),
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
            ]
        ),
        .target(
            name: "Bit Vector Dynamic Primitives",
            dependencies: [
                "Bit Vector Storage Primitives",
                "Bit Vector Bounded Primitives",
                "Bit Vector Inline Primitives",
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Affine Primitives", package: "swift-affine-primitives"),
            ]
        ),

        // MARK: - Umbrella
        .target(
            name: "Bit Vector Primitives",
            dependencies: [
                "Bit Vector Storage Primitives",
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
