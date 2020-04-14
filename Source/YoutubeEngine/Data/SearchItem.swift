import Foundation

public enum SearchItem: Equatable {
    case channel(Channel)
    case video(Video)
    case playlist(Playlist)

    public var video: Video? {
        if case .video(let video) = self {
            return video
        }
        return nil
    }

    public var channel: Channel? {
        if case .channel(let channel) = self {
            return channel
        }
        return nil
    }

    public var playlist: Playlist? {
        if case .playlist(let playlist) = self {
            return playlist
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
        case channelID = "channelId"
        case videoID = "videoId"
        case playlistID = "playlistId"
    }

    private enum Kind: String, Decodable {
        case channel = "youtube#channel"
        case video = "youtube#video"
        case playlist = "youtube#playlist"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idContainer = try container.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .id)
        let kind = try idContainer.decode(Kind.self, forKey: .kind)
        switch kind {
        case .channel:
            let id = try idContainer.decode(String.self, forKey: .channelID)
            let snippet = try container.decodeIfPresent(ChannelSnippet.self, forKey: .snippet)
            let channel = Channel(id: id, snippet: snippet)
            self = .channel(channel)
        case .video:
            let id = try idContainer.decode(String.self, forKey: .videoID)
            let snippet = try container.decodeIfPresent(VideoSnippet.self, forKey: .snippet)
            let video = Video(id: id, snippet: snippet)
            self = .video(video)
        case .playlist:
            let id = try idContainer.decode(String.self, forKey: .playlistID)
            let snippet = try container.decodeIfPresent(PlaylistSnippet.self, forKey: .snippet)
            let playlist = Playlist(id: id, snippet: snippet)
            self = .playlist(playlist)
        }
    }
}
