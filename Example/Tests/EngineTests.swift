import Quick
import Nimble
import Mockingjay
@testable import YoutubeEngine

public typealias Builder = (NSURLRequest) -> (Response)

func lastPathComponent(component: String) -> NSURLRequest -> Bool {
   return { request in
      guard let components = NSURLComponents(string: request.URLString),
         let path = components.path else {
            return false
      }
      let actualCommand = (path as NSString).lastPathComponent
      return component == actualCommand
   }
}

typealias RequestHook = NSURLRequest -> Void

extension XCTestCase {
   func jsonFile(fileName: String) -> Builder {
      let path = NSBundle(forClass: self.dynamicType).pathForResource(fileName, ofType: "json")!
      let data = NSData(contentsOfFile: path)!
      return jsonData(data)
   }

   func stubCommand(command: String, builder: Builder) -> Stub {
      return self.stub(lastPathComponent(command), builder: builder)
   }

   func stubCommand(command: String, fileName: String, hook: RequestHook? = nil) -> Stub {
      return self.stubCommand(command) { request in
         hook?(request)
         return self.jsonFile(fileName)(request)
      }
   }

   func stubCommandFiles(files: [String: String]) {
      for (command, fileName) in files {
         self.stubCommand(command, fileName: fileName)
      }
   }
}

class EngineSpec: QuickSpec {
   override func spec() {
      describe("Engine") {
         let vevoChannel =
            Channel(id: "UC2pmfLm7iq6Ov1UwYrWYkZA",
                    snippet:
               Snippet(title: "Vevo",
                  publishDate: ISO8601Formatter.dateFromString("2006-04-14T17:07:29.000Z")!,
                  thumbnailURL: NSURL(string: "https://yt3.ggpht.com/-hmxOepMtptM/AAAAAAAAAAI/AAAAAAAAAAA/nzePQZGAM2Y/s88-c-k-no-rj-c0xffffff/photo.jpg")!),
                    statistics:
               ChannelStatistics(subscriberCount: "12397460",
                  videoCount: "975"))

         let video1 =
            Video(id: "FASkBnLAHEw",
                  snippet:
               Snippet(title: "Vevo - HOT THIS WEEK: Aug 5, 2016",
                  publishDate: ISO8601Formatter.dateFromString("2016-08-05T19:30:01.000Z")!,
                  thumbnailURL: NSURL(string: "https://i.ytimg.com/vi/FASkBnLAHEw/default.jpg")!),
                  statistics:
               VideoStatistics(viewCount: "94170",
                  likeCount: "1537",
                  dislikeCount: "78"),
                  contentDetails: VideoContentDetails(duration: components(minute: 3, second: 25)))

         let video2 =
            Video(id: "Ho1oF_P3X00",
                  snippet:
               Snippet(title: "Top 100 Most Viewed Songs Of All Time (VEVO) (Updated August 2016)",
                  publishDate: ISO8601Formatter.dateFromString("2016-08-03T16:52:56.000Z")!,
                  thumbnailURL: NSURL(string: "https://i.ytimg.com/vi/Ho1oF_P3X00/default.jpg")!),
                  statistics:
               VideoStatistics(viewCount: "84236",
                  likeCount: "2503",
                  dislikeCount: "70"),
                  contentDetails: VideoContentDetails(duration: components(minute: 15, second: 15)))

         let engine = Engine(key: "TEST")
         afterEach {
            self.removeAllStubs()
         }
         it("searches all parts") {
            self.stubCommandFiles(["search": "search_VEVO",
               "videos": "videos_VEVO",
               "channels": "channels_VEVO"])
            waitUntil(timeout: 1) { done in
               let request = Search(.Term("VEVO", [.Video: [.Statistics, .ContentDetails], .Channel: [.Statistics]]), limit: 3)
               engine.search(request)
                  .startWithNext {
                     page in
                     expect(page.items.count) == 3
                     expect(page.nextPageToken) == "CAMQAA"
                     expect(page.totalCount) == 1000000
                     let expectedItems: [SearchItem] =
                        [.ChannelItem(vevoChannel), .VideoItem(video1), .VideoItem(video2)]

                     expect(page.items) == expectedItems

                     done()
               }
            }
         }

         it("searches just snippets by default") {
            self.stubCommandFiles(["search": "search_VEVO",
               "videos": "videos_VEVO",
               "channels": "channels_VEVO"])

            waitUntil(timeout: 1) { done in
               let request = Search(.Term("VEVO", [.Video: [], .Channel: []]), limit: 3)
               engine.search(request)
                  .startWithNext {
                     page in
                     let vevoChannel = Channel(id: vevoChannel.id, snippet: vevoChannel.snippet, statistics: nil)
                     let video1 = Video(id: video1.id, snippet: video1.snippet, statistics: nil, contentDetails: nil)
                     let video2 = Video(id: video2.id, snippet: video2.snippet, statistics: nil, contentDetails: nil)

                     let expectedItems: [SearchItem] =
                        [.ChannelItem(vevoChannel), .VideoItem(video1), .VideoItem(video2)]

                     expect(page.items) == expectedItems

                     done()
               }
            }
         }

         it("searches just mentioned types") {

            var videoCalled = false
            var channelsCalled = false
            var justChannelsType = true

            self.stubCommand("search", fileName: "search_VEVO") { request in
               let components = NSURLComponents(string: request.URLString)
               if let queryItems = components?.queryItems,
                  let typeIndex = queryItems.indexOf({ $0.name == "type" }) {
                     justChannelsType = queryItems[typeIndex].value == Type.Channel.parameterValue
               }
            }

            self.stubCommand("channels", fileName: "channels_VEVO") { _ in channelsCalled = true}
            self.stubCommand("videos", fileName: "videos_VEVO") { _ in videoCalled = true }

            waitUntil(timeout: 1) { done in
               let request = Search(.Term("VEVO", [.Channel: [.Statistics]]), limit: 3)
               engine.search(request)
                  .startWithNext {
                     page in
                     expect(justChannelsType).to(beTrue())
                     expect(videoCalled).to(beFalse())
                     expect(channelsCalled).to(beTrue())
                     done()
               }
            }
         }

         it("ignores errors for failed part requests") {
            self.stubCommandFiles(["search": "search_VEVO",
               "videos": "error",
               "channels": "channels_VEVO"])

            waitUntil(timeout: 1) { done in
               let request = Search(.Term("VEVO", [.Video: [.Statistics, .ContentDetails], .Channel: [.Statistics]]), limit: 3)
               engine.search(request)
                  .startWithNext {
                     page in
                     let video1 = Video(id: video1.id, snippet: video1.snippet, statistics: nil, contentDetails: nil)
                     let video2 = Video(id: video2.id, snippet: video2.snippet, statistics: nil, contentDetails: nil)

                     let expectedItems: [SearchItem] =
                        [.ChannelItem(vevoChannel), .VideoItem(video1), .VideoItem(video2)]

                     expect(page.items) == expectedItems
                     
                     done()
               }
            }
         }

         it("fails with propert message") {
            self.stubCommand("search", fileName: "error")

            waitUntil(timeout: 1) { done in
               let request = Search(.Term("VEVO", [.Video: [], .Channel: []]), limit: 1000)
               engine.search(request)
                  .startWithFailed {
                     error in
                     expect(error.domain) == YoutubeErrorDomain
                     expect(error.code) == 400
                     expect(error.localizedDescription) == "Invalid value '1000'. Values must be within the range: [0, 50]"
                     done()
               }
            }
         }
      }
   }
}
