import Foundation
import ReactiveCocoa

protocol ItemsViewModel {
   associatedtype Item
   var provider: AnyProperty<AnyItemsProvider<Item>?> { get }
}

extension ItemsViewModel {
   var items: [Item] {
      return self.provider.value?.items.value ?? []
   }
}

final class MutableItemsViewModel<Item>: ItemsViewModel {
   let provider: AnyProperty<AnyItemsProvider<Item>?>
   let mutableProvider: MutableProperty<AnyItemsProvider<Item>?>

   init() {
      self.mutableProvider = MutableProperty(nil)
      self.provider = AnyProperty(self.mutableProvider)
   }
}
