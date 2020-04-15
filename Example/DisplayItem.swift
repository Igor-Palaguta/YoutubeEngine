import Foundation
import YoutubeEngine

enum DisplayItem {
    case channel(Channel)
    case video(Video)
    case playlistItem(PlaylistItem)
    case playlist(Playlist)
}

extension SearchItem {
    var displayItem: DisplayItem {
        switch self {
        case .channel(let channel):
            return .channel(channel)
        case .video(let video):
            return .video(video)
        case .playlist(let playlist):
            return .playlist(playlist)
        }
    }
}
