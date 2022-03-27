// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "UdpConnection",
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        .library(
            name: "UdpConnection",
            targets: ["UdpConnection"]),
    ],
    dependencies: [

    ],
    targets: [
        .target(
            name: "UdpConnection",
            dependencies: []),
        .testTarget(
            name: "UdpConnectionTests",
            dependencies: ["UdpConnection"]),
    ]
)
