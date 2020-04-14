import Foundation

extension Video: PartibleObject, SearchableObject {
    static func request(withRequiredParts requiredParts: [Part],
                        for objects: [Video]) -> AnyPageRequest<Video> {
        return AnyPageRequest(VideoRequest(.byIDs(objects.map { $0.id }), requiredParts: requiredParts))
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
