[![Build Status](https://travis-ci.org/Igor-Palaguta/YoutubeEngine.svg?branch=master)](https://travis-ci.org/Igor-Palaguta/YoutubeEngine)

# YoutubeEngine

Library with ReactiveCocoa api for Youtube. Allows easy access required parts of videos and channels in one call.

## Screenshots

![YoutubeEngine](https://raw.githubusercontent.com/Igor-Palaguta/YoutubeEngine/master/Screenshots/ScreenRecord.gif)

## Example

To run the example project, clone the repo, and run `carthage checkout`.

```swift
let engine = Engine(authorization: .key(YOUR_API_KEY))
let request: SearchRequest = .search(withTerm: "VEVO",
                                     requiredVideoParts: [.statistics, .contentDetails],
                                     requiredChannelParts: [.statistics],
                                     requiredPlaylistParts: [.snippet],
                                     limit: 20)

engine.search(request)
    .startWithResult { result in
        guard case .success(let page) = result else {
            return
        }
        let formattedItems = page.items.enumerated().map { "[\($0)] = \($1)" }
        print("VEVO:\n\(formattedItems.joined(separator: "\n"))")
    }
```

## Requirements

Supports Swift 5

## Installation

Cocoapods
```ruby
pod "YoutubeEngine", :git => 'https://github.com/Igor-Palaguta/YoutubeEngine', :tag => '0.7.0'
```

Carthage
```ruby
github "Igor-Palaguta/YoutubeEngine" ~> 0.7.0
```

SPM
```swift
.package(url: "https://github.com/Igor-Palaguta/YoutubeEngine", .upToNextMinor(from: "0.7.0"))
```

## Implemented API

1. [search list](https://developers.google.com/youtube/v3/docs/search/list) by keyword, videos from channel, related videos

1. [channels list](https://developers.google.com/youtube/v3/docs/channels/list) by identifiers or my

1. [videos list](https://developers.google.com/youtube/v3/docs/videos/list) by identifiers or popular

1. [playlistItems list](https://developers.google.com/youtube/v3/docs/playlistItems/list) by identifiers or from playlist

## Author

Igor Palaguta, igor.palaguta@gmail.com

## License

YoutubeEngine is available under the MIT license. See the LICENSE file for more info.
