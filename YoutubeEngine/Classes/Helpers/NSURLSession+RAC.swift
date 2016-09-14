import Foundation
import ReactiveCocoa
import SwiftyJSON

protocol Logger {
   func logRequest(request: NSURLRequest)
   func logResponse(response: NSHTTPURLResponse, body: NSData?)
   func logError(error: NSError)
}

struct DefaultLogger: Logger {
   func logRequest(request: NSURLRequest) {
      NSLog("%@ %@", request.HTTPMethod!, request.URL!)
   }

   func logResponse(response: NSHTTPURLResponse, body: NSData?) {
      let body = body.flatMap { NSString(data: $0, encoding: NSUTF8StringEncoding) } ?? ""
      NSLog("%d %@\n%@", response.statusCode, response.URL!, body)
   }

   func logError(error: NSError) {
      NSLog("%@", error.localizedDescription)
   }
}

extension NSURLSession {
   final func signalForJSON(method: Method,
                            _ url: NSURL,
                            parameters: [String: String]?,
                            logger: Logger?) -> SignalProducer<JSON, NSError> {
      return SignalProducer {
         observer, disposable in
         guard let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else {
            observer.sendFailed(Error.error(code: .InvalidURL))
            return
         }

         if let parameters = parameters {
            components.queryItems = parameters.keys.map {
               return NSURLQueryItem(name: $0, value: parameters[$0])
            }
         }

         guard let url = components.URL else {
            observer.sendFailed(Error.error(code: .InvalidURL))
            return
         }

         let request = NSMutableURLRequest(URL: url)
         request.HTTPMethod = method.rawValue

         logger?.logRequest(request)
         let task = self.dataTaskWithRequest(request) {
            data, response, error in

            if let error = error {
               if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                  observer.sendInterrupted()
               } else {
                  observer.sendFailed(error)
               }
               return
            }

            logger?.logResponse(response as! NSHTTPURLResponse, body: data)

            guard let data = data,
               let JSONObject = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) else {
                  observer.sendFailed(Error.error(code: .InvalidJSON))
                  return
            }

            let json = JSON(JSONObject)
            if let error = Error.error(json) {
               observer.sendFailed(error)
               return
            }

            observer.sendNext(json)
            observer.sendCompleted()
         }

         task.resume()

         disposable.addDisposable {
            task.cancel()
         }
         }
         .on(failed: { error in
            logger?.logError(error)
         })
         .observeOn(UIScheduler())
   }
}
