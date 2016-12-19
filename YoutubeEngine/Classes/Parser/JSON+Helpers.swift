import Foundation
import SwiftyJSON

extension JSON {
   var date: NSDate? {
      return self.string.flatMap { ISO8601Formatter.dateFromString($0) }
   }

   var duration: NSDateComponents? {
      return self.string.flatMap { NSDateComponents(ISO8601String: $0) }
   }
}
