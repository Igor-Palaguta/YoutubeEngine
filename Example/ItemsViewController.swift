import ReactiveSwift
import UIKit
import YoutubeEngine

final class ItemsViewController: UITableViewController {

    @IBOutlet private var searchBar: UISearchBar!

    let model = MutableItemsViewModel<DisplayItem>()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag

        model
            .provider
            .producer
            .flatMap(.latest) { provider -> SignalProducer<Void, Never> in
                if let pageLoader = provider?.pageLoader {
                    return pageLoader
                        .on(failed: { [weak self] error in
                            self?.presentError(error)
                        })
                        .flatMapError { _ in .empty }
                }
                return .empty
            }
            .startWithCompleted {}

        model
            .provider
            .producer.flatMap(.latest) { provider -> SignalProducer<[DisplayItem], Never> in
                guard let provider = provider else {
                    return SignalProducer(value: [])
                }

                return provider.items.producer
            }
            .startWithValues { [weak self] _ in
                self?.tableView.reloadData()
            }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model.items[indexPath.row]
        switch item {
        case .channel(let channel):
            // swiftlint:disable:next force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelCell
            cell.channel = channel
            return cell
        case .video(let video):
            // swiftlint:disable:next force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoCell
            cell.video = video
            return cell
        case .playlist(let playlist):
            // swiftlint:disable:next force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell", for: indexPath) as! PlaylistCell
            cell.playlist = playlist
            return cell
        case .playlistItem(let playlistItem):
            // swiftlint:disable:next force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistItemCell", for: indexPath) as! PlaylistItemCell
            cell.playlistItem = playlistItem
            return cell
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let provider = model.provider.value, !provider.items.value.isEmpty && !provider.isLoadingPage else {
            return
        }

        let lastCellIndexPath = IndexPath(row: provider.items.value.count - 1, section: 0)
        if tableView.cellForRow(at: lastCellIndexPath) == nil {
            return
        }

        provider.pageLoader?.startWithFailed { [weak self] error in
            self?.presentError(error)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationController = segue.destination as? ItemsViewController else {
            return
        }

        if let cell = sender as? ChannelCell, let channel = cell.channel {
            // swiftlint:disable:next force_unwrapping
            destinationController.title = channel.snippet!.title
            destinationController.model.mutableProvider.value = AnyItemsProvider { token, limit in
                let request: SearchRequest = .videosFromChannel(withID: channel.id,
                                                                requiredParts: [.statistics, .contentDetails],
                                                                limit: limit,
                                                                pageToken: token)
                return Engine.defaultEngine
                    .search(request)
                    .map { page in (page.items.map { $0.displayItem }, page.nextPageToken) }
            }
        } else if let cell = sender as? PlaylistCell, let playlist = cell.playlist {
            // swiftlint:disable:next force_unwrapping
            destinationController.title = playlist.snippet!.title
            destinationController.model.mutableProvider.value = AnyItemsProvider { token, limit in
                let request: PlaylistItemRequest = .itemsFromPlaylist(withID: playlist.id,
                                                                      requiredParts: [.snippet],
                                                                      limit: limit,
                                                                      pageToken: token)
                return Engine.defaultEngine
                    .playlistItems(request)
                    .map { page in (page.items.map { .playlistItem($0) }, page.nextPageToken) }
            }
        }
    }

    private func presentError(_ error: NSError) {
        let alert = UIAlertController(title: "Request failed",
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
