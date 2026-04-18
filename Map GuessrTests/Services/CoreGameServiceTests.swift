//
//  CoreGameServiceTests.swift
//  Map Guessr
//
//  Created by Abir Pal on 19/04/2026.
//

import XCTest
import SwiftUI
@testable import Map_Guessr

final class CoreGameServiceTests: XCTestCase {
    var sut: CoreGameService!
    var mockSession: URLSession!

    @MainActor
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)
        
        sut = CoreGameService(session: mockSession)
    }

    override func tearDown() {
        sut = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    // MARK: - getCountryNames Tests
    
    @MainActor
    func test_getCountryNames_returnsListOnSuccess() async {
        let jsonString = """
        { "countries": ["New Zealand", "Australia", "Japan"] }
        """
        let data = jsonString.data(using: .utf8)!
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let countries = await sut.getCountryNames()

        XCTAssertEqual(countries.count, 3)
        XCTAssertEqual(countries.first, "New Zealand")
    }

    @MainActor
    func test_getCountryNames_returnsEmptyArrayOnEmptyData() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let countries = await sut.getCountryNames()
        XCTAssertTrue(countries.isEmpty)
    }

    // MARK: - getCountryOutline Tests

    @MainActor
    func test_getCountryOutline_returnsImageOnValidData() async {
        // Given: A small valid 1x1 PNG image data
        let base64Image = "iVBORw0KGgoAAAANSU66666"
        let imageData = Data(base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==")!
        
        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url!.absoluteString.contains("New%20Zealand"))
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, imageData)
        }

        let image = await sut.getCountryOutline(countryName: "New Zealand")

        XCTAssertNotNil(image)
    }

    @MainActor
    func test_getCountryOutline_returnsNilOnInvalidImage() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("NotAnImage".utf8))
        }

        let image = await sut.getCountryOutline(countryName: "Japan")
        XCTAssertNil(image)
    }

    // MARK: - getClue Tests

    @MainActor
    func test_getClue_buildsCorrectQueryParameters() async {
        let expectedDistance = 1500.0
        let jsonString = """
        { "distance": \(expectedDistance), "direction": "North" }
        """
        let data = jsonString.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let url = request.url!.absoluteString
            XCTAssertTrue(url.contains("country_a=Japan"))
            XCTAssertTrue(url.contains("country_b=France"))
            
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }

        let clue = await sut.getClue(origin: "Japan", destination: "France")
        
        XCTAssertNotNil(clue)
        // Adjust these properties to match your actual DistanceResponse model
        // XCTAssertEqual(clue?.distance, expectedDistance)
    }
}
