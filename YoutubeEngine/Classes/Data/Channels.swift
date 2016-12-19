import Foundation

public struct Channels {

   public enum Filter {
      case mine
      case byIds([String])
   }

   public let filter: Filter
   public let parts: [Part]
   public let limit: Int?
   public let pageToken: String?

   public init(_ filter: Filter, parts: [Part] = [.snippet], limit: Int? = nil, pageToken: String? = nil) {
      self.filter = filter
      self.parts = parts.isEmpty ? [.snippet] : parts
      self.limit = limit
      self.pageToken = pageToken
   }
}

public struct Channel: Equatable {
   public let id: String
   public let snippet: ChannelSnippet?
   public let statistics: ChannelStatistics?

   public static func == (lhs: Channel, rhs: Channel) -> Bool {
      return lhs.id == rhs.id &&
         lhs.snippet == rhs.snippet &&
         lhs.statistics == rhs.statistics
   }
}

public struct ChannelSnippet: Equatable {
   public let title: String
   public let publishDate: Date
   public let defaultImage: Image
   public let mediumImage: Image
   public let highImage: Image

   public static func == (lhs: ChannelSnippet, rhs: ChannelSnippet) -> Bool {
      return lhs.title == rhs.title &&
         lhs.publishDate == rhs.publishDate &&
         lhs.defaultImage == rhs.defaultImage &&
         lhs.mediumImage == rhs.mediumImage &&
         lhs.highImage == rhs.highImage
   }
}

public struct ChannelStatistics: Equatable {
   public let subscribers: Int?
   public let videos: Int?

   public static func == (lhs: ChannelStatistics, rhs: ChannelStatistics) -> Bool {
      return lhs.subscribers == rhs.subscribers &&
         lhs.videos == rhs.videos
   }
}

extension Channels: PageRequest {
   typealias Item = Channel

   var method: Method { return .GET }
   var command: String { return "channels" }

   var parameters: [String: String] {
      var parameters: [String: String] = ["part": self.parts.joinParameters()]

      switch self.filter {
      case .mine:
         parameters["mine"] = "true"
      case .byIds(let ids):
         parameters["id"] = ids.joinParameters()
      }

      parameters["maxResults"] = self.limit.map(String.init)
      parameters["pageToken"] = self.pageToken
      return parameters
   }
}

extension Channel: PartibleObject, SearchableObject {
   func merge(with other: Channel) -> Channel {
      return Channel(id: self.id,
                     snippet: self.snippet ?? other.snippet,
                     statistics: self.statistics ?? other.statistics)
   }

   static func request(for parts: [Part], objects: [Channel]) -> AnyPageRequest<Channel> {
      return AnyPageRequest(Channels(.byIds(objects.map { $0.id }), parts: parts))
   }

   var searchItemType: Type {
      return .channel
   }
}
