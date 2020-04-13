import Foundation

extension Video: PartibleObject, SearchableObject {
    static func request(for parts: [Part], objects: [Video]) -> AnyPageRequest<Video> {
        return AnyPageRequest(VideoRequest(.byIds(objects.map { $0.id }), parts: parts))
    }

    var searchItemType: ContentType {
        return .video
    }

    func merged(with other: Video) -> Video {
        return Video(id: id,
                     snippet: snippet ?? other.snippet,
                     statistics: statistics ?? other.statistics,
                     contentDetails: contentDetails ?? other.contentDetails)
    }
}
