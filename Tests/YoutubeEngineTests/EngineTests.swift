import Nimble
import OHHTTPStubs
import ReactiveSwift
import XCTest
@testable import YoutubeEngine

final class EngineTests: XCTestCase {
    private typealias RequestHook = (URLRequest) -> Void

    private let vevoChannel =
        Channel(id: "UC2pmfLm7iq6Ov1UwYrWYkZA",
                snippet:
                ChannelSnippet(title: "Vevo",
                               publishDate: DateFormatter.iso8601WithMilliseconds.date(from: "2006-04-14T17:07:29.000Z")!,
                               defaultImage: Image(url: URL(string: "https://yt3.ggpht.com/-hmxOepMtptM/AAAAAAAAAAI/AAAAAAAAAAA/nzePQZGAM2Y/s88-c-k-no-rj-c0xffffff/photo.jpg")!, size: nil),
                               mediumImage: Image(url: URL(string: "https://yt3.ggpht.com/-hmxOepMtptM/AAAAAAAAAAI/AAAAAAAAAAA/nzePQZGAM2Y/s240-c-k-no-rj-c0xffffff/photo.jpg")!, size: nil),
                               highImage: Image(url: URL(string: "https://yt3.ggpht.com/-hmxOepMtptM/AAAAAAAAAAI/AAAAAAAAAAA/nzePQZGAM2Y/s240-c-k-no-rj-c0xffffff/photo.jpg")!, size: nil)),
                statistics:
                ChannelStatistics(subscriberCount: 12397460,
                                  videoCount: 975))

    private let video1 =
        Video(id: "FASkBnLAHEw",
              snippet:
              VideoSnippet(title: "Vevo - HOT THIS WEEK: Aug 5, 2016",
                           publishDate: DateFormatter.iso8601WithMilliseconds.date(from: "2016-08-05T19:30:01.000Z")!,
                           channelId: "UC2pmfLm7iq6Ov1UwYrWYkZA",
                           channelTitle: "Vevo",
                           defaultImage: Image(url: URL(string: "https://i.ytimg.com/vi/FASkBnLAHEw/default.jpg")!, size: CGSize(width: 120, height: 90)),
                           mediumImage: Image(url: URL(string: "https://i.ytimg.com/vi/FASkBnLAHEw/mqdefault.jpg")!, size: CGSize(width: 320, height: 180)),
                           highImage: Image(url: URL(string: "https://i.ytimg.com/vi/FASkBnLAHEw/hqdefault.jpg")!, size: CGSize(width: 480, height: 360))),
              statistics:
              VideoStatistics(viewCount: 94170,
                              likeCount: 1537,
                              dislikeCount: 78),
              contentDetails: VideoContentDetails(duration: components(minute: 3, second: 25)))

    private let video2 =
        Video(id: "Ho1oF_P3X00",
              snippet:
              VideoSnippet(title: "Top 100 Most Viewed Songs Of All Time (VEVO) (Updated August 2016)",
                           publishDate: DateFormatter.iso8601WithMilliseconds.date(from: "2016-08-03T16:52:56.000Z")!,
                           channelId: "UCVDKPOPmcsZuEjLVqFgQDcg",
                           channelTitle: "TopMusicMafia",
                           defaultImage: Image(url: URL(string: "https://i.ytimg.com/vi/Ho1oF_P3X00/default.jpg")!, size: CGSize(width: 120, height: 90)),
                           mediumImage: Image(url: URL(string: "https://i.ytimg.com/vi/Ho1oF_P3X00/mqdefault.jpg")!, size: CGSize(width: 320, height: 180)),
                           highImage: Image(url: URL(string: "https://i.ytimg.com/vi/Ho1oF_P3X00/hqdefault.jpg")!, size: CGSize(width: 480, height: 360))),
              statistics:
              VideoStatistics(viewCount: 84236,
                              likeCount: 2503,
                              dislikeCount: 70),
              contentDetails: VideoContentDetails(duration: components(minute: 15, second: 15)))

    private var engine: Engine!

    override func setUp() {
        super.setUp()

        engine = Engine(authorization: .key("AIzaSyCgwWIve2NhQOb5IHMdXxDaRHOnDrLdrLg"))
    }

    override func tearDown() {
        super.tearDown()

        removeAllStubs()
    }

    func testAllPartsSearch() {
        addStubs(commandFiles: ["search": "search_VEVO",
                                "videos": "videos_VEVO",
                                "channels": "channels_VEVO"])
        waitUntil(timeout: 1) { done in
            let request = SearchRequest(.term("VEVO", [.video: [.statistics, .contentDetails], .channel: [.statistics]]), limit: 3)
            self.engine.search(request)
                .startWithResult { result in
                    guard case .success(let page) = result else {
                        return
                    }
                    expect(page.items.count) == 3
                    expect(page.nextPageToken) == "CAMQAA"
                    expect(page.totalCount) == 1000000

                    expect(page.items) == [
                        .channelItem(self.vevoChannel),
                        .videoItem(self.video1),
                        .videoItem(self.video2)
                    ]

                    done()
                }
        }
    }

