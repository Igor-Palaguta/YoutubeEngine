import Foundation

protocol PartibleObject {
    static func request(for parts: [Part], objects: [Self]) -> AnyPageRequest<Self>

    func merged(with other: Self) -> Self
}

protocol SearchableObject {
    var id: String { get }
    var searchItemType: ContentType { get }
}
