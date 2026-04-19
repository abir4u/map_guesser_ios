//
//  NetworkClientTests.swift
//  Map Guessr
//
//  Created by Abir Pal on 19/04/2026.
//

import XCTest
@testable import Map_Guessr

final class NetworkClientTests: XCTestCase {
    var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
    }

    override func tearDown() {
        mockSession = nil
        super.tearDown()
    }

    func test_request_throwsErrorOnNon200Response() async {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(url: URL(string: "https://test.com")!,
                                           statusCode: 404,
                                           httpVersion: nil,
                                           headerFields: nil)!
            return (response, Data())
        }
        
        do {
            let _: CountryResponse = try await NetworkClient.request(URL(string: "https://test.com")!, session: mockSession)
            XCTFail("Should have thrown badServerResponse")
        } catch {
            XCTAssertEqual((error as? URLError)?.code, .badServerResponse)
        }
    }
}
