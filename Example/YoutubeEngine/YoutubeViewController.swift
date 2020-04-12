import UIKit
import YoutubeEngine
import ReactiveSwift

extension Engine {
   static let defaultEngine: Engine = {
      let engine = Engine(.key("AIzaSyCgwWIve2NhQOb5IHMdXxDaRHOnDrLdrLg"))
      engine.logEnabled = true
      return engine
   }()
}

final class YoutubeViewModel {
   let keyword = MutableProperty("")
}

final class YoutubeViewController: UIViewController {

   @IBOutlet private weak var searchBar: UISearchBar!

   fileprivate let model = YoutubeViewModel()

   override func viewDidLoad() {
      super.viewDidLoad()

      self.navigationItem.titleView = self.searchBar
      self.automaticallyAdjustsScrollViewInsets = false
   }

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      guard let contentController = segue.destination as? SearchItemsViewController else {
         return
      }
      contentController.model.mutableProvider <~ self.model.keyword.signal
         .debounce(0.5, on: QueueScheduler.main)
         .map { keyword -> AnyItemsProvider<SearchItem>? in
            if keyword.isEmpty {
               return nil
            }
            return AnyItemsProvider { token, limit in
               let request = Search(.term(keyword, [.video: [.statistics, .contentDetails], .channel: [.statistics]]),
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
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      self.model.keyword.value = searchText
   }

   func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      searchBar.resignFirstResponder()
   }
}
