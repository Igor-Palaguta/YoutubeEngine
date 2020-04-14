import Foundation

public struct Playlist: Equatable, Decodable {
    public let id: String
    public var snippet: PlaylistSnippet?
}

public struct PlaylistSnippet: Equatable {
    public let title: String
    public let description: String
    public let publishDate: Date
    public let channelID: String
    public let channelTitle: String
    public let defaultImage: Image
    public let mediumImage: Image
    public let highImage: Image
}

extension PlaylistSnippet: Decodable {
    private enum CodingKeys: String, CodingKey {
        case title
        case description
        case publishDate = "publishedAt"
        case channelID = "channelId"
        case channelTitle
        case thumbnails
    }

    private enum ThumbnailCodingKeys: String, CodingKey {
        case `default`
        case medium
        case high
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.publishDate = try container.decode(Date.self, forKey: .publishDate)
        self.channelID = try container.decode(String.self, forKey: .channelID)
        self.channelTitle = try container.decode(String.self, forKey: .channelTitle)

        let thumbnailsContainer = try container.nestedContainer(keyedBy: ThumbnailCodingKeys.self, forKey: .thumbnails)

        self.defaultImage = try thumbnailsContainer.decode(Image.self, forKey: .default)
        self.mediumImage = try thumbnailsContainer.decode(Image.self, forKey: .medium)
        self.highImage = try thumbnailsContainer.decode(Image.self, forKey: .high)
    }
}
