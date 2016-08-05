import Foundation

public enum Part: Parameter {
   case Snippet
   case ContentDetails
   case Statistics

   static let all: [Part] = [.Snippet, .ContentDetails, .Statistics]

   var parameterValue: String {
      switch self {
      case .Snippet:
         return "snippet"
      case .ContentDetails:
         return "contentDetails"
      case .Statistics:
         return "statistics"
      }
   }
}

public struct Snippet: CustomStringConvertible {
   public let title: String
   public let publishDate: NSDate
   public let thumbnailURL: NSURL

   public var description: String {
      return "Snippet(title: \(title), publishDate: \(publishDate), thumbnailURL: \(thumbnailURL))"
   }
}
