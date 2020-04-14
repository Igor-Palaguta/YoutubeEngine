import Foundation

public struct ChannelRequest {
    public enum Filter {
        case my
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

extension ChannelRequest {
    public static func myChannels(withRequiredParts requiredParts: [Part] = [.snippet],
                                  limit: Int? = nil,
                                  pageToken: String? = nil) -> ChannelRequest {
        return ChannelRequest(.my,
                              requiredParts: requiredParts,
                              limit: limit,
                              pageToken: pageToken)
    }

    public static func channels(withIDs channelIDs: [String],
                                requiredParts: [Part] = [.snippet],
                                limit: Int? = nil,
                                pageToken: String? = nil) -> ChannelRequest {
        return ChannelRequest(.byIDs(channelIDs),
                              requiredParts: requiredParts,
                              limit: limit,
                              pageToken: pageToken)
    }
}

extension ChannelRequest: PageRequest {
    typealias Item = Channel

    var method: HTTPMethod { return .GET }
    var command: String { return "channels" }

    var parameters: [String: String] {
        var parameters: [String: String] = ["part": requiredParts.requestParameterValue]

        switch filter {
        case .my:
            parameters["mine"] = "true"
        case .byIDs(let ids):
            parameters["id"] = ids.requestParameterValue
        }

        parameters["maxResults"] = limit.map(String.init)
        parameters["pageToken"] = pageToken
        return parameters
    }
}
