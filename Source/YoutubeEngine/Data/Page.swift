import Foundation

public struct Page<Item> {
   public let items: [Item]
   public let totalCount: Int
   public let nextPageToken: String?
   public let previousPageToken: String?
}
