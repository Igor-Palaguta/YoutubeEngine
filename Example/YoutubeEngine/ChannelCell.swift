import Foundation
import Kingfisher
import YoutubeEngine

final class ChannelCell: UITableViewCell {
    @IBOutlet private var thumbnailView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var videosLabel: UILabel!
    @IBOutlet private var subscribersLabel: UILabel!

    var channel: Channel! {
        didSet {
            thumbnailView.kf.setImage(with: ImageResource(downloadURL: channel.snippet!.defaultImage.url),
                                      options: [.transition(.fade(0.3))])

            titleLabel.text = channel.snippet?.title

            videosLabel.text = channel.statistics?
                .videos
                .map {
                    NumberFormatter.localizedString(from: NSNumber(value: $0), number: .decimal) + " videos"
                }

            subscribersLabel.text = channel.statistics?.subscribers
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
