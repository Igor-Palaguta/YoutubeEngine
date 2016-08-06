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

extension VideoStatistics: JSONRepresentable {
   init?(json: JSON) {
      self.viewCount = json["viewCount"].string
      self.likeCount = json["likeCount"].string
      self.dislikeCount = json["dislikeCount"].string
   }
}

extension VideoContentDetails: JSONRepresentable {
   init?(json: JSON) {
      guard let duration = json["duration"].string.flatMap({ NSDateComponents(ISO8601String: $0) }) else {
         return nil
      }
      self.duration = duration
   }
}

extension ChannelStatistics: JSONRepresentable {
   init?(json: JSON) {
      self.subscriberCount = json["subscriberCount"].string
      self.videoCount = json["videoCount"].string
   }
}
