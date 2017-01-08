import Foundation

public struct YoutubeError: Error {

   public static let Domain = "com.spangleapp.YoutubeEngine"

   public enum Code: Int {
      case requestFailed = 10000
      case invalidURL    = 10001
      case invalidJSON   = 10002
   }

   static func error(code: Code) -> NSError {
      return NSError(domain: Domain,
                     code: code.rawValue,
                     userInfo: nil)
   }

   static func youtubeError(code: Int, message: String) -> NSError {
      return NSError(domain: Domain,
                     code: code,
                     userInfo: [NSLocalizedDescriptionKey: message])
   }
}
