import Foundation

public enum ContentType: String, RequestParameterRepresenting {
    case video
    case channel
    case playlist
}

public struct SearchRequest {
    public enum Filter {
        case term(String, [ContentType: [Part]])
        case fromChannel(String, [Part])
        case relatedTo(String, [Part])
    }

    public let filter: Filter
    public let limit: Int?
    public let pageToken: String?

    public init(_ filter: Filter, limit: Int? = nil, pageToken: String? = nil) {
        self.filter = filter
        self.limit = limit
        self.pageToken = pageToken
    }

    var contentTypes: [ContentType] {
        if case .term(_, let parts) = filter {
            return Array(parts.keys)
        }
        return [.video]
    }

    var videoParts: [Part] {
        switch filter {
        case .term(_, let parts):
            return parts[.video] ?? []
        case .fromChannel(_, let videoParts):
            return videoParts
        case .relatedTo(_, let videoParts):
            return videoParts
        }
    }

    var channelParts: [Part] {
        switch filter {
        case .term(_, let parts):
            return parts[.channel] ?? []
        default:
            return []
        }
    }

    var playlistParts: [Part] {
        switch filter {
        case .term(_, let parts):
            return parts[.playlist] ?? []
        default:
            return []
        }
    }

    var part: Part {
        return .snippet
    }
}

extension SearchRequest {
    public static func search(withTerm term: String,
                              requiredVideoParts: [Part]? = nil,
                              requiredChannelParts: [Part]? = nil,
                              requiredPlaylistParts: [Part]? = nil,
                              limit: Int? = nil,
                              pageToken: String? = nil) -> SearchRequest {
        var partsByType: [ContentType: [Part]] = [:]
        partsByType[.video] = requiredVideoParts
        partsByType[.channel] = requiredChannelParts
        partsByType[.playlist] = requiredPlaylistParts
        return SearchRequest(.term(term, partsByType),
                             limit: limit,
                             pageToken: pageToken)
    }

    public static func videosFromChannel(withID channelID: String,
                                         requiredParts: [Part],
                                         limit: Int? = nil,
                                         pageToken: String? = nil) -> SearchRequest {
        return SearchRequest(.fromChannel(channelID, requiredParts),
                             limit: limit,
                             pageToken: pageToken)
    }

    public static func videosRelatedToVideo(withID videoID: String,
                                            requiredParts: [Part],
                                            limit: Int? = nil,
                                            pageToken: String? = nil) -> SearchRequest {
        return SearchRequest(.relatedTo(videoID, requiredParts),
                             limit: limit,
                             pageToken: pageToken)
    }
}

extension SearchRequest: PageRequest {

    typealias Item = SearchItem

    var method: HTTPMethod { return .GET }
    var command: String { return "search" }

    var parameters: [String: String] {
        var parameters: [String: String] = [
            "part": part.requestParameterValue,
            "type": contentTypes.requestParameterValue
        ]

        parameters["maxResults"] = limit.map(String.init)
        parameters["pageToken"] = pageToken

        switch filter {
        case .term(let query, _):
            parameters["q"] = query
        case .fromChannel(let channelID, _):
            parameters["channelId"] = channelID
        case .relatedTo(let videoID, _):
            parameters["videoId"] = videoID
        }

        return parameters
    }
}
