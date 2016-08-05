import Foundation
import Alamofire

protocol PartibleObject {
   func mergeParts(other: Self) -> Self
   static func requestForParts(parts: [Part], objects: [Self]) -> AnyPageRequest<Self>
}

protocol SearchableObject {
   var id: String { get }
   var searchItemType: Type { get }
   func toSearchItem() -> SearchItem
   static func fromSearchItem(item: SearchItem) -> Self?
}
