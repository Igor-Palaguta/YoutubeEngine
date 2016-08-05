import Foundation
import SwiftyJSON

extension SearchItem: JSONRepresentable {
   init?(json: JSON) {
      guard let id = json["id"].searchItemId, let snippet = Snippet(json: json["snippet"]) else {
         return nil
      }

      switch id.type {
      case .Channel:
         self = .ChannelItem(Channel(id: id.id, snippet: snippet))
      case .Video:
         self = .VideoItem(Video(id: id.id, snippet: snippet, statistics: nil, contentDetails: nil))
      }
   }
}

private extension JSON {
   var searchItemId: (type: Type, id: String)? {
      guard let kind = self["kind"].string else {
         return nil
      }

      if kind == "youtube#channel", let channelId = self["channelId"].string {
         return (.Channel, channelId)
      } else if kind == "youtube#video", let videoId = self["videoId"].string {
         return (.Video, videoId)
      }
      return nil
   }
}
