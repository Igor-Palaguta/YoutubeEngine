import Foundation
import SwiftyJSON

extension Video: JSONRepresentable {
   init?(json: JSON) {
      guard let id = json["id"].string else {
         return nil
      }

      self.id = id
      self.snippet = Snippet(json: json[Part.Snippet.parameterValue])
      self.contentDetails = VideoContentDetails(json: json[Part.ContentDetails.parameterValue])
      self.statistics = VideoStatistics(json: json[Part.Statistics.parameterValue])
   }
}

extension VideoStatistics: JSONRepresentable {
   init?(json: JSON) {
      self.viewCount = json["viewCount"].string.flatMap { Int64($0) }
      self.likeCount = json["likeCount"].string.flatMap { Int64($0) }
      self.dislikeCount = json["dislikeCount"].string.flatMap { Int64($0) }
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
