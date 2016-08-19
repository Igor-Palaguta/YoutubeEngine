import Foundation

extension NSDateComponents {
   convenience init?(ISO8601String string: String) {
      guard let unitValues = string.durationUnitValues else {
         return nil
      }

      self.init()

      for (unit, value) in unitValues {
         self.setValue(value, forComponent: unit)
      }
   }
}

private let dateUnitMapping: [Character: NSCalendarUnit] = ["Y": .Year, "M": .Month, "D": .Day]
private let timeUnitMapping: [Character: NSCalendarUnit] = ["H": .Hour, "M": .Minute, "S": .Second]

private extension String {
   var durationUnitValues: [(NSCalendarUnit, Int)]? {
      guard self.hasPrefix("P") else {
         return nil
      }

      let duration = self.substringFromIndex(self.startIndex.advancedBy(1))

      guard let separatorRange = duration.rangeOfString("T") else {
         return duration.unitValuesWithMapping(dateUnitMapping)
      }

      let date = duration.substringToIndex(separatorRange.startIndex)
      let time = duration.substringFromIndex(separatorRange.endIndex)
      guard let dateUnits = date.unitValuesWithMapping(dateUnitMapping),
         let timeUnits = time.unitValuesWithMapping(timeUnitMapping) else {
            return nil
      }

      return dateUnits + timeUnits
   }

   func unitValuesWithMapping(mapping: [Character: NSCalendarUnit]) -> [(NSCalendarUnit, Int)]? {
      if self.isEmpty {
         return []
      }

      var components: [(NSCalendarUnit, Int)] = []

      let identifiersSet = NSCharacterSet(charactersInString: String(mapping.keys))

      let scanner = NSScanner(string: self)
      while !scanner.atEnd {
         var value: Int = 0
         if !scanner.scanInteger(&value) {
            return nil
         }
         var identifier: NSString?
         if !scanner.scanCharactersFromSet(identifiersSet, intoString: &identifier) || identifier?.length != 1 {
            return nil
         }
         let unit = mapping[Character(identifier! as String)]!
         components.append((unit, value))
      }
      return components
   }
}
