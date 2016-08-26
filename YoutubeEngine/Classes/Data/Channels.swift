import Foundation
import Alamofire

public struct Channels {

   public enum Filter {
      case Mine
      case ByIds([String])
   }

   public let filter: Filter
   public let parts: [Part]
   public let limit: Int?
   public let pageToken: String?

   public init(_ filter: Filter, parts: [Part] = [.Snippet], limit: Int? = nil, pageToken: String? = nil) {
      self.filter = filter
      self.parts = parts.isEmpty ? [.Snippet] : parts
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
   public let subscribers: Int?
   public let videos: Int?
}

public func == (lhs: ChannelStatistics, rhs: ChannelStatistics) -> Bool {
   return lhs.subscribers == rhs.subscribers &&
      lhs.videos == rhs.videos
}

extension Channels: PageRequest {
   typealias Item = Channel

   var method: Alamofire.Method { return .GET }
   var command: String { return "channels" }

   var parameters: [String: AnyObject] {
      var parameters: [String: AnyObject] = ["part": self.parts.joinParameters()]

      switch self.filter {
      case .Mine:
         parameters["mine"] = "true"
      case .ByIds(let ids):
         parameters["id"] = ids.joinParameters()
      }

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
      return AnyPageRequest(Channels(.ByIds(objects.map { $0.id }), parts: parts))
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
