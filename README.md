# YoutubeEngine

Library with ReactiveCocoa api for Youtube. Allows easy access required parts of videos and channels in one call.

## Screenshots

![YoutubeEngine](https://raw.githubusercontent.com/Igor-Palaguta/YoutubeEngine/master/Screenshots/ScreenRecord.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift
let engine = Engine(authorization: .key(YOUR_API_KEY))
let request = SearchRequest(.term("VEVO", [.video: [.statistics, .contentDetails], .channel: [.statistics]]))
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
pod "YoutubeEngine", :git => 'https://github.com/Igor-Palaguta/YoutubeEngine'
```

Carthage
```ruby
github "Igor-Palaguta/YoutubeEngine"
```

SPM
```swift
.package(url: "https://github.com/Igor-Palaguta/YoutubeEngine", from: "0.5.0")
```

## Author

Igor Palaguta, igor.palaguta@gmail.com

## License

YoutubeEngine is available under the MIT license. See the LICENSE file for more info.
