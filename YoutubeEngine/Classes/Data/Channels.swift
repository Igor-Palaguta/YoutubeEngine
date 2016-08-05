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

public struct Channel: CustomStringConvertible {
   public let id: String
   public internal(set) var snippet: Snippet?
   public internal(set) var statistics: ChannelStatistics?

   public var description: String {
      return "Channel(id: \(id), snippet: \(snippet?.description ?? "null"), statistics: \(statistics?.description ?? "null"))"
   }
}

public struct ChannelStatistics: CustomStringConvertible {
   public let subscriberCount: String
   public let videoCount: String

   public var description: String {
      return "ChannelStatistics(subscriberCount: \(subscriberCount), videoCount: \(videoCount))"
   }
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


