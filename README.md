# YoutubeEngine

Library with RAC4 api for Youtube. Allows easy access required parts of videos and channels in one call.

## Screenshots

![YoutubeEngine](https://raw.githubusercontent.com/Igor-Palaguta/YoutubeEngine/master/Screenshots/ScreenRecord.gif)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```
var engine = Engine(key: YOUR_API_KEY)
let request = Search(.Term("VEVO", [.Video: [.Statistics, .ContentDetails], .Channel: [.Statistics]]))
engine.search(request)
   .startWithNext {
      page in
      let formattedItems = page.items.enumerate().map { "[\($0)] = \($1)" }
      print("VEVO:\n\(formattedItems.joinWithSeparator("\n"))")
   }
```

## Requirements

Supports both swift2.3 and swift2.2

ReactiveCocoa 4.2 (was tested on 4.2, probably earlier will work too)

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
