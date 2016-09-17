import Foundation
import ReactiveSwift
import YoutubeEngine
import enum Result.NoError

final class SearchViewModel {
   let provider: Property<SearchProvider?>
   let keyword = MutableProperty("")

   let items: Property<[SearchItem]>

   init(engine: Engine) {
      self.provider = Property(
         initial: nil,
         then: self.keyword.signal
            .debounce(0.5, on: QueueScheduler.main)
            .map { $0.isEmpty ? nil : SearchProvider(keyword: $0, engine: engine) })

      self.items = Property(
         initial: [],
         then: self.provider.producer.flatMap(.latest) {
            provider -> SignalProducer<[SearchItem], NoError> in
            guard let provider = provider else {
               return SignalProducer(value: [])
            }

            return provider.items.producer
      })
   }
}
