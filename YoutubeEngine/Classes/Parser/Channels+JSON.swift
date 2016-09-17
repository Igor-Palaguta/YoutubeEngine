import Foundation
import SwiftyJSON

extension Channel: JSONRepresentable {
   init?(json: JSON) {
      guard let id = json["id"].string else {
         return nil
      }

      self.id = id
      self.snippet = Snippet(json: json[Part.snippet.parameterValue])
      self.statistics = ChannelStatistics(json: json[Part.statistics.parameterValue])
   }
}

extension ChannelStatistics: JSONRepresentable {
   init?(json: JSON) {
      self.subscribers = json["subscriberCount"].string.flatMap { Int($0) }
      self.videos = json["videoCount"].string.flatMap { Int($0) }
   }
}
