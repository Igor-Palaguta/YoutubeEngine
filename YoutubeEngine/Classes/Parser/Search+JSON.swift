import Foundation
import SwiftyJSON

extension SearchItem: JSONRepresentable {
   init?(json: JSON) {
      guard let kind = json["id"]["kind"].string else {
         return nil
      }

      let jsonId = json["id"]
      if kind == "youtube#channel",
         let channelId = jsonId["channelId"].string,
         let snippet = ChannelSnippet(json: json["snippet"]) {
         self = .channelItem(Channel(id: channelId, snippet: snippet, statistics: nil))
      } else if kind == "youtube#video",
         let videoId = jsonId["videoId"].string,
         let snippet = VideoSnippet(json: json["snippet"]) {
         self = .videoItem(Video(id: videoId, snippet: snippet, statistics: nil, contentDetails: nil))
      } else {
         return nil
      }
   }
}
