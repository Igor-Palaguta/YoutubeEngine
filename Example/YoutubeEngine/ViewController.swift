import UIKit
import YoutubeEngine

class ViewController: UIViewController {

   override func viewDidLoad() {
      super.viewDidLoad()

      let engine = Engine(.Key("AIzaSyCgwWIve2NhQOb5IHMdXxDaRHOnDrLdrLg"))
      engine.logEnabled = true

      let request = Search(.Term("VEVO", [.Video: [.Statistics, .ContentDetails], .Channel: [.Statistics]]))
      engine.search(request)
         .startWithNext {
            page in
            let formattedItems = page.items.enumerate().map { "[\($0)] = \($1)" }
            print("VEVO (total: \(page.totalCount)):\n\(formattedItems.joinWithSeparator("\n"))")
      }

      engine.videos(Videos(.Popular, parts: [.Statistics], limit: 10))
         .startWithNext {
            page in
            let formattedItems = page.items.enumerate().map { "[\($0)] = \($1)" }
            print("Popular Videos (total: \(page.totalCount)):\n\(formattedItems.joinWithSeparator("\n"))")
      }
   }
}
