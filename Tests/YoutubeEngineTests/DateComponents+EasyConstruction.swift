import Foundation

extension DateComponents {
    static func makeComponents(year: Int? = nil,
                               month: Int? = nil,
                               weekOfYear: Int? = nil,
                               day: Int? = nil,
                               hour: Int? = nil,
                               minute: Int? = nil,
                               second: Int? = nil) -> DateComponents {
        var components = DateComponents()
        _ = year.map { components.year = $0 }
        _ = month.map { components.month = $0 }
        _ = day.map { components.day = $0 }
        _ = weekOfYear.map { components.weekOfYear = $0 }
        _ = hour.map { components.hour = $0 }
        _ = minute.map { components.minute = $0 }
        _ = second.map { components.second = $0 }
        return components
    }
}
