// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Validations",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Validations",
            targets: ["Validations"]),
    ],
    dependencies: [
        .package(name: "Validated", url: "git@github.com:pointfreeco/swift-validated.git", from: "0.2.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Validations",
            dependencies: ["Validated"]),
        .testTarget(
            name: "ValidationsTests",
            dependencies: ["Validations"]),
    ]
)
