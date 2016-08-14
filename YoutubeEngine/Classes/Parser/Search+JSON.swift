import Foundation
import SwiftyJSON

extension SearchItem: JSONRepresentable {
   init?(json: JSON) {
      guard let kind = json["id"]["kind"].string,
         let snippet = Snippet(json: json["snippet"]) else {
            return nil
      }

      let jsonId = json["id"]
      if kind == "youtube#channel", let channelId = jsonId["channelId"].string {
         self = .ChannelItem(Channel(id: channelId, snippet: snippet, statistics: nil))
      } else if kind == "youtube#video", let videoId = jsonId["videoId"].string {
         self = .VideoItem(Video(id: videoId, snippet: snippet, statistics: nil, contentDetails: nil))
      } else {
         return nil
      }
   }
}
