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

private let dateUnitMapping: [String: NSCalendarUnit] = ["Y": .Year, "M": .Month, "D": .Day]
private let timeUnitMapping: [String: NSCalendarUnit] = ["H": .Hour, "M": .Minute, "S": .Second]

private extension String {
   var durationParts: (date: String, time: String)? {
      guard self.hasPrefix("P") else {
         return nil
      }

      let duration = self.substringFromIndex(self.startIndex.advancedBy(1))

      if let separatorRange = duration.rangeOfString("T") {
         let date = duration.substringToIndex(separatorRange.startIndex)
         let time = duration.substringFromIndex(separatorRange.endIndex)
         return (date, time)
      }

      return (duration, "")
   }

   var durationUnitValues: [(NSCalendarUnit, Int)]? {
      guard let (date, time) = self.durationParts,
         let dateUnitValues = date.unitValuesWithMapping(dateUnitMapping),
         let timeUnitValues = time.unitValuesWithMapping(timeUnitMapping) else {
            return nil
      }

      return dateUnitValues + timeUnitValues
   }

   func unitValuesWithMapping(mapping: [String: NSCalendarUnit]) -> [(NSCalendarUnit, Int)]? {
      var components: [(NSCalendarUnit, Int)] = []

      let identifiersSet = NSCharacterSet(charactersInString: mapping.keys.joinWithSeparator(""))

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
         let unit = mapping[identifier! as String]!
         components.append((unit, value))
      }
      return components
   }
}
