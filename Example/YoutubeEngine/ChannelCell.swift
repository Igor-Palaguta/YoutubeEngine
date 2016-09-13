import Foundation
import YoutubeEngine
import Kingfisher
import Reusable

final class ChannelCell: UITableViewCell, NibReusable {
   @IBOutlet private weak var thumbnailView: UIImageView!
   @IBOutlet private weak var titleLabel: UILabel!
   @IBOutlet private weak var videosLabel: UILabel!
   @IBOutlet private weak var subscribersLabel: UILabel!

   var channel: Channel! {
      didSet {
         self.thumbnailView.kf_setImageWithURL(channel.snippet?.defaultImage.url,
                                               optionsInfo: [.Transition(.Fade(0.3))])
         self.titleLabel.text = channel.snippet?.title

         self.videosLabel.text = channel.statistics?
            .videos
            .map {
               NSNumberFormatter.localizedStringFromNumber($0, numberStyle: .DecimalStyle) + " videos"
            }

         self.subscribersLabel.text = channel.statistics?.subscribers
            .map {
               NSNumberFormatter.localizedStringFromNumber($0, numberStyle: .DecimalStyle) + " subscribers"
            }
      }
   }

   override func layoutSubviews() {
      super.layoutSubviews()
      self.thumbnailView.layer.cornerRadius = min(self.thumbnailView.bounds.midX, self.thumbnailView.bounds.midY)
   }
}
