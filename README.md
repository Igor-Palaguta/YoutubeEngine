# YoutubeEngine

Library with ReactiveCocoa api for Youtube. Allows easy access required parts of videos and channels in one call.

## Screenshots

![YoutubeEngine](https://raw.githubusercontent.com/Igor-Palaguta/YoutubeEngine/master/Screenshots/ScreenRecord.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```
let engine = Engine(.key(YOUR_API_KEY))
let request = Search(.term("VEVO", [.video: [.statistics, .contentDetails], .channel: [.statistics]]))
engine.search(request)
   .startWithResult {
      result in
      guard case .success(let page) = result else {
         return
      }
      let formattedItems = page.items.enumerated().map { "[\($0)] = \($1)" }
      print("VEVO:\n\(formattedItems.joined(separator: "\n"))")
}
```

## Requirements

Supports swift2 and swift3. Use 'swift-2.3' branch for swift2

## Installation

Cocoapods
```ruby
pod "YoutubeEngine"
```

Carthage
```
github "Igor-Palaguta/YoutubeEngine"
```

## Author

Igor Palaguta, igor.palaguta@gmail.com

## License

YoutubeEngine is available under the MIT license. See the LICENSE file for more info.
