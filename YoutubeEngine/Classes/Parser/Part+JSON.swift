import Foundation
import SwiftyJSON

extension Snippet: JSONRepresentable {
   init?(json: JSON) {
      guard let publishDate = json["publishedAt"].date,
         let title = json["title"].string,
         let thumbnailURL = json["thumbnails"]["default"]["url"].URL
         else {
            return nil
      }
      self.title = title
      self.publishDate = publishDate
      self.thumbnailURL = thumbnailURL

      //in video/channel snippet channelTitle is nil
      self.channelTitle = json["channelTitle"].string
   }
}

private extension JSON {
   var date: NSDate? {
      return self.string.flatMap { ISO8601Formatter.dateFromString($0) }
   }
}
