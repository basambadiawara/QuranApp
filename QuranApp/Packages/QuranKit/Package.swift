// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "QuranKit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(name: "QuranKit", targets: ["QuranKit"]),
        .library(name: "QuranCore", targets: ["QuranCore"]),
        .library(name: "QuranUI", targets: ["QuranUI"])
    ],
    dependencies: [
        .package(url: "https://github.com/basambadiawara/PageView.git", branch: "main"),
        .package(url: "https://github.com/basambadiawara/FontLoader.git", exact: "0.1.2")
    ],
    targets: [
        .target(
            name: "QuranCore",
            path: "Sources/QuranCore",
            resources: [.process("Resources")]
        ),
        .target(
            name: "QuranUI",
            dependencies: [
                "QuranCore",
                .product(name: "PageView", package: "PageView"),
                .product(name: "FontLoader", package: "FontLoader")
            ],
            path: "Sources/QuranUI",
            resources: [.process("Resources")]
        ),
        .target(
            name: "QuranKit",
            dependencies: ["QuranCore", "QuranUI"],
            path: "Sources/QuranKit"
        )
    ]
)
