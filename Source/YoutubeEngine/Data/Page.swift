import Foundation

public struct Page<Item> {
    public let items: [Item]
    public let totalCount: Int
    public let nextPageToken: String?
    public let previousPageToken: String?
}

extension Page: Decodable where Item: Decodable {
    private enum CodingKeys: String, CodingKey {
        case items
        case pageInfo
        case nextPageToken
        case previousPageToken = "prevPageToken"
    }

    private enum PageInfoCodingKeys: String, CodingKey {
        case totalCount = "totalResults"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.nextPageToken = try container.decodeIfPresent(String.self, forKey: .nextPageToken)

        self.previousPageToken = try container.decodeIfPresent(String.self, forKey: .previousPageToken)

        self.items = try container.decode([Item].self, forKey: .items)

        let pageInfoContainer = try container.nestedContainer(keyedBy: PageInfoCodingKeys.self, forKey: .pageInfo)

        self.totalCount = try pageInfoContainer.decode(Int.self, forKey: .totalCount)
    }
}
