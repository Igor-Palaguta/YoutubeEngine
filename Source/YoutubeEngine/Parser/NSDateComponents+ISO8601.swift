import Foundation

extension DateComponents {
    init(ISO8601String: String) throws {
        guard let unitValues = ISO8601String.durationUnitValues else {
            throw ISO8601DateComponentsFormatError()
        }

        self.init()
        for (unit, value) in unitValues {
            setValue(value, for: unit)
        }
    }
}

struct ISO8601DateComponentsFormatError: Error {}

private extension String {
    private static let dateUnitMapping: [Character: Calendar.Component] = [
        "Y": .year,
        "M": .month,
        "W": .weekOfYear,
        "D": .day
    ]

    private static let timeUnitMapping: [Character: Calendar.Component] = [
        "H": .hour,
        "M": .minute,
        "S": .second
    ]

    var durationUnitValues: [(Calendar.Component, Int)]? {
        guard hasPrefix("P") else {
            return nil
        }

        let duration = String(dropFirst())

        guard let separatorRange = duration.range(of: "T") else {
            return duration.unitValues(withMapping: String.dateUnitMapping)
        }

        let date = String(duration[..<separatorRange.lowerBound])
        let time = String(duration[separatorRange.upperBound...])

        guard let dateUnits = date.unitValues(withMapping: String.dateUnitMapping),
            let timeUnits = time.unitValues(withMapping: String.timeUnitMapping) else {
            return nil
        }

        return dateUnits + timeUnits
    }

    func unitValues(withMapping mapping: [Character: Calendar.Component]) -> [(Calendar.Component, Int)]? {
        if isEmpty {
            return []
        }

        var components: [(Calendar.Component, Int)] = []

        let identifiersSet = CharacterSet(charactersIn: String(mapping.keys))

        let scanner = Scanner(string: self)
        while !scanner.isAtEnd {
            var value: Int = 0
            if !scanner.scanInt(&value) {
                return nil
            }
            var identifier: NSString?
            if !scanner.scanCharacters(from: identifiersSet, into: &identifier) || identifier?.length != 1 {
                return nil
            }
            // swiftlint:disable:next force_unwrapping
            let unit = mapping[Character(identifier! as String)]!
            components.append((unit, value))
        }
        return components
    }
}
