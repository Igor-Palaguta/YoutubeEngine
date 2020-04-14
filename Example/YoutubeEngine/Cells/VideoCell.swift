import Kingfisher
import UIKit
import YoutubeEngine

final class VideoCell: UITableViewCell {

    @IBOutlet private var thumbnailView: UIImageView!
    @IBOutlet private var durationBackgroundView: UIView!
    @IBOutlet private var durationLabel: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var channelLabel: UILabel!
    @IBOutlet private var detailsLabel: UILabel!

    var video: Video! {
        didSet {
            // swiftlint:disable:next force_unwrapping
            let snippet = video.snippet!
            
            thumbnailView.kf.setImage(with: ImageResource(downloadURL: snippet.defaultImage.url),
                                      options: [.transition(.fade(0.3))])

            titleLabel.text = snippet.title
            channelLabel.text = snippet.channelTitle

            durationLabel.text = video.contentDetails?.duration.youtubeDurationString
            durationBackgroundView.isHidden = video.contentDetails?.duration == nil

            let views = video.statistics?.viewCount
                .map {
                    NumberFormatter.localizedString(from: NSNumber(value: $0), number: .decimal) + " views"
                }

            let timestamp = video.snippet?.publishDate.timestampString

            if let views = views, let timestamp = timestamp {
                detailsLabel.text = "\(views) • \(timestamp)"
            } else if let views = views {
                detailsLabel.text = views
            } else {
                detailsLabel.text = timestamp
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
        guard let range = range(of: end) else {
            return self
        }
        return String(self[..<range.lowerBound])
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
        return timestampStingToDate(Date())
    }
}
