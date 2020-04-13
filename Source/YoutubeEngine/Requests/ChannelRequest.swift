import Foundation

public struct ChannelRequest {
    public enum Filter {
        case mine
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

extension ChannelRequest: PageRequest {
    typealias Item = Channel

    var method: HTTPMethod { return .GET }
    var command: String { return "channels" }

    var parameters: [String: String] {
        var parameters: [String: String] = ["part": parts.requestParameterValue]

        switch filter {
        case .mine:
            parameters["mine"] = "true"
        case .byIds(let ids):
            parameters["id"] = ids.requestParameterValue
        }

        parameters["maxResults"] = limit.map(String.init)
        parameters["pageToken"] = pageToken
        return parameters
    }
}
