import Foundation

public struct Videos {

    public enum Filter {
        case popular
        case byIds([String])
    }

    public let filter: Filter
    public let parts: [Part]
    public let limit: Int?
    public let pageToken: String?

    public init(_ filter: Filter, parts: [Part] = [.snippet], limit: Int? = nil, pageToken: String? = nil) {
        self.filter = filter
        self.parts = parts.isEmpty ? [.snippet] : parts
        self.limit = limit
        self.pageToken = pageToken
    }
}

public struct Video: Equatable {
    public let id: String
    public let snippet: VideoSnippet?
    public let statistics: VideoStatistics?
    public let contentDetails: VideoContentDetails?}

public struct VideoSnippet: Equatable {
    public let title: String
    public let publishDate: Date
    public let channelId: String
    public let channelTitle: String
    public let defaultImage: Image
    public let mediumImage: Image
    public let highImage: Image
}

public struct VideoStatistics: Equatable {
    public let views: Int?
    public let likes: Int?
    public let dislikes: Int?
}

public struct VideoContentDetails: Equatable {
    public let duration: DateComponents
}

extension Videos: PageRequest {

    typealias Item = Video

    var method: Method { return .GET }
    var command: String { return "videos" }

    var parameters: [String: String] {
        var parameters: [String: String] = ["part": parts.joinParameters()]

        switch filter {
        case .popular:
            parameters["chart"] = "mostPopular"
        case .byIds(let ids):
            parameters["id"] = ids.joinParameters()
        }

        parameters["maxResults"] = limit.map(String.init)
        parameters["pageToken"] = pageToken

        return parameters
    }
}

extension Video: PartibleObject, SearchableObject {
    func merge(with other: Video) -> Video {
        return Video(id: id,
                     snippet: snippet ?? other.snippet,
                     statistics: statistics ?? other.statistics,
                     contentDetails: contentDetails ?? other.contentDetails)
    }

    static func request(for parts: [Part], objects: [Video]) -> AnyPageRequest<Video> {
        return AnyPageRequest(Videos(.byIds(objects.map { $0.id }), parts: parts))
    }

    var searchItemType: Type {
        return .video
    }
}
