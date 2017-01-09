import Foundation
import ReactiveSwift
import SwiftyJSON
import enum Result.NoError

public final class Engine {
   public enum Authorization {
      case key(String)
      case accessToken(String)
   }

   public var logEnabled = false

   private let session: URLSession
   private let authorization: Authorization
   private let baseURL = URL(string: "https://www.googleapis.com/youtube/v3")!

   public init(_ authorization: Authorization) {
      self.session = URLSession(configuration: URLSessionConfiguration.default)
      self.authorization = authorization
   }

   public func cancelAllRequests() {
      self.session.invalidateAndCancel()
   }

   public func videos(_ request: Videos) -> SignalProducer<Page<Video>, NSError> {
      return self.page(for: request)
   }

   public func channels(_ request: Channels) -> SignalProducer<Page<Channel>, NSError> {
      return self.page(for: request)
   }

   public func search(_ request: Search) -> SignalProducer<Page<SearchItem>, NSError> {
      return self.page(for: request)
         .flatMap(.latest) { page -> SignalProducer<Page<SearchItem>, NSError> in

            let videosParts =
               self.load(parts: request.videoParts.filter { $0 != request.part },
                         for: page.items.flatMap { $0.video })

            let channelParts =
               self.load(parts: request.channelParts.filter { $0 != request.part },
                         for: page.items.flatMap { $0.channel })

            return SignalProducer.combineLatest(videosParts, channelParts)
               .map { videosById, channelsById -> Page<SearchItem> in
                  let mergedItems: [SearchItem] = page.items.map { item in
                     if let itemVideo = item.video, let video = videosById[itemVideo.id] {
                        return .videoItem(itemVideo.merge(with: video))
                     } else if let itemChannel = item.channel, let channel = channelsById[itemChannel.id] {
                        return .channelItem(itemChannel.merge(with: channel))
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

   private func load<T: JSONRepresentable & PartibleObject & SearchableObject>(
      parts: [Part],
      for objects: [T]) -> SignalProducer<[String: T], NoError> {
      if parts.isEmpty {
         return SignalProducer(value: [:])
      }

      if objects.isEmpty {
         return SignalProducer(value: [:])
      }

      return self.page(for: T.request(for: parts, objects: objects))
         .map { page in
            var objectsById: [String: T] = [:]
            page.items.forEach {
               objectsById[$0.id] = $0
            }
            return objectsById
         }
         .flatMapError { _ in SignalProducer(value: [:]) }
   }

   private func json(for request: YoutubeRequest) -> SignalProducer<JSON, NSError> {
      let url = self.baseURL.appendingPathComponent(request.command)

      var parameters: [String: String] = request.parameters
      switch self.authorization {
      case .accessToken(let token):
         parameters["access_token"] = token
      case .key(let key):
         parameters["key"] = key
      }

      let logger: Logger? = self.logEnabled ? DefaultLogger() : nil
      return self.session.jsonSignal(request.method,
                                     url,
                                     parameters: parameters,
                                     logger: logger)
   }

   private func page<R: PageRequest>(for request: R) -> SignalProducer<Page<R.Item>, NSError> where R.Item: JSONRepresentable {
      return self.json(for: request)
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
