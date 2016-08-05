import Foundation
import ReactiveCocoa
import Alamofire
import SwiftyJSON

public let YoutubeErrorDomain = "com.spangleapp.Youtube"

public final class Engine {
   public var logEnabled = false

   private let manager: Manager
   private let key: String
   private let baseURL = NSURL(string: "https://www.googleapis.com/youtube/v3")!

   public init(key: String) {
      precondition(!key.isEmpty)
      self.manager = Manager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
      self.key = key
   }

   public func cancelAllRequests() {
      self.manager.session.invalidateAndCancel()
   }

   public func videos(request: VideosRequest) -> SignalProducer<Page<Video>, NSError> {
      return self.page(request)
   }

   public func search(request: SearchRequest) -> SignalProducer<Page<SearchItem>, NSError> {
      return self.page(request)
   }

   public func search(request: SearchRequest, parts: [Part]) -> SignalProducer<Page<SearchItem>, NSError> {
      return self.search(request)
         .flatMap(.Latest) { page -> SignalProducer<Page<SearchItem>, NSError> in

            let parts = Set(parts).subtract(request.parts)

            if parts.isEmpty {
               return SignalProducer(value: page)
            }

            let videoIds = page.items.flatMap { $0.video?.id }

            if videoIds.isEmpty {
               return SignalProducer(value: page)
            }

            return self.videos(.Videos(ids: videoIds, parts: Array(parts)))
               .map { $0.items }
               .map { videos in
                  var videosById: [String: Video] = [:]
                  videos.forEach {
                     videosById[$0.id] = $0
                  }
                  let items: [SearchItem] = page.items.map {
                     if let searchVideo = $0.video, let video = videosById[searchVideo.id] {
                        return SearchItem.VideoItem(searchVideo.merge(video))
                     }
                     return $0
                  }
                  return Page(items: items,
                     totalCount: page.totalCount,
                     nextPageToken: page.nextPageToken,
                     previousPageToken: page.previousPageToken)
            }
      }
   }

   private func jsonForRequest(request: YoutubeRequest) -> SignalProducer<JSON, NSError> {
      #if swift(>=2.3)
         let url = self.baseURL.URLByAppendingPathComponent(request.command)!
      #else
         let url = self.baseURL.URLByAppendingPathComponent(request.command)
      #endif

      var parameters: [String: AnyObject] = ["key": self.key]
      for (name, value) in request.parameters {
         parameters[name] = value
      }

      let logger: Logger? = logEnabled ? DefaultLogger() : nil
      return self.manager.signalForJSON(request.method, url, parameters: parameters, logger: logger)
   }

   private func page<R: PageRequest where R.Item: JSONRepresentable>(request: R) -> SignalProducer<Page<R.Item>, NSError> {
      return self.jsonForRequest(request)
         .map {
            json in
            let items = json["items"]
               .arrayValue
               .flatMap { R.Item(json: $0) }

            return Page(items: items,
               totalCount: json["pageInfo"]["totalResults"].intValue,
               nextPageToken: json["nextPageToken"].string,
               previousPageToken: json["prevPageToken"].string)
      }
   }
}

private extension Video {
   func merge(other: Video) -> Video {
      var mergedVideo = self
      if other.snippet != nil {
         mergedVideo.snippet = other.snippet
      }
      if other.statistics != nil {
         mergedVideo.statistics = other.statistics
      }
      if other.contentDetails != nil {
         mergedVideo.contentDetails = other.contentDetails
      }
      return mergedVideo
   }
}
