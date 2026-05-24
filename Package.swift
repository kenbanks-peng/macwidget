// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacWidget",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "macwidget", targets: ["MacWidget"])
    ],
    targets: [
        .executableTarget(name: "MacWidget")
    ]
)

