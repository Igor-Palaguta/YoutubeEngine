import Foundation

protocol PartibleObject {
   func merge(with other: Self) -> Self
   static func request(for parts: [Part], objects: [Self]) -> AnyPageRequest<Self>
}

protocol SearchableObject {
   var id: String { get }
   var searchItemType: Type { get }
}
