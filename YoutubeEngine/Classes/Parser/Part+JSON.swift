import Foundation
import SwiftyJSON

extension Snippet: JSONRepresentable {
   init?(json: JSON) {
      guard let publishDate = json["publishedAt"].string.flatMap({ ISO8601Formatter.dateFromString($0) }),
         let title = json["title"].string,
         let thumbnailURL = json["thumbnails"]["default"]["url"].URL
         else {
            return nil
      }
      self.title = title
      self.publishDate = publishDate
      self.thumbnailURL = thumbnailURL
   }
}
