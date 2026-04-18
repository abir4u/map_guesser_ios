//
//  AuthServiceTests.swift
//  Map Guessr
//
//  Created by Abir Pal on 17/04/2026.
//

import XCTest
@testable import Map_Guessr

final class AuthServiceTests: XCTestCase {
    var sut: AuthService!
    var mockDefaults: UserDefaults!
    var mockSession: URLSession!
    
    @MainActor
    override func setUp() {
        super.setUp()
        mockDefaults = UserDefaults(suiteName: "AuthServiceTests")
        mockDefaults.removePersistentDomain(forName: "AuthServiceTests")
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: config)        
    }

    override func tearDown() {
        sut = nil
        mockDefaults.removePersistentDomain(forName: "AuthServiceTests")
        mockDefaults = nil
        super.tearDown()
    }

    // MARK: - Initialisation Tests
    @MainActor
    func test_initialization_loadsFromUserDefaults() {
        mockDefaults.set(true, forKey: "isLoggedIn")
        mockDefaults.set("test@example.com", forKey: "userEmail")
        
        sut = AuthService(session: mockSession, defaults: mockDefaults)

        XCTAssertTrue(sut.isLoggedIn)
        XCTAssertEqual(sut.userEmail, "test@example.com")
    }

    // MARK: - Logout Tests
    @MainActor
    func test_logout_clearsData() {
        sut = AuthService(session: mockSession, defaults: mockDefaults)

        mockDefaults.set(true, forKey: "isLoggedIn")
        sut.isLoggedIn = true
        sut.userEmail = "test@example.com"
        
        sut.logout()
        
        XCTAssertFalse(sut.isLoggedIn)
        XCTAssertNil(sut.userEmail)
        XCTAssertFalse(mockDefaults.bool(forKey: "isLoggedIn"))
        XCTAssertNil(mockDefaults.string(forKey: "userEmail"))
    }

    // MARK: - Backend Auth Tests (Mocking Network)
    @MainActor
    func test_processSuccessfulLogin_failsIfBackendReturns401() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        sut = AuthService(session: mockSession, defaults: mockDefaults)
        
        do {
            try await sut.processSuccessfulLogin(email: "test@example.com")
            XCTFail("Should have thrown a backend authentication failed error")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "AuthService")
            XCTAssertEqual(nsError.code, -2)
        }
    }
    
    // MARK: -
    @MainActor
    func test_processSuccessfulLogin_savesUserOnSuccess() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }
        
        sut = AuthService(session: mockSession, defaults: mockDefaults)
        try await sut.processSuccessfulLogin(email: "test@example.com")
        
        XCTAssertTrue(sut.isLoggedIn)
        XCTAssertEqual(sut.userEmail, "test@example.com")
        XCTAssertTrue(mockDefaults.bool(forKey: "isLoggedIn"))
    }

}

// MARK: - Helper Mock Network Protocol
class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { return true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { return request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else { return }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
