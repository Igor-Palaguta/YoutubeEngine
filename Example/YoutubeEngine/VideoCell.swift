import UIKit
import YoutubeEngine
import Kingfisher

final class VideoCell: UITableViewCell {

   @IBOutlet private weak var thumbnailView: UIImageView!
   @IBOutlet private weak var durationBackgroundView: UIView!
   @IBOutlet private weak var durationLabel: UILabel!
   @IBOutlet private weak var titleLabel: UILabel!
   @IBOutlet private weak var channelLabel: UILabel!
   @IBOutlet private weak var detailsLabel: UILabel!

   var video: Video! {
      didSet {
         self.thumbnailView.kf_setImage(with: ImageResource(downloadURL: video.snippet!.defaultImage.url),
                                        options: [.transition(.fade(0.3))])
         self.titleLabel.text = video.snippet?.title
         self.channelLabel.text = video.snippet?.channelTitle

         self.durationLabel.text = video.contentDetails?.duration.youtubeDurationString
         self.durationBackgroundView.isHidden = video.contentDetails?.duration == nil

         let views = video.statistics?.views
            .map {
               NumberFormatter.localizedString(from: NSNumber(value: $0), number: .decimal) + " views"
         }

         let timestamp = video.snippet?.publishDate.timestampString

         if let views = views, let timestamp = timestamp {
            self.detailsLabel.text = "\(views) • \(timestamp)"
         } else if let views = views {
            self.detailsLabel.text = views
         } else {
            self.detailsLabel.text = timestamp
         }
      }
   }
}

private extension DateComponents {
   var youtubeDurationString: String? {
      let durationFormatter = DateComponentsFormatter()
      durationFormatter.unitsStyle = .positional
      durationFormatter.zeroFormattingBehavior = .pad
      durationFormatter.allowedUnits = [.minute, .second]
      return durationFormatter.string(from: self)
   }
}

private extension String {
   func dropCharactersStarting(_ end: String) -> String {
      guard let range = self.range(of: end) else {
         return self
      }
      return self.substring(to: range.lowerBound)
   }
}

private extension Date {
   func timestampStingToDate(_ date: Date) -> String? {
      if date.timeIntervalSince(self) < 60 {
         return NSLocalizedString("just now", comment: "")
      }

      let formatter = DateComponentsFormatter()
      formatter.unitsStyle = .short
      formatter.maximumUnitCount = 1
      formatter.allowedUnits = [.year, .month, .day, .hour, .minute]

      guard let timeString = formatter.string(from: self, to: date) else {
         return nil
      }

      let formatString = NSLocalizedString("%@ ago", comment: "")
      return String(format: formatString, timeString.dropCharactersStarting(","))
   }

   var timestampString: String? {
      return self.timestampStingToDate(Date())
   }
}
