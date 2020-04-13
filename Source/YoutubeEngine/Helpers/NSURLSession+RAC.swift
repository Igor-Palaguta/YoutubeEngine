import Foundation
import ReactiveSwift

protocol Logging {
    func log(_ request: URLRequest)
    func log(_ response: HTTPURLResponse, body: Data?)
    func log(_ error: NSError)
}

struct ConsoleLogger: Logging {
    func log(_ request: URLRequest) {
        // swiftlint:disable:next force_unwrapping
        let logMessage = "\(request.httpMethod!) \(request.url!)"
        print(logMessage)
    }

    func log(_ response: HTTPURLResponse, body: Data?) {
        let bodyString = body.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        // swiftlint:disable:next force_unwrapping
        let logMessage = "\(response.statusCode) \(response.url!)\n\(bodyString)"
        print(logMessage)
    }

    func log(_ error: NSError) {
        print(error.localizedDescription)
    }
}

// swiftlint:disable function_body_length
// swiftlint:disable closure_body_length
extension URLSession {
    final func objectSignal<T: Decodable>(method: HTTPMethod,
                                          url: URL,
                                          parameters: [String: String]?,
                                          logger: Logging?) -> SignalProducer<T, NSError> {
        return SignalProducer { observer, disposable in
            guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: false) else {
                observer.send(error: YoutubeEngineError.invalidURL as NSError)
                return
            }

            if let parameters = parameters {
                components.queryItems = parameters.keys.map {
                    URLQueryItem(name: $0, value: parameters[$0])
                }
            }

            guard let url = components.url else {
                observer.send(error: YoutubeEngineError.invalidURL as NSError)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue

            logger?.log(request)
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    let error = error as NSError
                    if error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled {
                        observer.sendInterrupted()
                    } else {
                        observer.send(error: error)
                    }
                    return
                }

                // swiftlint:disable:next force_cast
                logger?.log(response as! HTTPURLResponse, body: data)

                guard let data = data else {
                    observer.send(error: YoutubeEngineError.invalidJSON as NSError)
                    return
                }

                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(.iso8601WithMilliseconds)

                if let youtubeError = try? decoder.decode(YoutubeAPIError.self, from: data) {
                    observer.send(error: youtubeError as NSError)
                    return
                }

                do {
                    let object = try decoder.decode(T.self, from: data)
                    observer.send(value: object)
                    observer.sendCompleted()
                } catch {
                    observer.send(error: error as NSError)
                }
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
