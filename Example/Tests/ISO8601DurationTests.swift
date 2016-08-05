// https://github.com/Quick/Quick

import Quick
import Nimble
@testable import YoutubeEngine

private func components(year year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> NSDateComponents {
   let components = NSDateComponents()
   let _ = year.map { components.year = $0 }
   let _ = month.map { components.month = $0 }
   let _ = day.map { components.day = $0 }
   let _ = hour.map { components.hour = $0 }
   let _ = minute.map { components.minute = $0 }
   let _ = second.map { components.second = $0 }
   return components
}

private func ISO8601(string: String) -> NSDateComponents? {
   return NSDateComponents(ISO8601String: string)
}

class NSDateComponentsISO8601Spec: QuickSpec {
   override func spec() {
      describe("ISO8601") {
         context("all components") {
            it("parse") {
               expect(ISO8601("P1Y2M3DT4H5M6S")) == components(year: 1, month: 2, day: 3, hour: 4, minute: 5, second: 6)
            }
         }
         context("just date") {
            it("parse") {
               expect(ISO8601("P1Y2M3D")) == components(year: 1, month: 2, day: 3)
               expect(ISO8601("P4Y")) == components(year: 4)
               expect(ISO8601("P5Y6D")) == components(year: 5, day: 6)
               expect(ISO8601("P1M")) == components(month: 1)
            }
         }
         context("just time") {
            it("parse") {
               expect(ISO8601("PT1M")) == components(minute: 1)
               expect(ISO8601("PT12H10S")) == components(hour: 12, second: 10)
            }
         }
         context("invalid") {
            it("returns nil") {
               expect(ISO8601("P1Z")).to(beNil())
               expect(ISO8601("P1MM")).to(beNil())
               expect(ISO8601("1M")).to(beNil())
            }
         }
      }
   }
}
