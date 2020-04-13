import Foundation

public enum SearchItem: Equatable {
    case channelItem(Channel)
    case videoItem(Video)

    public var video: Video? {
        if case .videoItem(let video) = self {
            return video
        }
        return nil
    }

    public var channel: Channel? {
        if case .channelItem(let channel) = self {
            return channel
        }
        return nil
    }
}

extension SearchItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case snippet
    }

    private enum IDCodingKeys: String, CodingKey {
        case kind
        case channelId
        case videoId
    }

    private enum Kind: String, Decodable {
        case channel = "youtube#channel"
        case video = "youtube#video"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idContainer = try container.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .id)
        let kind = try idContainer.decode(Kind.self, forKey: .kind)
        switch kind {
        case .channel:
            let id = try idContainer.decode(String.self, forKey: .channelId)
            let snippet = try container.decodeIfPresent(ChannelSnippet.self, forKey: .snippet)
            let channel = Channel(id: id, snippet: snippet)
            self = .channelItem(channel)
        case .video:
            let id = try idContainer.decode(String.self, forKey: .videoId)
            let snippet = try container.decodeIfPresent(VideoSnippet.self, forKey: .snippet)
            let channel = Video(id: id, snippet: snippet)
            self = .videoItem(channel)
        }
    }
}
