import Foundation
import ReactiveCocoa
import SwiftyJSON
import enum Result.NoError

public final class Engine {
   public enum Authorization {
      case Key(String)
      case AccessToken(String)
   }

   public var logEnabled = false

   private let session: NSURLSession
   private let authorization: Authorization
   private let baseURL = NSURL(string: "https://www.googleapis.com/youtube/v3")!

   public init(_ authorization: Authorization) {
      self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
      self.authorization = authorization
   }

   public func cancelAllRequests() {
      self.session.invalidateAndCancel()
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
                              objects: page.items.flatMap { $0.video })

            let channelParts =
               self.loadParts(request.channelParts.filter { $0 != request.part },
                              objects: page.items.flatMap { $0.channel })

            return combineLatest(videosParts, channelParts)
               .map { videosById, channelsById -> Page<SearchItem> in
                  let mergedItems: [SearchItem] = page.items.map { item in
                     if let itemVideo = item.video, let video = videosById[itemVideo.id] {
                        return .VideoItem(itemVideo.mergeParts(video))
                     } else if let itemChannel = item.channel, let channel = channelsById[itemChannel.id] {
                        return .ChannelItem(itemChannel.mergeParts(channel))
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

   private func loadParts<T: protocol<JSONRepresentable,
      PartibleObject,
      SearchableObject>>(parts: [Part],
                         objects: [T]) -> SignalProducer<[String: T], NoError> {
      if parts.isEmpty {
         return SignalProducer(value: [:])
      }

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

      var parameters: [String: String] = request.parameters
      switch self.authorization {
      case .AccessToken(let token):
         parameters["access_token"] = token
      case .Key(let key):
         parameters["key"] = key
      }

      let logger: Logger? = self.logEnabled ? DefaultLogger() : nil
      return self.session.jsonSignal(request.method,
                                     url,
                                     parameters: parameters,
                                     logger: logger)
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
