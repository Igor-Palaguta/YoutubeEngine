import Foundation
import ReactiveCocoa
import YoutubeEngine

final class SearchProvider {

   let items: AnyProperty<[SearchItem]>
   private(set) var isLoadingPage = false

   private var nextPageToken: String?
   private let mutableItems = MutableProperty<[SearchItem]?>(nil)
   private let keyword: String
   private let engine: Engine

   init(keyword: String, engine: Engine) {
      self.keyword = keyword
      self.engine = engine
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

      let request = Search(.Term(self.keyword, [.Video: [.Statistics, .ContentDetails], .Channel: [.Statistics]]),
                           limit: 20,
                           pageToken: self.nextPageToken)
      return self.engine
         .search(request)
         .on(next: {
            page in
            self.nextPageToken = page.nextPageToken
            self.mutableItems.value = self.items.value + page.items
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
