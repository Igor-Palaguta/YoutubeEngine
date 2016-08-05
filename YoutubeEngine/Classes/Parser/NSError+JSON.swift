import Foundation
import SwiftyJSON

extension NSError {
   class func errorWithJSON(json: JSON) -> NSError? {
      let error = json["error"]
      guard error.isExists() else {
         return nil
      }

      let code = error["code"].int ?? 0
      let message = error["message"].string ?? "Request failed"

      return self.init(domain: YoutubeErrorDomain,
                       code: code,
                       userInfo: [NSLocalizedDescriptionKey: message])
   }
}
