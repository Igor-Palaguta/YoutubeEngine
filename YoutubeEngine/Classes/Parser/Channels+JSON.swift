import Foundation
import SwiftyJSON

extension Channel: JSONRepresentable {
   init?(json: JSON) {
      guard let id = json["id"].string else {
         return nil
      }

      self.id = id
      self.snippet = ChannelSnippet(json: json[Part.snippet.parameterValue])
      self.statistics = ChannelStatistics(json: json[Part.statistics.parameterValue])
   }
}

extension ChannelSnippet: JSONRepresentable {
   init?(json: JSON) {
      guard let publishDate = json["publishedAt"].date,
         let title = json["title"].string,
         let defaultImage = Image(json: json["thumbnails"]["default"]),
         let mediumImage = Image(json: json["thumbnails"]["medium"]),
         let highImage = Image(json: json["thumbnails"]["high"]) else {
            return nil
      }
      self.title = title
      self.publishDate = publishDate
      self.defaultImage = defaultImage
      self.mediumImage = mediumImage
      self.highImage = highImage
   }
}

extension ChannelStatistics: JSONRepresentable {
   init?(json: JSON) {
      guard json.exists() else {
         return nil
      }

      self.subscribers = json["subscriberCount"].string.flatMap { Int($0) }
      self.videos = json["videoCount"].string.flatMap { Int($0) }
   }
}
