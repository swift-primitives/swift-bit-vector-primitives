// swift-tools-version: 6.2

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
        .library(
            name: "Bit Vector Primitives",
            targets: ["Bit Vector Primitives"]
        ),
        .library(
            name: "Bit Vector Primitives Test Support",
            targets: ["Bit Vector Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-bit-primitives"),
        .package(path: "../swift-bit-pack-primitives"),
        .package(path: "../swift-property-primitives"),
        .package(path: "../swift-vector-primitives"),
        .package(path: "../swift-sequence-primitives"),
    ],
    targets: [
        .target(
            name: "Bit Vector Primitives",
            dependencies: [
                .product(name: "Bit Primitives", package: "swift-bit-primitives"),
                .product(name: "Bit Pack Primitives", package: "swift-bit-pack-primitives"),
                .product(name: "Property Primitives", package: "swift-property-primitives"),
                .product(name: "Vector Primitives", package: "swift-vector-primitives"),
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
            ]
        ),
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
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
