import UIKit
import YoutubeEngine

class ViewController: UIViewController {

   private lazy var engine = Engine(key: "AIzaSyCgwWIve2NhQOb5IHMdXxDaRHOnDrLdrLg")

   override func viewDidLoad() {
      super.viewDidLoad()

      self.engine.search(.Search(query: "VEVO", types: [.Video, .Channel], pageToken: nil), parts: [.Statistics, .ContentDetails])
         .startWithNext {
            page in
            let formattedItems = page.items.enumerate().map { "[\($0)] = \($1)" }
            print("VEVO:\n\(formattedItems.joinWithSeparator("\n"))")
      }
   }
}

