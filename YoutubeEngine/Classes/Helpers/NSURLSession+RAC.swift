import Foundation
import ReactiveSwift
import SwiftyJSON

protocol Logger {
   func log(request: URLRequest)
   func log(response: HTTPURLResponse, body: Data?)
   func log(error: NSError)
}

struct DefaultLogger: Logger {
   func log(request: URLRequest) {
      NSLog("%@ %@", [request.httpMethod!, request.url!])
   }

   func log(response: HTTPURLResponse, body: Data?) {
      let body = body.flatMap { NSString(data: $0, encoding: String.Encoding.utf8.rawValue) } ?? ""
      NSLog("%d %@\n%@", [response.statusCode, response.url!, body])
   }

   func log(error: NSError) {
      NSLog("%@", error.localizedDescription)
   }
}

extension URLSession {
   final func jsonSignal(_ method: Method,
                         _ url: URL,
                         parameters: [String: String]?,
                         logger: Logger?) -> SignalProducer<JSON, NSError> {
      return SignalProducer {
         observer, disposable in
         guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) else {
            observer.send(error: YoutubeError.error(code: .invalidURL))
            return
         }

         if let parameters = parameters {
            components.queryItems = parameters.keys.map {
               return URLQueryItem(name: $0, value: parameters[$0])
            }
         }

         guard let url = components.url else {
            observer.send(error: YoutubeError.error(code: .invalidURL))
            return
         }

         var request = URLRequest(url: url)
         request.httpMethod = method.rawValue

         logger?.log(request: request)
         let task = self.dataTask(with: request) {
            data, response, error in

            if let error = error {
               let error = error as NSError
               if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                  observer.sendInterrupted()
               } else {
                  observer.send(error: error)
               }
               return
            }

            logger?.log(response: response as! HTTPURLResponse, body: data)

            guard let data = data,
               let JSONObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
                  observer.send(error: YoutubeError.error(code: .invalidJSON))
                  return
            }

            let json = JSON(JSONObject)
            if let error = YoutubeError.error(json: json) {
               observer.send(error: error)
               return
            }

            observer.send(value: json)
            observer.sendCompleted()
         }

         task.resume()

         disposable.add {
            task.cancel()
         }
         }
         .on(failed: { error in
            logger?.log(error: error)
         })
         .observe(on: UIScheduler())
   }
}
