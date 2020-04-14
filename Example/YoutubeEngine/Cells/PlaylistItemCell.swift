import Foundation
import Kingfisher
import YoutubeEngine

final class PlaylistItemCell: UITableViewCell {
    @IBOutlet private var thumbnailView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    var playlistItem: PlaylistItem! {
        didSet {
            // swiftlint:disable:next force_unwrapping
            let snippet = playlistItem.snippet!
            thumbnailView.kf.setImage(with: ImageResource(downloadURL: snippet.defaultImage.url),
                                      options: [.transition(.fade(0.3))])

            titleLabel.text = snippet.title
        }
    }
}
