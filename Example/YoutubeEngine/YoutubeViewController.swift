import UIKit
import YoutubeEngine
import ReactiveCocoa

private let _defaultEngine: Engine = {
   let engine = Engine(.Key("AIzaSyCgwWIve2NhQOb5IHMdXxDaRHOnDrLdrLg"))
   engine.logEnabled = true
   return engine
}()

extension Engine {
   static var defaultEngine: Engine {
      return _defaultEngine
   }
}

final class YoutubeViewModel {
   let keyword = MutableProperty("")
}

final class YoutubeViewController: UIViewController {

   @IBOutlet private weak var searchBar: UISearchBar!

   private let model = YoutubeViewModel()

   override func viewDidLoad() {
      super.viewDidLoad()

      self.navigationItem.titleView = self.searchBar
      self.automaticallyAdjustsScrollViewInsets = false
   }

   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      guard let contentController = segue.destinationViewController as? SearchItemsViewController else {
         return
      }
      contentController.model.mutableProvider <~ self.model.keyword.signal
         .debounce(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
         .map { keyword in
            if keyword.isEmpty {
               return nil
            }
            return AnyItemsProvider { token, limit in
               let request = Search(.Term(keyword, [.Video: [.Statistics, .ContentDetails], .Channel: [.Statistics]]),
                                    limit: limit,
                                    pageToken: token)
               return Engine.defaultEngine
                  .search(request)
                  .map { page in (page.items, page.nextPageToken) }
            }
      }
   }
}

extension YoutubeViewController: UISearchBarDelegate {
   func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
      self.model.keyword.value = searchText
   }

   func searchBarSearchButtonClicked(searchBar: UISearchBar) {
      searchBar.resignFirstResponder()
   }
}
