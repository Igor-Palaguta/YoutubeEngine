import Foundation
import ReactiveCocoa
import YoutubeEngine
import enum Result.NoError

final class SearchViewModel {
   let provider: AnyProperty<SearchProvider?>
   let keyword = MutableProperty("")

   let items: AnyProperty<[SearchItem]>

   init(engine: Engine) {
      self.provider = AnyProperty(
         initialValue: nil,
         signal: self.keyword.signal
            .debounce(0.5, onScheduler: QueueScheduler.mainQueueScheduler)
            .map { $0.isEmpty ? nil : SearchProvider(keyword: $0, engine: engine) })

      self.items = AnyProperty(
         initialValue: [],
         producer: self.provider.producer.flatMap(.Latest) {
            provider -> SignalProducer<[SearchItem], NoError> in
            guard let provider = provider else {
               return SignalProducer(value: [])
            }

            return provider.items.producer
         })
   }
}
