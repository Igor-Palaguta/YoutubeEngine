import Foundation
import SwiftyJSON

extension Snippet: JSONRepresentable {
   init?(json: JSON) {
      guard let publishDate = json["publishedAt"].date,
         let title = json["title"].string,
         let channelId = json["channelId"].string,
         let defaultImage = Image(json: json["thumbnails"]["default"]),
         let mediumImage = Image(json: json["thumbnails"]["medium"]),
         let highImage = Image(json: json["thumbnails"]["high"]) else {
            return nil
      }
      self.title = title
      self.publishDate = publishDate
      self.channelId = channelId
      self.defaultImage = defaultImage
      self.mediumImage = mediumImage
      self.highImage = highImage

      //in video/channel snippet channelTitle is nil
      self.channelTitle = json["channelTitle"].string
   }
}

extension Image: JSONRepresentable {
   init?(json: JSON) {
      guard let url = json["url"].URL else {
         return nil
      }
      self.url = url
      if let width = json["width"].int,
         let height = json["height"].int {
         self.size = CGSize(width: width, height: height)
      } else {
         self.size = nil
      }
   }
}

private extension JSON {
   var date: Date? {
      return self.string.flatMap { ISO8601Formatter.date(from: $0) }
   }
}
