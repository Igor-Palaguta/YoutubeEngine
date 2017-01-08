import Foundation

private extension DateFormatter {
   class func serverDateFormatter(_ format: String) -> Self {
      let formatter = self.init()
      let usLocale = Locale(identifier: "en_US_POSIX")
      formatter.locale = usLocale

      let utcTimezone = TimeZone(abbreviation: "UTC")!

      var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
      calendar.timeZone = utcTimezone
      calendar.locale = usLocale
      formatter.calendar = calendar

      formatter.timeZone = utcTimezone

      formatter.dateFormat = format

      return formatter
   }
}

let ISO8601Formatter = DateFormatter.serverDateFormatter("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
