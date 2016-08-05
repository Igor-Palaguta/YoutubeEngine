import Foundation

extension NSDateComponents {
   convenience init?(ISO8601String string: String) {
      guard let (date, time) = string.durationParts,
         let dateComponents = date.durationComponents,
         let timeComponents = time.durationComponents else {
            return nil
      }

      self.init()

      for (value, identifier) in dateComponents {
         if identifier == "Y" {
            self.year = value
         } else if identifier == "M" {
            self.month = value
         } else if identifier == "D" {
            self.day = value
         }
      }

      for (value, identifier) in timeComponents {
         if identifier == "H" {
            self.hour = value
         } else if identifier == "M" {
            self.minute = value
         } else if identifier == "S" {
            self.second = value
         }
      }
   }
}

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

   var durationComponents: [(Int, String)]? {
      var components: [(Int, String)] = []

      let identifiersSet = NSCharacterSet(charactersInString: "YMDHMS")

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
         components.append((value, identifier! as String))
      }
      return components
   }
}
