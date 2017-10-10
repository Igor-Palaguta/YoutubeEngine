import PackageDescription

let package = Package(
   name: "YoutubeEngine",
   dependencies: [
      .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", "3.1.4"),
      .Package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", majorVersion: 2)
   ]
   //OHHTTPStubs does not support SPM
   //exclude: ["Tests/YoutubeEngineTests/EngineSpec.swift", "Tests/YoutubeEngineTests/Responses"]
)
