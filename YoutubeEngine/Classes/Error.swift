import Foundation

public struct Error {

   public static let Domain = "com.spangleapp.YoutubeEngine"

   public enum Code: Int {
      case RequestFailed = 10000
      case InvalidURL    = 10001
      case InvalidJSON   = 10002
   }

   static func error(code code: Code) -> NSError {
      return NSError(domain: Domain,
                     code: code.rawValue,
                     userInfo: nil)
   }

   static func youtubeError(code code: Int, message: String) -> NSError {
      return NSError(domain: Domain,
                     code: code,
                     userInfo: [NSLocalizedDescriptionKey: message])
   }
}
