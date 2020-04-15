import Foundation
import Kingfisher
import UIKit
import YoutubeEngine

final class PlaylistCell: UITableViewCell {
    @IBOutlet private var thumbnailView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!

    var playlist: Playlist! {
        didSet {
            // swiftlint:disable:next force_unwrapping
            let snippet = playlist.snippet!

            thumbnailView.kf.setImage(with: ImageResource(downloadURL: snippet.defaultImage.url),
                                      options: [.transition(.fade(0.3))])

            titleLabel.text = snippet.title
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailView.layer.cornerRadius = min(thumbnailView.bounds.midX, thumbnailView.bounds.midY)
    }
}
