import Foundation

enum Method: String {
   case GET
   case POST
   case PUT
   case DELETE
}

protocol YoutubeRequest {
   var method: Method { get }
   var command: String { get }
   var parameters: [String: String] { get }
}

protocol PageRequest: YoutubeRequest {
   associatedtype Item
   var pageToken: String? { get }
   var limit: Int? { get }
}

struct AnyPageRequest<ItemType>: PageRequest {
   typealias Item = ItemType
   let method: Method
   let command: String
   let parameters: [String: String]
   let pageToken: String?
   let limit: Int?

   init<R: PageRequest where R.Item == Item>(_ request: R) {
      self.method = request.method
      self.command = request.command
      self.parameters = request.parameters
      self.pageToken = request.pageToken
      self.limit = request.limit
   }
}
