import ReactiveSwift
import UIKit
import YoutubeEngine

extension Engine {
    static let defaultEngine = Engine(
        authorization: .key("AIzaSyBjLH-61v1oTcb_wQUcGAYIHmWSCj19Ss4"),
        isLogEnabled: true
    )
}

final class YoutubeViewModel {
    let keyword = MutableProperty("")
}

final class YoutubeViewController: UIViewController {

    @IBOutlet private var searchBar: UISearchBar!

    private let model = YoutubeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.titleView = searchBar
        automaticallyAdjustsScrollViewInsets = false
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let contentController = segue.destination as? SearchItemsViewController else {
            return
        }
        contentController.model.mutableProvider <~ model.keyword.signal
            .debounce(0.5, on: QueueScheduler.main)
            .map { keyword -> AnyItemsProvider<SearchItem>? in
                if keyword.isEmpty {
                    return nil
                }
                return AnyItemsProvider { token, limit in
                    let request = SearchRequest(
                        .term(keyword, [.video: [.statistics, .contentDetails], .channel: [.statistics]]),
                        limit: limit,
                        pageToken: token
                    )
                    return Engine.defaultEngine
                        .search(request)
                        .map { page in (page.items, page.nextPageToken) }
                }
            }
    }
}

extension YoutubeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        model.keyword.value = searchText
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
