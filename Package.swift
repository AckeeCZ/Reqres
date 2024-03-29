// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Reqres",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_12)
    ],
    products: [
        .library(name: "Reqres", targets: ["Reqres"]),
    ],
    targets: [
        .target(name: "Reqres"),
        .testTarget(
            name: "ReqresTests",
            dependencies: ["Reqres"]
        )
    ]
)
