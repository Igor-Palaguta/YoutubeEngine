import Foundation

extension DateFormatter {
    static let iso8601WithMilliseconds = makeServerDateFormatter(withFormat: "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")

    private static func makeServerDateFormatter(withFormat format: String) -> DateFormatter {
        let formatter = DateFormatter()
        let usLocale = Locale(identifier: "en_US_POSIX")
        formatter.locale = usLocale

        // swiftlint:disable:next force_unwrapping
        let utcTimezone = TimeZone(abbreviation: "UTC")!

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = utcTimezone
        calendar.locale = usLocale
        formatter.calendar = calendar

        formatter.timeZone = utcTimezone

        formatter.dateFormat = format

        return formatter
    }
}
