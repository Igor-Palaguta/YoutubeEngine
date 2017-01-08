import Quick
import Nimble
import OHHTTPStubs
import ReactiveSwift
@testable import YoutubeEngine

func lastComponentIs(_ component: String) -> OHHTTPStubsTestBlock {
   return { request in
      guard let components = NSURLComponents(url: request.url!, resolvingAgainstBaseURL: false),
         let path = components.path else {
            return false
      }
      let actualCommand = (path as NSString).lastPathComponent
      return component == actualCommand
   }
}

typealias RequestHook = (URLRequest) -> Void

extension XCTestCase {
   func removeAllStubs() {
      OHHTTPStubs.removeAllStubs()
   }

   func jsonFile(_ fileName: String) -> OHHTTPStubsResponse {
      let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json")!
      let response = fixture(filePath: path, headers: nil)
      response.requestTime(0, responseTime: 0)
      return response
   }

   func addStub(command: String, response: @escaping OHHTTPStubsResponseBlock) {
      let condition: OHHTTPStubsTestBlock = lastComponentIs(command)
      _ = stub(condition: condition, response: response)
   }

   func addStub(command: String, fileName: String, hook: RequestHook? = nil) {
      return self.addStub(command: command) { request in
         hook?(request)
         return self.jsonFile(fileName)
      }
   }

   func addStubs(commandFiles: [String: String]) {
      for (command, fileName) in commandFiles {
         self.addStub(command: command, fileName: fileName)
      }
   }
}

