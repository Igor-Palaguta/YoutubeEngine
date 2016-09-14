import Foundation
import SwiftyJSON

extension Error {
   static func error(json: JSON) -> NSError? {
      let error = json["error"]
      guard error.isExists() else {
         return nil
      }

      guard let code = error["code"].int,
         let message = error["message"].string else {
            return Error.error(code: .RequestFailed)
      }

      return Error.youtubeError(code: code, message: message)
   }
}
