import Foundation

public struct Channel: Equatable, Decodable {
    public let id: String
    public var snippet: ChannelSnippet?
    public var statistics: ChannelStatistics?
}

public struct ChannelStatistics: Equatable {
    public let subscriberCount: Int?
    public let videoCount: Int?
}

extension ChannelStatistics: Decodable {
    private enum CodingKeys: String, CodingKey {
        case subscriberCount
        case videoCount
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.subscriberCount = try container.decodeIfPresent(StatisticsNumber.self, forKey: .subscriberCount)?.value
        self.videoCount = try container.decodeIfPresent(StatisticsNumber.self, forKey: .videoCount)?.value
    }
}

public struct ChannelSnippet: Equatable {
    public let title: String
    public let publishDate: Date
    public let defaultImage: Image
    public let mediumImage: Image
    public let highImage: Image
}

extension ChannelSnippet: Decodable {
    private enum CodingKeys: String, CodingKey {
        case title
        case publishDate = "publishedAt"
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

        let thumbnailsContainer = try container.nestedContainer(keyedBy: ThumbnailCodingKeys.self, forKey: .thumbnails)

        self.defaultImage = try thumbnailsContainer.decode(Image.self, forKey: .default)
        self.mediumImage = try thumbnailsContainer.decode(Image.self, forKey: .medium)
        self.highImage = try thumbnailsContainer.decode(Image.self, forKey: .high)
    }
}
