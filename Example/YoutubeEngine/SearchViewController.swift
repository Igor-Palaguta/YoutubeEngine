import UIKit
import YoutubeEngine
import ReactiveSwift
import enum Result.NoError

final class SearchViewController: UITableViewController {

   @IBOutlet private var searchBar: UISearchBar!

   fileprivate lazy var model: SearchViewModel = {
      //Generate your own https://developers.google.com/youtube/v3/getting-started
      let engine = Engine(.key("AIzaSyCgwWIve2NhQOb5IHMdXxDaRHOnDrLdrLg"))
      engine.logEnabled = true
      return SearchViewModel(engine: engine)
   }()

   override func viewDidLoad() {
      super.viewDidLoad()

      self.navigationItem.titleView = self.searchBar

      self.tableView.keyboardDismissMode = .onDrag

      self.model
         .provider
         .producer
         .flatMap(.latest) {
            provider -> SignalProducer<Void, NoError> in
            if let pageLoader = provider?.pageLoader {
               return pageLoader
                  .on(failed: {
                     [weak self] error in
                     self?.presentError(error)
                     })
                  .flatMapError { _ in .empty }
            }
            return .empty
         }
         .startWithCompleted {}

      self.model
         .items
         .producer
         .startWithValues {
            [weak self] _ in
            self?.tableView.reloadData()
      }
   }

   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.model.items.value.count
   }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let item = self.model.items.value[indexPath.row]
      switch item {
      case .channelItem(let channel):
         let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelCell
         cell.channel = channel
         return cell
      case .videoItem(let video):
         let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
         cell.video = video
         return cell
      }
   }

   override func scrollViewDidScroll(_ scrollView: UIScrollView) {
      guard let provider = self.model.provider.value, !provider.items.value.isEmpty && !provider.isLoadingPage else {
         return
      }

      let lastCellIndexPath = IndexPath(row: provider.items.value.count - 1, section: 0)
      if tableView.cellForRow(at: lastCellIndexPath) == nil {
         return
      }

      provider.pageLoader?.startWithFailed {
         [weak self] error in
         self?.presentError(error)
      }
   }

   private func presentError(_ error: NSError) {
      let alert = UIAlertController(title: "Request failed",
                                    message: error.localizedDescription,
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      self.present(alert, animated: true, completion: nil)
   }
}

extension SearchViewController: UISearchBarDelegate {
   func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      self.model.keyword.value = searchText
   }

   func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      searchBar.resignFirstResponder()
   }
}
