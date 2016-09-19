import Foundation
import ReactiveCocoa
import YoutubeEngine

protocol ItemsProviders {
   associatedtype Item
   var items: AnyProperty<[Item]> { get }
   var isLoadingPage: Bool { get }
   var pageLoader: SignalProducer<Void, NSError>? { get }
}

final class AnyItemsProvider<Item>: ItemsProviders {
   let items: AnyProperty<[Item]>
   private(set) var isLoadingPage = false

   typealias PageLoader = (pageToken: String?, limit: Int) -> SignalProducer<([Item], String?), NSError>
   private let _pageLoader: PageLoader
   private var nextPageToken: String?
   private let mutableItems = MutableProperty<[Item]?>(nil)

   init(pageLoader: PageLoader) {
      self._pageLoader = pageLoader
      self.items = self.mutableItems.map { $0 ?? [] }
   }

   var pageLoader: SignalProducer<Void, NSError>? {
      if self.isLoadingPage {
         return nil
      }

      //Nothing for this keyword
      if self.mutableItems.value != nil && nextPageToken == nil {
         return nil
      }

      return self._pageLoader(pageToken: self.nextPageToken, limit: 20)
         .on(next: {
            items, token in
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
         })
   }
}
