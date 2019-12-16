// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Reqres",
    platforms: [
        .iOS(.v9),
        .macOS(.v10_12)
    ],
    products: [
        .library(name: "Reqres", targets: ["Reqres"]),
    ],
    targets: [
        .target(name: "Reqres", path: "Reqres")
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
