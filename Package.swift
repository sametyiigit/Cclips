// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Cclips",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Cclips", targets: ["Cclips"])
    ],
    targets: [
        .executableTarget(
            name: "Cclips"
        ),
        .testTarget(
            name: "CclipsTests",
            dependencies: ["Cclips"]
        ),
    ]
)
