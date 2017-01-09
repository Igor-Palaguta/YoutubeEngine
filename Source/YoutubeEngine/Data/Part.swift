import Foundation

public enum Part: Parameter {
   case snippet
   case contentDetails
   case statistics

   static let all: [Part] = [.snippet, .contentDetails, .statistics]

   var parameterValue: String {
      switch self {
      case .snippet:
         return "snippet"
      case .contentDetails:
         return "contentDetails"
      case .statistics:
         return "statistics"
      }
   }
}

public struct Image: Equatable {
   public let url: URL
   public let size: CGSize?

   public static func == (lhs: Image, rhs: Image) -> Bool {
      return lhs.url == rhs.url && lhs.size == rhs.size
   }
}
