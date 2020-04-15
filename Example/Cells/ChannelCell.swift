import Foundation
import Kingfisher
import UIKit
import YoutubeEngine

final class ChannelCell: UITableViewCell {
    @IBOutlet private var thumbnailView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var videosLabel: UILabel!
    @IBOutlet private var subscribersLabel: UILabel!

    var channel: Channel! {
        didSet {
            // swiftlint:disable:next force_unwrapping
            let snippet = channel.snippet!
            thumbnailView.kf.setImage(with: ImageResource(downloadURL: snippet.defaultImage.url),
                                      options: [.transition(.fade(0.3))])

            titleLabel.text = snippet.title

            videosLabel.text = channel.statistics?
                .videoCount
                .map {
                    NumberFormatter.localizedString(from: NSNumber(value: $0), number: .decimal) + " videos"
                }

            subscribersLabel.text = channel.statistics?.subscriberCount
                .map {
                    NumberFormatter.localizedString(from: NSNumber(value: $0), number: .decimal) + " subscribers"
                }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnailView.layer.cornerRadius = min(thumbnailView.bounds.midX, thumbnailView.bounds.midY)
    }
}
