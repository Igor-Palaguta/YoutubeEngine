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

public struct Image: Equatable {
   public let url: NSURL
   public let size: CGSize?
}

public func == (lhs: Image, rhs: Image) -> Bool {
   return lhs.url == rhs.url && lhs.size == rhs.size
}
