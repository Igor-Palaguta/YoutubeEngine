import Foundation
import SwiftyJSON

extension YoutubeError {
   static func error(json: JSON) -> NSError? {
      let error = json["error"]
      guard error.exists() else {
         return nil
      }

      guard let code = error["code"].int,
         let message = error["message"].string else {
            return YoutubeError.error(code: .requestFailed)
      }

      return YoutubeError.youtubeError(code: code, message: message)
   }
}
