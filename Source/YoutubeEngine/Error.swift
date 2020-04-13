import Foundation

enum YoutubeEngineError: Int, Error {
    case requestFailed
    case invalidURL
    case invalidJSON
}

struct YoutubeAPIError: Error {
    let code: Int
    let message: String
}

extension YoutubeAPIError: CustomNSError {
    var errorCode: Int {
        return code
    }

    var errorUserInfo: [String: Any] {
        return [NSLocalizedDescriptionKey: message]
    }
}

extension YoutubeAPIError: Decodable {
    private enum CodingKeys: String, CodingKey {
        case error
    }

    private enum ErrorCodingKeys: String, CodingKey {
        case code
        case message
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let errorContainer = try container.nestedContainer(keyedBy: ErrorCodingKeys.self, forKey: .error)
        self.code = try errorContainer.decode(Int.self, forKey: .code)
        self.message = try errorContainer.decode(String.self, forKey: .message)
    }
}
