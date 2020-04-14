// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "YoutubeEngine",
    platforms: [
        .macOS(.v10_12), .iOS(.v10), .tvOS(.v10), .watchOS(.v3)
    ],
    products: [
        .library(name: "YoutubeEngine", targets: ["YoutubeEngine"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "6.0.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0")
        // stub and fixture functions don't work
        // .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.0.0")
    ],
    targets: [
        .target(name: "YoutubeEngine", dependencies: ["ReactiveSwift"], path: "Source"),
        .testTarget(name: "YoutubeEngineTests",
                    dependencies: [
                        "YoutubeEngine",
                        "Nimble"
                        // "OHHTTPStubsSwift"
                    ],
                    exclude: ["EngineTests.swift"])
    ],
    swiftLanguageVersions: [.v5]
)
