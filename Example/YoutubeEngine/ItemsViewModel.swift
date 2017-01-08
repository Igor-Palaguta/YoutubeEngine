import Foundation
import ReactiveSwift

protocol ItemsViewModel {
   associatedtype Item
   var provider: Property<AnyItemsProvider<Item>?> { get }
}

extension ItemsViewModel {
   var items: [Item] {
      return self.provider.value?.items.value ?? []
   }
}

final class MutableItemsViewModel<Item>: ItemsViewModel {
   let provider: Property<AnyItemsProvider<Item>?>
   let mutableProvider: MutableProperty<AnyItemsProvider<Item>?>

   init() {
      self.mutableProvider = MutableProperty(nil)
      self.provider = Property(self.mutableProvider)
   }
}
