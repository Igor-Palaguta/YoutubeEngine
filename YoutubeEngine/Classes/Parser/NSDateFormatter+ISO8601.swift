import Foundation

private extension NSDateFormatter {
   class func serverDateFormatter(format: String) -> Self {
      let formatter = self.init()
      let usLocale = NSLocale(localeIdentifier: "en_US_POSIX")
      formatter.locale = usLocale

      let utcTimezone = NSTimeZone(abbreviation: "UTC")!

      formatter.calendar = {
         $0.timeZone = utcTimezone
         $0.locale = usLocale
         return $0
      }(NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!)

      formatter.timeZone = utcTimezone

      formatter.dateFormat = format

      return formatter
   }
}

let ISO8601Formatter = NSDateFormatter.serverDateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
