// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacWidget",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "macwidget", targets: ["MacWidget"])
    ],
    targets: [
        .target(name: "WidgetKitShared"),
        .target(
            name: "CPUWidget",
            dependencies: ["WidgetKitShared"]
        ),
        .target(
            name: "DummyWidget",
            dependencies: ["WidgetKitShared"]
        ),
        .executableTarget(
            name: "MacWidget",
            dependencies: ["WidgetKitShared", "CPUWidget", "DummyWidget"]
        )
    ]
)
