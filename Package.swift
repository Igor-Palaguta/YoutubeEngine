import PackageDescription

let package = Package(
   name: "YoutubeEngine",
   dependencies: [
      .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", versions: Version(3,0,0)...Version(3,1,3)),
      .Package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", majorVersion: 1),
      //.Package(url: "https://github.com/Quick/Quick", majorVersion: 1),
      //.Package(url: "https://github.com/Quick/Nimble", majorVersion: 5, minor: 1),
   ],
   //OHHTTPStubs does not support SPM
   //exclude: ["Tests/YoutubeEngineTests/EngineSpec.swift", "Tests/YoutubeEngineTests/Responses"]
)
