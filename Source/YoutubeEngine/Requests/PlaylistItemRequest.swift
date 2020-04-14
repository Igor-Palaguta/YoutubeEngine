import Foundation

public struct PlaylistItemRequest {
    public enum Filter {
        case fromPlaylist(String)
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

extension PlaylistItemRequest {
    public static func itemsFromPlaylist(withID playlistID: String,
                                         requiredParts: [Part] = [.snippet],
                                         limit: Int? = nil,
                                         pageToken: String? = nil) -> PlaylistItemRequest {
        return PlaylistItemRequest(.fromPlaylist(playlistID),
                                   requiredParts: requiredParts,
                                   limit: limit,
                                   pageToken: pageToken)
    }

    public static func playlistItems(withIDs playlistIDs: [String],
                                     requiredParts: [Part] = [.snippet],
                                     limit: Int? = nil,
                                     pageToken: String? = nil) -> PlaylistItemRequest {
        return PlaylistItemRequest(.byIDs(playlistIDs),
                                   requiredParts: requiredParts,
                                   limit: limit,
                                   pageToken: pageToken)
    }
}

extension PlaylistItemRequest: PageRequest {
    typealias Item = PlaylistItem

    var method: HTTPMethod { return .GET }
    var command: String { return "playlistItems" }

    var parameters: [String: String] {
        var parameters: [String: String] = ["part": requiredParts.requestParameterValue]

        switch filter {
        case .fromPlaylist(let playlistID):
            parameters["playlistId"] = playlistID
        case .byIDs(let ids):
            parameters["id"] = ids.requestParameterValue
        }

        parameters["maxResults"] = limit.map(String.init)
        parameters["pageToken"] = pageToken
        return parameters
    }
}
