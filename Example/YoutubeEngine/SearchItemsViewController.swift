import UIKit
import YoutubeEngine
import ReactiveCocoa
import Reusable
import enum Result.NoError

final class SearchItemsViewController: UITableViewController {

   @IBOutlet private var searchBar: UISearchBar!

   let model = MutableItemsViewModel<SearchItem>()

   override func viewDidLoad() {
      super.viewDidLoad()

      self.tableView.keyboardDismissMode = .OnDrag

      self.model
         .provider
         .producer
         .flatMap(.Latest) {
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
         .provider
         .producer
         .flatMap(.Latest) {
            provider -> SignalProducer<[SearchItem], NoError> in
            guard let provider = provider else {
               return SignalProducer(value: [])
            }

            return provider.items.producer
         }
         .startWithNext {
            [weak self] _ in
            self?.tableView.reloadData()
      }
   }

   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.model.items.count
   }

   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let item = self.model.items[indexPath.row]
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

      provider.pageLoader?.startWithFailed {
         [weak self] error in
         self?.presentError(error)
      }
   }

   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      guard let controller = segue.destinationViewController as? SearchItemsViewController,
         let cell = sender as? ChannelCell,
         let channel = cell.channel else {
            return
      }
      controller.title = channel.snippet!.title
      controller.model.mutableProvider.value = AnyItemsProvider { token, limit in
         let request = Search(.FromChannel(channel.id, [.Statistics, .ContentDetails]),
                              limit: limit,
                              pageToken: token)
         return Engine.defaultEngine
            .search(request)
            .map { page in (page.items, page.nextPageToken) }
      }
   }

   private func presentError(error: NSError) {
      let alert = UIAlertController(title: "Request failed",
                                    message: error.localizedDescription,
                                    preferredStyle: .Alert)
      alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
      self.presentViewController(alert,
                                 animated: true,
                                 completion: nil)
   }
}
