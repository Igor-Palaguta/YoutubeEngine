import Foundation

protocol PartibleObject {
    static func request(withRequiredParts requiredParts: [Part],
                        for objects: [Self]) -> AnyPageRequest<Self>

    func merged(with other: Self) -> Self
}

protocol SearchableObject {
    var id: String { get }
    var searchItemType: ContentType { get }
}
