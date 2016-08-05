import Foundation
import SwiftyJSON

extension Video: JSONRepresentable {
   init?(json: JSON) {
      guard let id = json["id"].string else {
         return nil
      }

      self.id = id
      self.snippet = Snippet(json: json[Part.Snippet.parameterValue])
      self.contentDetails = ContentDetails(json: json[Part.ContentDetails.parameterValue])
      self.statistics = Statistics(json: json[Part.Statistics.parameterValue])
   }
}
