import Foundation
import Alamofire

public struct Channels {
   public let ids: [String]
   public let parts: [Part]
   public let limit: Int?
   public let pageToken: String?

   public init(ids: [String], parts: [Part], limit: Int? = nil, pageToken: String? = nil) {
      self.ids = ids
      self.parts = parts
      self.limit = limit
      self.pageToken = pageToken
   }
}

public struct Channel: Equatable {
   public let id: String
   public let snippet: Snippet?
   public let statistics: ChannelStatistics?
}

public func == (lhs: Channel, rhs: Channel) -> Bool {
   return lhs.id == rhs.id &&
      lhs.snippet == rhs.snippet &&
      lhs.statistics == rhs.statistics
}

public struct ChannelStatistics: Equatable {
   public let subscriberCount: String?
   public let videoCount: String?
}

public func == (lhs: ChannelStatistics, rhs: ChannelStatistics) -> Bool {
   return lhs.subscriberCount == rhs.subscriberCount &&
      lhs.videoCount == rhs.videoCount
}

extension Channels: PageRequest {
   typealias Item = Channel

   var method: Alamofire.Method { return .GET }
   var command: String { return "channels" }

   var parameters: [String: AnyObject] {
      var parameters: [String: AnyObject] = ["id": ids.joinParameters(), "part": parts.joinParameters()]
      parameters["maxResults"] = self.limit
      parameters["pageToken"] = self.pageToken
      return parameters
   }
}

extension Channel: PartibleObject, SearchableObject {
   func mergeParts(other: Channel) -> Channel {
      return Channel(id: self.id,
                     snippet: self.snippet ?? other.snippet,
                     statistics: self.statistics ?? other.statistics)
   }

   static func requestForParts(parts: [Part], objects: [Channel]) -> AnyPageRequest<Channel> {
      return AnyPageRequest(Channels(ids: objects.map { $0.id }, parts: parts))
   }

   var searchItemType: Type {
      return .Channel
   }

   func toSearchItem() -> SearchItem {
      return .ChannelItem(self)
   }

   static func fromSearchItem(item: SearchItem) -> Channel? {
      return item.channel
   }
}
