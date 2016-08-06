import Foundation
import Alamofire

public struct Videos {

   public enum Filter {
      case Popular
      case ByIds([String])
   }

   public let filter: Filter
   public let parts: [Part]
   public let limit: Int?
   public let pageToken: String?

   public init(_ filter: Filter, parts: [Part], limit: Int? = nil, pageToken: String? = nil) {
      self.filter = filter
      self.parts = parts
      self.limit = limit
      self.pageToken = pageToken
   }
}

public struct Video {
   public let id: String
   public let snippet: Snippet?
   public let statistics: VideoStatistics?
   public let contentDetails: VideoContentDetails?
}

public struct VideoStatistics {
   public let viewCount: String?
   public let likeCount: String?
   public let dislikeCount: String?
}

public struct VideoContentDetails {
   public let duration: NSDateComponents
}

extension Videos: PageRequest {

   typealias Item = Video

   var method: Alamofire.Method { return .GET }
   var command: String { return "videos" }

   var parameters: [String: AnyObject] {
      var parameters: [String: AnyObject] = ["part": self.parts.joinParameters()]
      parameters["maxResults"] = self.limit
      parameters["pageToken"] = self.pageToken
      switch self.filter {
      case .Popular(_):
         parameters["chart"] = "mostPopular"
      case .ByIds(let ids):
         parameters["id"] = ids.joinParameters()
      }
      return parameters
   }
}

extension Video: PartibleObject, SearchableObject {
   func mergeParts(other: Video) -> Video {
      return Video(id: self.id,
                   snippet: self.snippet ?? other.snippet,
                   statistics: self.statistics ?? other.statistics,
                   contentDetails: self.contentDetails ?? other.contentDetails)
   }

   static func requestForParts(parts: [Part], objects: [Video]) -> AnyPageRequest<Video> {
      return AnyPageRequest(Videos(.ByIds(objects.map { $0.id }), parts: parts))
   }

   var searchItemType: Type {
      return .Video
   }

   func toSearchItem() -> SearchItem {
      return .VideoItem(self)
   }

   static func fromSearchItem(item: SearchItem) -> Video? {
      return item.video
   }
}