    func testSearchSnippetByDefault() {
        addStubs(commandFiles: ["search": "search_VEVO",
                                "videos": "videos_VEVO",
                                "channels": "channels_VEVO"])

        waitUntil(timeout: 1) { done in
            let request = SearchRequest(.term("VEVO", [.video: [], .channel: []]), limit: 3)
            self.engine.search(request)
                .startWithResult { result in
                    guard case .success(let page) = result else {
                        return
                    }
                    let vevoChannel = Channel(id: self.vevoChannel.id, snippet: self.vevoChannel.snippet)
                    let video1 = Video(id: self.video1.id, snippet: self.video1.snippet)
                    let video2 = Video(id: self.video2.id, snippet: self.video2.snippet)

                    expect(page.items) == [
                        .channelItem(vevoChannel),
                        .videoItem(video1),
                        .videoItem(video2)
                    ]

                    done()
                }
        }
    }

    func testContentType() {
        var videoCalled = false
        var channelsCalled = false
        var justChannelsType = true

        addStub(command: "search", fileName: "search_VEVO") { request in
            let components = NSURLComponents(string: request.url!.absoluteString)
            if let queryItems = components?.queryItems,
                let typeIndex = queryItems.firstIndex(where: { $0.name == "type" }) {
                justChannelsType = queryItems[typeIndex].value == ContentType.channel.requestParameterValue
            }
        }

        addStub(command: "channels", fileName: "channels_VEVO") { _ in channelsCalled = true }
        addStub(command: "videos", fileName: "videos_VEVO") { _ in videoCalled = true }

        waitUntil(timeout: 1) { done in
            let request = SearchRequest(.term("VEVO", [.channel: [.statistics]]), limit: 3)
            self.engine.search(request)
                .startWithResult { result in
                    guard case .success = result else {
                        return
                    }

                    expect(justChannelsType) == true
                    expect(videoCalled) == false
                    expect(channelsCalled) == true
                    done()
                }
        }
    }

    func testIgnoresErrorsForFailedPartRequests() {
        addStubs(commandFiles: ["search": "search_VEVO",
                                "videos": "error",
                                "channels": "channels_VEVO"])

        waitUntil(timeout: 1) { done in
            let request = SearchRequest(.term("VEVO", [.video: [.statistics, .contentDetails], .channel: [.statistics]]), limit: 3)
            self.engine.search(request)
                .startWithResult { result in
                    guard case .success(let page) = result else {
                        return
                    }

                    let video1 = Video(id: self.video1.id, snippet: self.video1.snippet)
                    let video2 = Video(id: self.video2.id, snippet: self.video2.snippet)

                    expect(page.items) == [
                        .channelItem(self.vevoChannel),
                        .videoItem(video1),
                        .videoItem(video2)
                    ]

                    done()
                }
        }
    }

    func testError() {
        addStub(command: "search", fileName: "error")
        waitUntil { done in
            let request = SearchRequest(.term("VEVO", [.video: [], .channel: []]), limit: 1000)
            self.engine.search(request)
                .startWithFailed { error in
                    expect(error.code) == 400
                    expect(error.localizedDescription) == "Invalid value '1000'. Values must be within the range: [0, 50]"
                    done()
                }
        }
    }

    func testCancel() {
        addStub(command: "search", fileName: "search_VEVO")
        let request = SearchRequest(.term("VEVO", [.video: [], .channel: []]), limit: 1000)
        waitUntil { done in
            self.engine.search(request)
                .on(failed: { _ in
                    XCTFail("should never happend")
                })
                .startWithInterrupted {
                    done()
                }
            self.engine.cancelAllRequests()
        }
    }

    func testRequestLivesLongerThanEngine() {
        addStub(command: "channels", fileName: "channels_VEVO")
        waitUntil { done in
            let localEngine = Engine(authorization: .key("TEST"))
            localEngine
                .channels(ChannelRequest(.mine))
                .startWithResult { result in
                    if case .success = result {
                        done()
                    }
                }
        }
    }

    func testChannels() {
        addStub(command: "channels", fileName: "channels_search")
        waitUntil(timeout: 1) { done in
            let localEngine = Engine(authorization: .key("TEST"))
            localEngine
                .channels(ChannelRequest(.byIds(["UC2pmfLm7iq6Ov1UwYrWYkZA"])))
                .startWithResult { result in
                    if case .success(let channels) = result {
                        expect(channels.items) == [self.vevoChannel]
                        done()
                    }
                }
        }
    }

    private func removeAllStubs() {
        HTTPStubs.removeAllStubs()
    }

    private func jsonFile(_ fileName: String) -> HTTPStubsResponse {
        let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "json")!
        let response = fixture(filePath: path, headers: nil)
        response.requestTime(0, responseTime: 0)
        return response
    }

    private func addStub(command: String, response: @escaping HTTPStubsResponseBlock) {
        let condition: HTTPStubsTestBlock = isLastComponent(command)
        _ = stub(condition: condition, response: response)
    }

    private func addStub(command: String, fileName: String, hook: RequestHook? = nil) {
        return addStub(command: command) { request in
            hook?(request)
            return self.jsonFile(fileName)
        }
    }

    private func addStubs(commandFiles: [String: String], hook: RequestHook? = nil) {
        for (command, fileName) in commandFiles {
            addStub(command: command, fileName: fileName, hook: hook)
        }
    }

    private func isLastComponent(_ component: String) -> HTTPStubsTestBlock {
        return { request in
            guard let components = NSURLComponents(url: request.url!, resolvingAgainstBaseURL: false),
                let path = components.path else {
                return false
            }
            let actualCommand = (path as NSString).lastPathComponent
            return component == actualCommand
        }
    }
}
