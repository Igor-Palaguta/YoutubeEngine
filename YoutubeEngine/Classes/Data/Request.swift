import Foundation
import enum Alamofire.Method

protocol YoutubeRequest {
   var method: Method { get }
   var command: String { get }
   var parameters: [String: AnyObject] { get }
}

protocol PageRequest: YoutubeRequest {
   associatedtype Item
}

extension SearchRequest: PageRequest {

   typealias Item = SearchItem

   var method: Method {
      return .GET
   }

   var command: String {
      return "search"
   }

   var parameters: [String: AnyObject] {

      var parameters: [String: AnyObject] = ["part": self.parts.joinParameters(),
                                             "type": self.types.joinParameters()]

      if let pageToken = self.pageToken {
         parameters["pageToken"] = pageToken
      }

      switch self {
      case .Search(let query, _, _):
         parameters["q"] = query
      case .Channel(let channelId, _):
         parameters["channelId"] = channelId
      case .Related(let videoId, _):
         parameters["videoId"] = videoId
      }

      return parameters
   }
}

extension VideosRequest: PageRequest {

   typealias Item = Video

   var method: Method {
      return .GET
   }

   var command: String {
      return "videos"
   }

   var parameters: [String: AnyObject] {

      var parameters: [String: AnyObject] = ["part": self.parts.joinParameters()]

      switch self {
      case .Popular(_):
         parameters["chart"] = "mostPopular"
      case .Videos(let ids, _):
         parameters["id"] = ids.joinWithSeparator(",")
      }

      return parameters
   }
}
