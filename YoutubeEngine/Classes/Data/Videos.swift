import Foundation

public enum VideosRequest {
   case Popular(parts: [Part])
   case Videos(ids: [String], parts: [Part])

   var parts: [Part] {
      switch self {
      case .Popular(let parts):
         return parts
      case .Videos(_, let parts):
         return parts
      }
   }
}

public struct Video: CustomStringConvertible {
   let id: String
   public internal(set) var snippet: Snippet?
   public internal(set) var statistics: Statistics?
   public internal(set) var contentDetails: ContentDetails?

   public var description: String {
      return "Video(id: \(id), snippet: \(snippet?.description ?? "null"), statistics: \(statistics?.description ?? "null"), contentDetails: \(contentDetails?.description ?? "null"))"
   }
}