class EngineSpec: QuickSpec {
   override func spec() {
      describe("Engine") {
         let vevoChannel =
            Channel(id: "UC2pmfLm7iq6Ov1UwYrWYkZA",
                    snippet:
               ChannelSnippet(title: "Vevo",
                  publishDate: ISO8601Formatter.date(from: "2006-04-14T17:07:29.000Z")!,
                  defaultImage: Image(url: URL(string: "https://yt3.ggpht.com/-hmxOepMtptM/AAAAAAAAAAI/AAAAAAAAAAA/nzePQZGAM2Y/s88-c-k-no-rj-c0xffffff/photo.jpg")!, size: nil),
                  mediumImage: Image(url: URL(string: "https://yt3.ggpht.com/-hmxOepMtptM/AAAAAAAAAAI/AAAAAAAAAAA/nzePQZGAM2Y/s240-c-k-no-rj-c0xffffff/photo.jpg")!, size: nil),
                  highImage: Image(url: URL(string: "https://yt3.ggpht.com/-hmxOepMtptM/AAAAAAAAAAI/AAAAAAAAAAA/nzePQZGAM2Y/s240-c-k-no-rj-c0xffffff/photo.jpg")!, size: nil)
               ),
                    statistics:
               ChannelStatistics(subscribers: 12397460,
                  videos: 975))

         let video1 =
            Video(id: "FASkBnLAHEw",
                  snippet:
               VideoSnippet(title: "Vevo - HOT THIS WEEK: Aug 5, 2016",
                  publishDate: ISO8601Formatter.date(from: "2016-08-05T19:30:01.000Z")!,
                  channelId: "UC2pmfLm7iq6Ov1UwYrWYkZA",
                  channelTitle: "Vevo",
                  defaultImage: Image(url: URL(string: "https://i.ytimg.com/vi/FASkBnLAHEw/default.jpg")!, size: CGSize(width: 120, height: 90)),
                  mediumImage: Image(url: URL(string: "https://i.ytimg.com/vi/FASkBnLAHEw/mqdefault.jpg")!, size: CGSize(width: 320, height: 180)),
                  highImage: Image(url: URL(string: "https://i.ytimg.com/vi/FASkBnLAHEw/hqdefault.jpg")!, size: CGSize(width: 480, height: 360))),
                  statistics:
               VideoStatistics(views: 94170,
                  likes: 1537,
                  dislikes: 78),
                  contentDetails: VideoContentDetails(duration: components(minute: 3, second: 25)))

         let video2 =
            Video(id: "Ho1oF_P3X00",
                  snippet:
               VideoSnippet(title: "Top 100 Most Viewed Songs Of All Time (VEVO) (Updated August 2016)",
                  publishDate: ISO8601Formatter.date(from: "2016-08-03T16:52:56.000Z")!,
                  channelId: "UCVDKPOPmcsZuEjLVqFgQDcg",
                  channelTitle: "TopMusicMafia",
                  defaultImage: Image(url: URL(string: "https://i.ytimg.com/vi/Ho1oF_P3X00/default.jpg")!, size: CGSize(width: 120, height: 90)),
                  mediumImage: Image(url: URL(string: "https://i.ytimg.com/vi/Ho1oF_P3X00/mqdefault.jpg")!, size: CGSize(width: 320, height: 180)),
                  highImage: Image(url: URL(string: "https://i.ytimg.com/vi/Ho1oF_P3X00/hqdefault.jpg")!, size: CGSize(width: 480, height: 360))),
                  statistics:
               VideoStatistics(views: 84236,
                  likes: 2503,
                  dislikes: 70),
                  contentDetails: VideoContentDetails(duration: components(minute: 15, second: 15)))

         let engine = Engine(.key("AIzaSyCgwWIve2NhQOb5IHMdXxDaRHOnDrLdrLg"))
         engine.logEnabled = true
         afterEach {
            self.removeAllStubs()
         }
         it("searches all parts") {
            self.addStubs(commandFiles: ["search": "search_VEVO",
               "videos": "videos_VEVO",
               "channels": "channels_VEVO"])
            waitUntil(timeout: 1) { done in
               let request = Search(.term("VEVO", [.video: [.statistics, .contentDetails], .channel: [.statistics]]), limit: 3)
               engine.search(request)
                  .startWithResult {
                     result in
                     guard case .success(let page) = result else {
                        return
                     }
                     expect(page.items.count) == 3
                     expect(page.nextPageToken) == "CAMQAA"
                     expect(page.totalCount) == 1000000
                     let expectedItems: [SearchItem] =
                        [.channelItem(vevoChannel), .videoItem(video1), .videoItem(video2)]

                     expect(page.items) == expectedItems

                     done()
               }
            }
         }

         it("searches just snippets by default") {
            self.addStubs(commandFiles: ["search": "search_VEVO",
               "videos": "videos_VEVO",
               "channels": "channels_VEVO"])

            waitUntil(timeout: 1) { done in
               let request = Search(.term("VEVO", [.video: [], .channel: []]), limit: 3)
               engine.search(request)
                  .startWithResult {
                     result in
                     guard case .success(let page) = result else {
                        return
                     }
                     let vevoChannel = Channel(id: vevoChannel.id, snippet: vevoChannel.snippet, statistics: nil)
                     let video1 = Video(id: video1.id, snippet: video1.snippet, statistics: nil, contentDetails: nil)
                     let video2 = Video(id: video2.id, snippet: video2.snippet, statistics: nil, contentDetails: nil)

                     let expectedItems: [SearchItem] =
                        [.channelItem(vevoChannel), .videoItem(video1), .videoItem(video2)]

                     expect(page.items) == expectedItems

                     done()
               }
            }
         }

         it("searches just mentioned types") {

            var videoCalled = false
            var channelsCalled = false
            var justChannelsType = true

            self.addStub(command: "search", fileName: "search_VEVO") { request in
               let components = NSURLComponents(string: request.url!.absoluteString)
               if let queryItems = components?.queryItems,
                  let typeIndex = queryItems.index(where: { $0.name == "type" }) {
                     justChannelsType = queryItems[typeIndex].value == Type.channel.parameterValue
               }
            }

            self.addStub(command: "channels", fileName: "channels_VEVO") { _ in channelsCalled = true}
            self.addStub(command: "videos", fileName: "videos_VEVO") { _ in videoCalled = true }

            waitUntil(timeout: 1) { done in
               let request = Search(.term("VEVO", [.channel: [.statistics]]), limit: 3)
               engine.search(request)
                  .startWithResult {
                     result in
                     guard case .success(_) = result else {
                        return
                     }

                     expect(justChannelsType).to(beTrue())
                     expect(videoCalled).to(beFalse())
                     expect(channelsCalled).to(beTrue())
                     done()
               }
            }
         }

         it("ignores errors for failed part requests") {
            self.addStubs(commandFiles: ["search": "search_VEVO",
               "videos": "error",
               "channels": "channels_VEVO"])

            waitUntil(timeout: 1) { done in
               let request = Search(.term("VEVO", [.video: [.statistics, .contentDetails], .channel: [.statistics]]), limit: 3)
               engine.search(request)
                  .startWithResult {
                     result in
                     guard case .success(let page) = result else {
                        return
                     }

                     let video1 = Video(id: video1.id, snippet: video1.snippet, statistics: nil, contentDetails: nil)
                     let video2 = Video(id: video2.id, snippet: video2.snippet, statistics: nil, contentDetails: nil)

                     let expectedItems: [SearchItem] =
                        [.channelItem(vevoChannel), .videoItem(video1), .videoItem(video2)]

                     expect(page.items) == expectedItems
                     
                     done()
               }
            }
         }

         it("fails with proper message") {
            self.addStub(command: "search", fileName: "error")

            waitUntil(timeout: 1) { done in
               let request = Search(.term("VEVO", [.video: [], .channel: []]), limit: 1000)
               engine.search(request)
                  .startWithFailed {
                     error in
                     expect(error.domain) == YoutubeError.Domain
                     expect(error.code) == 400
                     expect(error.localizedDescription) == "Invalid value '1000'. Values must be within the range: [0, 50]"
                     done()
               }
            }
         }

         it("cancels") {
            self.addStub(command: "search", fileName: "search_VEVO")
            let request = Search(.term("VEVO", [.video: [], .channel: []]), limit: 1000)
            waitUntil(timeout: 1) { done in
               engine.search(request)
                  .on(failed: { _ in
                     fatalError()
                     })
                  .startWithInterrupted {
                     done()
               }
               engine.cancelAllRequests()
            }
         }

         it("request lives longer than engine") {
            self.addStub(command: "channels", fileName: "channels_VEVO")
            waitUntil(timeout: 1) { done in
               {
                  let localEngine = Engine(.key("TEST"))
                  localEngine
                     .channels(Channels(.mine))
                     .startWithResult { result in
                        if case .success(_) = result {
                           done()
                        }
                  }
               }()
            }
         }

         it("parses channels") {
            self.addStub(command: "channels", fileName: "channels_search")
            waitUntil(timeout: 1) { done in
               {
                  let localEngine = Engine(.key("TEST"))
                  localEngine
                     .channels(Channels(.byIds(["UC2pmfLm7iq6Ov1UwYrWYkZA"])))
                     .startWithResult { result in
                        if case .success(let channels) = result {
                           expect(channels.items) == [vevoChannel]
                           done()
                        }
                  }
               }()
            }
         }
      }
   }
}
