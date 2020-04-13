import Foundation

public struct VideoRequest {
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

extension VideoRequest: PageRequest {
    typealias Item = Video

    var method: HTTPMethod { return .GET }
    var command: String { return "videos" }

    var parameters: [String: String] {
        var parameters: [String: String] = ["part": parts.requestParameterValue]

        switch filter {
        case .popular:
            parameters["chart"] = "mostPopular"
        case .byIds(let ids):
            parameters["id"] = ids.requestParameterValue
        }

        parameters["maxResults"] = limit.map(String.init)
        parameters["pageToken"] = pageToken

        return parameters
    }
}
