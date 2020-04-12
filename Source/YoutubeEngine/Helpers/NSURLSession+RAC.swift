import Foundation
import ReactiveSwift
import SwiftyJSON

protocol Logger {
    func log(_ request: URLRequest)
    func log(_ response: HTTPURLResponse, body: Data?)
    func log(_ error: NSError)
}

struct DefaultLogger: Logger {
    func log(_ request: URLRequest) {
        let logMessage = "\(request.httpMethod!) \(request.url!)"
        print(logMessage)
    }

    func log(_ response: HTTPURLResponse, body: Data?) {
        let bodyString = body.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        let logMessage = "\(response.statusCode) \(response.url!)\n\(bodyString)"
        print(logMessage)
    }

    func log(_ error: NSError) {
        print(error.localizedDescription)
    }
}

extension URLSession {
    final func jsonSignal(_ method: Method,
                          _ url: URL,
                          parameters: [String: String]?,
                          logger: Logger?) -> SignalProducer<JSON, NSError> {
        return SignalProducer { observer, disposable in
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

            logger?.log(request)
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

                logger?.log(response as! HTTPURLResponse, body: data)

                guard let data = data,
                    let JSONObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else {
                    observer.send(error: YoutubeError.error(code: .invalidJSON))
                    return
                }

                let json = JSON(JSONObject)
                if let error = YoutubeError.makeError(from: json) {
                    observer.send(error: error)
                    return
                }

                observer.send(value: json)
                observer.sendCompleted()
            }

            task.resume()

            disposable.observeEnded {
                task.cancel()
            }
        }
        .on(failed: { error in
            logger?.log(error)
         })
        .observe(on: UIScheduler())
    }
}
