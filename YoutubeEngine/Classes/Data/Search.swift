import Foundation

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

public enum SearchRequest {
   case Search(query: String, types: [Type], pageToken: String?)
   case Channel(id: String, pageToken: String?)
   case Related(id: String, pageToken: String?)

   var parts: [Part] {
      return [.Snippet]
   }

   var types: [Type] {
      if case .Search(_, let types, _) = self {
         return types
      }
      return [.Video]
   }

   var pageToken: String? {
      switch self {
      case .Search(_, _, let pageToken):
         return pageToken
      case .Channel(_, let pageToken):
         return pageToken
      case .Related(_, let pageToken):
         return pageToken
      }
   }
}

public struct Channel: CustomStringConvertible {
   public let id: String
   public let snippet: Snippet

   public var description: String {
      return "Channel(id: \(id), snippet: \(snippet))"
   }
}

public enum SearchItem: CustomStringConvertible {
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

   public var description: String {
      switch self {
      case .ChannelItem(let channel):
         return channel.description
      case .VideoItem(let video):
         return video.description
      }
   }
}

public struct Page<Item> {
   public let items: [Item]
   public let totalCount: Int
   public let nextPageToken: String?
   public let previousPageToken: String?
}
