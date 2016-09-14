import UIKit
import YoutubeEngine
import ReactiveCocoa
import Reusable
import enum Result.NoError

final class SearchViewController: UITableViewController {

   @IBOutlet private var searchBar: UISearchBar!

   private let model = SearchViewModel(engine: Engine(.Key("AIzaSyCgwWIve2NhQOb5IHMdXxDaRHOnDrLdrLg")))

   override func viewDidLoad() {
      super.viewDidLoad()

      self.navigationItem.titleView = self.searchBar

      self.tableView.keyboardDismissMode = .OnDrag

      self.model
         .provider
         .producer
         .flatMap(.Latest) {
            provider -> SignalProducer<Void, NoError> in
            if let pageLoader = provider?.pageLoader {
               return pageLoader.flatMapError { _ in .empty }
            }
            return .empty
         }
         .startWithCompleted {}

      self.model
         .items
         .producer
         .startWithNext {
            [weak self] _ in
            self?.tableView.reloadData()
      }
   }

   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.model.items.value.count
   }

   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let item = self.model.items.value[indexPath.row]
      switch item {
      case .ChannelItem(let channel):
         let cell: ChannelCell = tableView.dequeueReusableCell(indexPath: indexPath)
         cell.channel = channel
         return cell
      case .VideoItem(let video):
         let cell: VideoCell = tableView.dequeueReusableCell(indexPath: indexPath)
         cell.video = video
         return cell
      }
   }

   override func scrollViewDidScroll(scrollView: UIScrollView) {
      guard let provider = self.model.provider.value where !provider.items.value.isEmpty && !provider.isLoadingPage else {
         return
      }

      let lastCellIndexPath = NSIndexPath(forRow: provider.items.value.count - 1, inSection: 0)
      if tableView.cellForRowAtIndexPath(lastCellIndexPath) == nil {
         return
      }

      provider.pageLoader?.startWithCompleted {}
   }
}

extension SearchViewController: UISearchBarDelegate {
   func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
      self.model.keyword.value = searchText
   }

   func searchBarSearchButtonClicked(searchBar: UISearchBar) {
      searchBar.resignFirstResponder()
   }
}
