import UIKit
import YoutubeEngine

class ViewController: UIViewController {

   private lazy var engine = Engine(key: "AIzaSyCgwWIve2NhQOb5IHMdXxDaRHOnDrLdrLg")

   override func viewDidLoad() {
      super.viewDidLoad()

      self.engine.logEnabled = true

      let request = Search(.Term("VEVO", [.Video: [.Statistics, .ContentDetails], .Channel: [.Statistics]]))
      self.engine.search(request)
         .startWithNext {
            page in
            let formattedItems = page.items.enumerate().map { "[\($0)] = \($1)" }
            print("VEVO (total: \(page.totalCount)):\n\(formattedItems.joinWithSeparator("\n"))")
      }

      self.engine.videos(Videos(.Popular, parts: [.Statistics], limit: 10))
         .startWithNext {
            page in
            let formattedItems = page.items.enumerate().map { "[\($0)] = \($1)" }
            print("Popular Videos (total: \(page.totalCount)):\n\(formattedItems.joinWithSeparator("\n"))")
      }
   }
}
