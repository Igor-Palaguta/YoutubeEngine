import Foundation
import ReactiveCocoa
import Alamofire
import SwiftyJSON
import enum Result.NoError

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

   public func videos(request: Videos) -> SignalProducer<Page<Video>, NSError> {
      return self.page(request)
   }

   public func channels(request: Channels) -> SignalProducer<Page<Channel>, NSError> {
      return self.page(request)
   }

   public func search(request: Search) -> SignalProducer<Page<SearchItem>, NSError> {
      return self.page(request)
         .flatMap(.Latest) { page -> SignalProducer<Page<SearchItem>, NSError> in

            let videosParts =
               self.loadParts(request.videoParts.filter { $0 != request.part },
                              items: page.items,
                              type: Video.self)

            let channelParts =
               self.loadParts(request.channelParts.filter { $0 != request.part },
                              items: page.items,
                              type: Channel.self)

            return combineLatest(videosParts, channelParts)
               .map { videosById, channelsById -> Page<SearchItem> in
                  let mergedItems: [SearchItem] = page.items.map { item in
                     if let itemVideo = item.video, let video = videosById[itemVideo.id] {
                        return itemVideo.mergeParts(video).toSearchItem()
                     } else if let itemChannel = item.channel, let channel = channelsById[itemChannel.id] {
                        return itemChannel.mergeParts(channel).toSearchItem()
                     }
                     return item
                  }
                  return Page(items: mergedItems,
                     totalCount: page.totalCount,
                     nextPageToken: page.nextPageToken,
                     previousPageToken: page.previousPageToken)
               }
               .promoteErrors(NSError.self)
      }
   }

   private func loadParts<T where T: JSONRepresentable, T: PartibleObject, T: SearchableObject>(parts: [Part],
                          items: [SearchItem],
                          type: T.Type) -> SignalProducer<[String: T], NoError> {
      if parts.isEmpty {
         return SignalProducer(value: [:])
      }

      let objects = items.flatMap { T.fromSearchItem($0) }

      if objects.isEmpty {
         return SignalProducer(value: [:])
      }

      return self.page(T.requestForParts(parts, objects: objects))
         .map { page in
            var objectsById: [String: T] = [:]
            page.items.forEach {
               objectsById[$0.id] = $0
            }
            return objectsById
         }
         .flatMapError { _ in SignalProducer(value: [:]) }
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

      let logger: Logger? = self.logEnabled ? DefaultLogger() : nil
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
