import Foundation
import Alamofire
import SwiftyJSON
import ReactiveCocoa

protocol Logger {
   func logRequest(request: NSURLRequest, parameters: [String: AnyObject]?)
   func logResponse(response: NSHTTPURLResponse, body: NSData?)
   func logError(error: NSError)
}

struct DefaultLogger: Logger {
   func logRequest(request: NSURLRequest, parameters: [String: AnyObject]?) {
      NSLog("%@ %@", request.HTTPMethod!, request.URL!)
      if let parameters = parameters {
         NSLog("%@", parameters)
      }
   }

   func logResponse(response: NSHTTPURLResponse, body: NSData?) {
      let body = body.flatMap { NSString(data: $0, encoding: NSUTF8StringEncoding) } ?? ""
      NSLog("%d %@\n%@", response.statusCode, response.URL!, body)
   }

   func logError(error: NSError) {
      NSLog("%@", error.localizedDescription)
   }
}

extension Manager {

   final func signalForJSON(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String: AnyObject]? = nil, headers: [String: String]? = nil, logger: Logger?) -> SignalProducer<JSON, NSError> {
      return SignalProducer {
         observer, disposable in
         let encoding: ParameterEncoding = method == .GET ? .URL : .JSON
         let request = self.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)

         logger?.logRequest(request.request!, parameters: parameters)

         request.responseJSON {
            response in

            if let HTTPResponse = response.response {
               logger?.logResponse(HTTPResponse, body: response.data)
            }

            switch response.result {
            case .Success(let value):
               guard let json = JSON(rawValue: value) else {
                  observer.sendFailed(NSError(domain: YoutubeErrorDomain, code: 1, userInfo: nil))
                  return
               }

               if let error = NSError.errorWithJSON(json) {
                  observer.sendFailed(error)
               } else {
                  observer.sendNext(json)
                  observer.sendCompleted()
               }
            case .Failure(let error):
               observer.sendFailed(error)
            }
         }
         disposable.addDisposable {
            request.cancel()
         }
         }
         .on(failed: {
            error in
            logger?.logError(error)
         })

   }
}
