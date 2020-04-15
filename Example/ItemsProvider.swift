import Foundation
import ReactiveSwift
import YoutubeEngine

protocol ItemsProviders {
    associatedtype Item

    var items: Property<[Item]> { get }
    var isLoadingPage: Bool { get }
    var pageLoader: SignalProducer<Void, NSError>? { get }
}

final class AnyItemsProvider<Item>: ItemsProviders {
    typealias PageLoader = (_ pageToken: String?, _ limit: Int) -> SignalProducer<([Item], String?), NSError>

    let items: Property<[Item]>
    private(set) var isLoadingPage = false

    private let _pageLoader: PageLoader
    private var nextPageToken: String?
    private let mutableItems = MutableProperty<[Item]?>(nil)

    init(pageLoader: @escaping PageLoader) {
        self._pageLoader = pageLoader
        self.items = mutableItems.map { $0 ?? [] }
    }

    var pageLoader: SignalProducer<Void, NSError>? {
        if isLoadingPage {
            return nil
        }

        // Nothing for this keyword
        if mutableItems.value != nil && nextPageToken == nil {
            return nil
        }

        return _pageLoader(nextPageToken, 20)
            .on(value: { items, token in
                self.nextPageToken = token
                self.mutableItems.value = self.items.value + items
            })
            .map { _ in () }
            .on(
                started: {
                    self.isLoadingPage = true
                },
                terminated: {
                    self.isLoadingPage = false
                }
            )
    }
}
