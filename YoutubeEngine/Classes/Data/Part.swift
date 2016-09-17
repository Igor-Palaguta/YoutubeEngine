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
}

public func == (lhs: Image, rhs: Image) -> Bool {
   return lhs.url == rhs.url && lhs.size == rhs.size
}

public struct Snippet: Equatable {
   public let title: String
   public let publishDate: Date
   public let channelId: String
   public let channelTitle: String?
   public let defaultImage: Image
   public let mediumImage: Image
   public let highImage: Image
}

public func == (lhs: Snippet, rhs: Snippet) -> Bool {
   return lhs.title == rhs.title &&
      lhs.publishDate == rhs.publishDate &&
      lhs.defaultImage == rhs.defaultImage &&
      lhs.mediumImage == rhs.mediumImage &&
      lhs.highImage == rhs.highImage &&
      lhs.channelId == rhs.channelId &&
      lhs.channelTitle == rhs.channelTitle
}
