// swift-tools-version:5.0
import PackageDescription

let package = Package(
   name: "YoutubeEngine",
   platforms: [
      .macOS(.v10_10), .iOS(.v8), .tvOS(.v9), .watchOS(.v2)
   ],
   products: [
      .library(name: "YoutubeEngine", targets: ["YoutubeEngine"]),
   ],
   dependencies: [
      .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
      .package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", from: "6.0.0"),
      .package(url: "https://github.com/Quick/Nimble.git", from: "8.0.0"),
      .package(url: "https://github.com/Quick/Quick.git", from: "2.0.0"),
      // stub and fixture functions don't work
      // .package(url: "https://github.com/AliSoftware/OHHTTPStubs.git", from: "9.0.0")
   ],
   targets: [
      .target(name: "YoutubeEngine", dependencies: ["SwiftyJSON", "ReactiveSwift"], path: "Source"),
      .testTarget(name: "YoutubeEngineTests",
                  dependencies: [
                     "YoutubeEngine",
                     "Nimble",
                     "Quick",
                     // "OHHTTPStubsSwift"
                  ],
                  exclude: ["EngineSpec.swift"]
      )
   ],
   swiftLanguageVersions: [.v5]
)
