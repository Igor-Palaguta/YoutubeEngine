import Foundation
import SwiftyJSON

extension Image: JSONRepresentable {
   init?(json: JSON) {
      guard let url = json["url"].url else {
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
