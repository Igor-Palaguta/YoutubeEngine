import Nimble
import XCTest
@testable import YoutubeEngine

final class NSDateComponentsISO8601Spec: XCTestCase {
    func testAllComponents() {
        expect(ISO8601("P10Y10M3W3DT20H31M21S")) == components(year: 10, month: 10, weekOfYear: 3, day: 3, hour: 20, minute: 31, second: 21)

        expect(ISO8601("P1Y2M3DT4H5M6S")) == components(year: 1, month: 2, day: 3, hour: 4, minute: 5, second: 6)
    }

    func testJustDate() {
        expect(ISO8601("P1Y2M3D")) == components(year: 1, month: 2, day: 3)
        expect(ISO8601("P4Y")) == components(year: 4)
        expect(ISO8601("P5Y6D")) == components(year: 5, day: 6)
        expect(ISO8601("P1M")) == components(month: 1)
    }

    func testJustTime() {
        expect(ISO8601("PT1M")) == components(minute: 1)
        expect(ISO8601("PT12H10S")) == components(hour: 12, second: 10)
    }

    func testInvalid() {
        expect(ISO8601("P1Z")).to(beNil())
        expect(ISO8601("P1MM")).to(beNil())
        expect(ISO8601("1M")).to(beNil())
        expect(ISO8601("P1H")).to(beNil())
        expect(ISO8601("PT1D")).to(beNil())
    }
}
