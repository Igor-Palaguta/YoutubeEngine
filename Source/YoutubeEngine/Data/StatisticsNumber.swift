import Foundation

struct StatisticsNumber {
    let value: Int
}

extension StatisticsNumber: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        guard let value = Int(try container.decode(String.self)) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid statistics number")
        }
        self.value = value
    }
}
