import PackageDescription

let package = Package(
    name: "YoutubeEngine",
    dependencies: [
        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", versions: Version(3,0,0)...Version(3,1,3)),
        .Package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", majorVersion: 1)
    ]
)
