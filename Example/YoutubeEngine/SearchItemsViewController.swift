import UIKit
import YoutubeEngine
import ReactiveSwift
import enum Result.NoError

final class SearchItemsViewController: UITableViewController {

   @IBOutlet private var searchBar: UISearchBar!

   let model = MutableItemsViewModel<SearchItem>()

   override func viewDidLoad() {
      super.viewDidLoad()

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
         .provider
         .producer.flatMap(.latest) {
            provider -> SignalProducer<[SearchItem], NoError> in
            guard let provider = provider else {
               return SignalProducer(value: [])
            }

            return provider.items.producer
         }
         .startWithValues {
            [weak self] _ in
            self?.tableView.reloadData()
      }
   }

   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.model.items.count
   }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let item = self.model.items[indexPath.row]
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

   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      guard let controller = segue.destination as? SearchItemsViewController,
         let cell = sender as? ChannelCell,
         let channel = cell.channel else {
            return
      }
      controller.title = channel.snippet!.title
      controller.model.mutableProvider.value = AnyItemsProvider { token, limit in
         let request = Search(.fromChannel(channel.id, [.statistics, .contentDetails]),
                              limit: limit,
                              pageToken: token)
         return Engine.defaultEngine
            .search(request)
            .map { page in (page.items, page.nextPageToken) }
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
