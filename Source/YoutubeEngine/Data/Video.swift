import Foundation

public struct Video: Equatable, Decodable {
    public let id: String
    public var snippet: VideoSnippet?
    public var statistics: VideoStatistics?
    public var contentDetails: VideoContentDetails?
}

public struct VideoSnippet: Equatable {
    public let title: String
    public let publishDate: Date
    public let channelID: String
    public let channelTitle: String
    public let defaultImage: Image
    public let mediumImage: Image
    public let highImage: Image
}

extension VideoSnippet: Decodable {
    private enum CodingKeys: String, CodingKey {
        case title
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
        self.publishDate = try container.decode(Date.self, forKey: .publishDate)
        self.channelID = try container.decode(String.self, forKey: .channelID)
        self.channelTitle = try container.decode(String.self, forKey: .channelTitle)

        let thumbnailsContainer = try container.nestedContainer(keyedBy: ThumbnailCodingKeys.self, forKey: .thumbnails)

        self.defaultImage = try thumbnailsContainer.decode(Image.self, forKey: .default)
        self.mediumImage = try thumbnailsContainer.decode(Image.self, forKey: .medium)
        self.highImage = try thumbnailsContainer.decode(Image.self, forKey: .high)
    }
}

public struct VideoStatistics: Equatable {
    public let viewCount: Int?
    public let likeCount: Int?
    public let dislikeCount: Int?
}

extension VideoStatistics: Decodable {
    private enum CodingKeys: String, CodingKey {
        case viewCount
        case likeCount
        case dislikeCount
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.viewCount = try container.decodeIfPresent(StatisticsNumber.self, forKey: .viewCount)?.value
        self.likeCount = try container.decodeIfPresent(StatisticsNumber.self, forKey: .likeCount)?.value
        self.dislikeCount = try container.decodeIfPresent(StatisticsNumber.self, forKey: .dislikeCount)?.value
    }
}

public struct VideoContentDetails: Equatable {
    public let duration: DateComponents
}

extension VideoContentDetails: Decodable {
    private enum CodingKeys: String, CodingKey {
        case duration
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let duration = try container.decode(String.self, forKey: .duration)
        self.duration = try DateComponents(ISO8601String: duration)
    }
}
