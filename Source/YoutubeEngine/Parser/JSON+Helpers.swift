import Foundation
import SwiftyJSON

extension JSON {
    var date: Date? {
        return string.flatMap { ISO8601Formatter.date(from: $0) }
    }

    var duration: DateComponents? {
        return string.flatMap { dateComponents(ISO8601String: $0) }
    }
}
