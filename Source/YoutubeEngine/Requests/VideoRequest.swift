import Foundation

public struct VideoRequest {
    public enum Filter {
        case popular
        case byIDs([String])
    }

    public let filter: Filter
    public let requiredParts: [Part]
    public let limit: Int?
    public let pageToken: String?

    public init(_ filter: Filter, requiredParts: [Part] = [.snippet], limit: Int? = nil, pageToken: String? = nil) {
        self.filter = filter
        self.requiredParts = requiredParts.isEmpty ? [.snippet] : requiredParts
        self.limit = limit
        self.pageToken = pageToken
    }
}

extension VideoRequest {
    public static func popularVideos(withRequiredParts requiredParts: [Part] = [.snippet],
                                     limit: Int? = nil,
                                     pageToken: String? = nil) -> VideoRequest {
        return VideoRequest(.popular,
                            requiredParts: requiredParts,
                            limit: limit,
                            pageToken: pageToken)
    }

    public static func videos(withIDs videoIDs: [String],
                              requiredParts: [Part] = [.snippet],
                              limit: Int? = nil,
                              pageToken: String? = nil) -> VideoRequest {
        return VideoRequest(.byIDs(videoIDs),
                            requiredParts: requiredParts,
                            limit: limit,
                            pageToken: pageToken)
    }
}

extension VideoRequest: PageRequest {
    typealias Item = Video

    var method: HTTPMethod { return .GET }
    var command: String { return "videos" }

    var parameters: [String: String] {
        var parameters: [String: String] = ["part": requiredParts.requestParameterValue]

        switch filter {
        case .popular:
            parameters["chart"] = "mostPopular"
        case .byIDs(let ids):
            parameters["id"] = ids.requestParameterValue
        }

        parameters["maxResults"] = limit.map(String.init)
        parameters["pageToken"] = pageToken

        return parameters
    }
}
