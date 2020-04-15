import Nimble
import XCTest
@testable import YoutubeEngine

final class NSDateComponentsISO8601Spec: XCTestCase {
    func testAllComponents() {
        expect(self.ISO8601("P10Y10M3W3DT20H31M21S")) == .makeComponents(year: 10, month: 10, weekOfYear: 3, day: 3, hour: 20, minute: 31, second: 21)

        expect(self.ISO8601("P1Y2M3DT4H5M6S")) == .makeComponents(year: 1, month: 2, day: 3, hour: 4, minute: 5, second: 6)
    }

    func testJustDate() {
        expect(self.ISO8601("P1Y2M3D")) == .makeComponents(year: 1, month: 2, day: 3)
        expect(self.ISO8601("P4Y")) == .makeComponents(year: 4)
        expect(self.ISO8601("P5Y6D")) == .makeComponents(year: 5, day: 6)
        expect(self.ISO8601("P1M")) == .makeComponents(month: 1)
    }

    func testJustTime() {
        expect(self.ISO8601("PT1M")) == .makeComponents(minute: 1)
        expect(self.ISO8601("PT12H10S")) == .makeComponents(hour: 12, second: 10)
    }

    func testInvalid() {
        expect(self.ISO8601("P1Z")).to(beNil())
        expect(self.ISO8601("P1MM")).to(beNil())
        expect(self.ISO8601("1M")).to(beNil())
        expect(self.ISO8601("P1H")).to(beNil())
        expect(self.ISO8601("PT1D")).to(beNil())
    }

    private func ISO8601(_ string: String) -> DateComponents? {
        return try? DateComponents(ISO8601String: string)
    }
}
