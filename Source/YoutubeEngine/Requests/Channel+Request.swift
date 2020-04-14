import Foundation

extension Channel: PartibleObject, SearchableObject {
    func merged(with other: Channel) -> Channel {
        return Channel(id: id,
                       snippet: snippet ?? other.snippet,
                       statistics: statistics ?? other.statistics)
    }

    static func request(withRequiredParts requiredParts: [Part],
                        for objects: [Channel]) -> AnyPageRequest<Channel> {
        return AnyPageRequest(ChannelRequest(.byIDs(objects.map { $0.id }), requiredParts: requiredParts))
    }

    var searchItemType: ContentType {
        return .channel
    }
}
