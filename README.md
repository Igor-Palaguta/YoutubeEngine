# YoutubeEngine

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

## Installation

YoutubeEngine is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "YoutubeEngine", :git => "https://github.com/Igor-Palaguta/YoutubeEngine.git"
```

## Author

Igor Palaguta, igor.palaguta@gmail.com

## License

YoutubeEngine is available under the MIT license. See the LICENSE file for more info.
