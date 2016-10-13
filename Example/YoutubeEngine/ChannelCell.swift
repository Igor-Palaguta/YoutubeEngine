import Foundation
import YoutubeEngine
import Kingfisher

final class ChannelCell: UITableViewCell {
   @IBOutlet private weak var thumbnailView: UIImageView!
   @IBOutlet private weak var titleLabel: UILabel!
   @IBOutlet private weak var videosLabel: UILabel!
   @IBOutlet private weak var subscribersLabel: UILabel!

   var channel: Channel! {
      didSet {
         self.thumbnailView.kf.setImage(with: ImageResource(downloadURL: channel.snippet!.defaultImage.url),
                                        options: [.transition(.fade(0.3))])
         self.titleLabel.text = channel.snippet?.title

         self.videosLabel.text = channel.statistics?
            .videos
            .map {
               NumberFormatter.localizedString(from: NSNumber(value: $0), number: .decimal) + " videos"
            }

         self.subscribersLabel.text = channel.statistics?.subscribers
            .map {
               NumberFormatter.localizedString(from: NSNumber(value: $0), number: .decimal) + " subscribers"
            }
      }
   }

   override func layoutSubviews() {
      super.layoutSubviews()
      self.thumbnailView.layer.cornerRadius = min(self.thumbnailView.bounds.midX, self.thumbnailView.bounds.midY)
   }
}
