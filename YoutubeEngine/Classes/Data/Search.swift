import Foundation
import Alamofire

public enum Type: Parameter {
   case Video
   case Channel

   var parameterValue: String {
      switch self {
      case .Video:
         return "video"
      case .Channel:
         return "channel"
      }
   }
}

public struct Search {
   public enum Filter {
      case Term(String, [Type: [Part]])
      case FromChannel(String, [Part])
      case RelatedTo(String, [Part])
   }

   public let filter: Filter
   public let limit: Int?
   public let pageToken: String?

   public init(_ filter: Filter, limit: Int? = nil, pageToken: String? = nil) {
      self.filter = filter
      self.limit = limit
      self.pageToken = pageToken
   }

   var types: [Type] {
      if case .Term(_, let parts) = self.filter {
         return Array(parts.keys)
      }
      return [.Video]
   }

   var videoParts: [Part] {
      switch self.filter {
      case .Term(_, let parts):
         return parts[.Video] ?? []
      case .FromChannel(_, let videoParts):
         return videoParts
      case .RelatedTo(_, let videoParts):
         return videoParts
      }
   }

   var channelParts: [Part] {
      switch self.filter {
      case .Term(_, let parts):
         return parts[.Channel] ?? []
      default:
         return []
      }
   }

   var part: Part {
      return .Snippet
   }
}

public enum SearchItem: Equatable {
   case ChannelItem(Channel)
   case VideoItem(Video)

   var video: Video? {
      if case .VideoItem(let video) = self {
         return video
      }
      return nil
   }

   var channel: Channel? {
      if case .ChannelItem(let channel) = self {
         return channel
      }
      return nil
   }
}

public func == (lhs: SearchItem, rhs: SearchItem) -> Bool {
   switch (lhs, rhs) {
   case (.ChannelItem(let lhsChannel), .ChannelItem(let rhsChannel)):
      return lhsChannel == rhsChannel
   case (.VideoItem(let lhsVideo), .VideoItem(let rhsVideo)):
      return lhsVideo == rhsVideo
   default:
      return false
   }
}

extension Search: PageRequest {

   typealias Item = SearchItem

   var method: Alamofire.Method { return .GET }
   var command: String { return "search" }

   var parameters: [String: AnyObject] {

      var parameters: [String: AnyObject] = ["part": self.part.parameterValue,
                                             "type": self.types.joinParameters()]

      parameters["maxResults"] = self.limit
      parameters["pageToken"] = self.pageToken

      switch self.filter {
      case .Term(let query, _):
         parameters["q"] = query
      case .FromChannel(let channelId, _):
         parameters["channelId"] = channelId
      case .RelatedTo(let videoId, _):
         parameters["videoId"] = videoId
      }
      
      return parameters
   }
}

private extension SequenceType where Generator.Element: Equatable {
   func substractArray(array: [Generator.Element]) -> [Generator.Element] {
      return self.filter { !array.contains($0) }
   }
}
