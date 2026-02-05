// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "generate-merchants",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/danini-the-panini/kdl-swift.git", from: "2.0.0")
    ],
    targets: [
        .executableTarget(
            name: "generate-merchants",
            dependencies: [
                .product(name: "KDL", package: "kdl-swift")
            ]
        )
    ]
)
