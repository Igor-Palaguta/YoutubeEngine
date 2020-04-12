import Foundation

public struct Channels {

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

public struct Channel: Equatable {
    public let id: String
    public let snippet: ChannelSnippet?
    public let statistics: ChannelStatistics?
}

public struct ChannelSnippet: Equatable {
    public let title: String
    public let publishDate: Date
    public let defaultImage: Image
    public let mediumImage: Image
    public let highImage: Image
}

public struct ChannelStatistics: Equatable {
    public let subscribers: Int?
    public let videos: Int?
}

extension Channels: PageRequest {
    typealias Item = Channel

    var method: Method { return .GET }
    var command: String { return "channels" }

    var parameters: [String: String] {
        var parameters: [String: String] = ["part": parts.joinParameters()]

        switch filter {
        case .mine:
            parameters["mine"] = "true"
        case .byIds(let ids):
            parameters["id"] = ids.joinParameters()
        }

        parameters["maxResults"] = limit.map(String.init)
        parameters["pageToken"] = pageToken
        return parameters
    }
}

extension Channel: PartibleObject, SearchableObject {
    func merge(with other: Channel) -> Channel {
        return Channel(id: id,
                       snippet: snippet ?? other.snippet,
                       statistics: statistics ?? other.statistics)
    }

    static func request(for parts: [Part], objects: [Channel]) -> AnyPageRequest<Channel> {
        return AnyPageRequest(Channels(.byIds(objects.map { $0.id }), parts: parts))
    }

    var searchItemType: Type {
        return .channel
    }
}
