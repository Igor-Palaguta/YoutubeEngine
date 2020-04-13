import Foundation

extension Channel: PartibleObject, SearchableObject {
    func merged(with other: Channel) -> Channel {
        return Channel(id: id,
                       snippet: snippet ?? other.snippet,
                       statistics: statistics ?? other.statistics)
    }

    static func request(for parts: [Part], objects: [Channel]) -> AnyPageRequest<Channel> {
        return AnyPageRequest(ChannelRequest(.byIds(objects.map { $0.id }), parts: parts))
    }

    var searchItemType: ContentType {
        return .channel
    }
}
