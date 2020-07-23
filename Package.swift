// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Validations",
    products: [
        .library(
            name: "Validations",
            targets: ["Validations"]),
    ],
    dependencies: [
        .package(name: "Validated", url: "https://github.com/pointfreeco/swift-validated.git", from: "0.2.1"),
        .package(name: "NonEmpty", url: "https://github.com/pointfreeco/swift-nonempty.git", from: "0.2.1")
    ],
    targets: [
        .target(
            name: "Validations",
            dependencies: ["Validated", "NonEmpty"]),
        .testTarget(
            name: "ValidationsTests",
            dependencies: ["Validations"]),
    ]
)
