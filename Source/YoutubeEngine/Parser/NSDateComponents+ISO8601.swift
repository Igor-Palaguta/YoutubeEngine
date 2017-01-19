import Foundation

func dateComponents(ISO8601String string: String) -> DateComponents? {
   guard let unitValues = string.durationUnitValues else {
      return nil
   }

   var components = DateComponents()
   for (unit, value) in unitValues {
      components.setValue(value, for: unit)
   }
   return components
}

private let dateUnitMapping: [Character: Calendar.Component] = ["Y": .year, "M": .month, "W": .weekOfYear, "D": .day]
private let timeUnitMapping: [Character: Calendar.Component] = ["H": .hour, "M": .minute, "S": .second]

private extension String {
   var durationUnitValues: [(Calendar.Component, Int)]? {
      guard self.hasPrefix("P") else {
         return nil
      }

      let duration = String(self.characters.dropFirst())

      guard let separatorRange = duration.range(of: "T") else {
         return duration.unitValuesWithMapping(dateUnitMapping)
      }

      let date = duration.substring(to: separatorRange.lowerBound)
      let time = duration.substring(from: separatorRange.upperBound)
      guard let dateUnits = date.unitValuesWithMapping(dateUnitMapping),
         let timeUnits = time.unitValuesWithMapping(timeUnitMapping) else {
            return nil
      }

      return dateUnits + timeUnits
   }

   func unitValuesWithMapping(_ mapping: [Character: Calendar.Component]) -> [(Calendar.Component, Int)]? {
      if self.isEmpty {
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
         let unit = mapping[Character(identifier! as String)]!
         components.append((unit, value))
      }
      return components
   }
}
