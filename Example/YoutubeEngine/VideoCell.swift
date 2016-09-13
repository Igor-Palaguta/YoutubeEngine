import UIKit
import YoutubeEngine
import Kingfisher
import Reusable

final class VideoCell: UITableViewCell, NibReusable {

   @IBOutlet private weak var thumbnailView: UIImageView!
   @IBOutlet private weak var durationBackgroundView: UIView!
   @IBOutlet private weak var durationLabel: UILabel!
   @IBOutlet private weak var titleLabel: UILabel!
   @IBOutlet private weak var channelLabel: UILabel!
   @IBOutlet private weak var detailsLabel: UILabel!

   var video: Video! {
      didSet {
         self.thumbnailView.kf_setImageWithURL(video.snippet?.defaultImage.url,
                                               optionsInfo: [.Transition(.Fade(0.3))])
         self.titleLabel.text = video.snippet?.title
         self.channelLabel.text = video.snippet?.channelTitle

         self.durationLabel.text = video.contentDetails?.duration.youtubeDurationString
         self.durationBackgroundView.hidden = video.contentDetails?.duration == nil

         let views = video.statistics?.views
            .map {
               NSNumberFormatter.localizedStringFromNumber($0, numberStyle: .DecimalStyle) + " views"
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

private extension NSDateComponents {
   var youtubeDurationString: String? {
      let durationFormatter = NSDateComponentsFormatter()
      durationFormatter.unitsStyle = .Positional
      durationFormatter.zeroFormattingBehavior = .Pad
      durationFormatter.allowedUnits = [.Minute, .Second]
      return durationFormatter.stringFromDateComponents(self)
   }
}

private extension String {
   func dropCharactersStarting(end: String) -> String {
      guard let range = self.rangeOfString(end) else {
         return self
      }
      return self.substringToIndex(range.startIndex)
   }
}

private extension NSDate {
   func timestampStingToDate(date: NSDate) -> String? {
      if date.timeIntervalSinceDate(self) < 60 {
         return NSLocalizedString("just now", comment: "")
      }

      let formatter = NSDateComponentsFormatter()
      formatter.unitsStyle = .Short
      formatter.maximumUnitCount = 1
      formatter.allowedUnits = [.Year, .Month, .Day, .Hour, .Minute]

      guard let timeString = formatter.stringFromDate(self, toDate: date) else {
         return nil
      }

      let formatString = NSLocalizedString("%@ ago", comment: "")
      return String(format: formatString, timeString.dropCharactersStarting(","))
   }

   var timestampString: String? {
      return self.timestampStingToDate(NSDate())
   }
}
