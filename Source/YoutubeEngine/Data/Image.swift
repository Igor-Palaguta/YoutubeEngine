import CoreGraphics
import Foundation

public struct Image: Equatable {
    public let url: URL
    public let size: CGSize?
}

extension Image: Decodable {
    private enum CodingKeys: String, CodingKey {
        case url
        case width
        case height
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.url = try container.decode(URL.self, forKey: .url)

        if let width = try container.decodeIfPresent(Int.self, forKey: .width),
            let height = try container.decodeIfPresent(Int.self, forKey: .height) {
            self.size = CGSize(width: width, height: height)
        } else {
            self.size = nil
        }
    }
}
