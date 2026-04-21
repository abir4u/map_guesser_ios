//
//  HomeViewModelTests.swift
//  Map Guessr
//
//  Created by Abir Pal on 19/04/2026.
//

import XCTest
import SwiftUI
@testable import Map_Guessr

// MARK: - Mock Service
@MainActor
class MockAuthService: AuthService {
    var shouldFail = false
    var loginCalled = false
    
    // We override the UI-heavy method to stay in the test environment
    override func handleGoogleLogin() async throws {
        loginCalled = true
        if shouldFail {
            throw NSError(domain: "Test", code: -1, userInfo: [NSLocalizedDescriptionKey: "Login Failed"])
        }
        self.isLoggedIn = true
    }
    
    override func logout() {
        self.isLoggedIn = false
    }
}

// MARK: - Tests
final class HomeViewModelTests: XCTestCase {
    var sut: HomeViewModel!
    var mockAuth: MockAuthService!

    @MainActor
    override func setUp() {
        super.setUp()
        mockAuth = MockAuthService(defaults: UserDefaults(suiteName: "HomeVMTests")!)
        sut = HomeViewModel(authService: mockAuth)
    }

    override func tearDown() {
        sut = nil
        mockAuth = nil
        super.tearDown()
    }

    // MARK: - Navigation Tests
    
    @MainActor
    func test_handleButtonTap_navigatesImmediatelyIfLoggedIn() {
        mockAuth.isLoggedIn = true
        
        sut.handleButtonTap(mode: .play(.Beginner))
        
        XCTAssertEqual(sut.path.count, 1, "Should append to path immediately when logged in")
    }

    @MainActor
    func test_handleButtonTap_triggersLoginIfNotLoggedIn() async {
        mockAuth.isLoggedIn = false
        
        sut.handleButtonTap(mode: .play(.Beginner))
        
        try? await Task.sleep(nanoseconds: 100_000_000)
        XCTAssertTrue(mockAuth.loginCalled, "Should have triggered the login flow")
    }

    // MARK: - Loading & Error State Tests

    @MainActor
    func test_loginFlow_updatesLoadingStateAndPathOnSuccess() async {
        mockAuth.isLoggedIn = false
        
        sut.handleButtonTap(mode: .play(.Beginner))
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.path.count, 1)
        XCTAssertNil(sut.errorMessage)
    }

    @MainActor
    func test_loginFlow_setsErrorMessageOnFailure() async {
        mockAuth.shouldFail = true
        
        sut.handleButtonTap(mode: .play(.Beginner))
        
        try? await Task.sleep(nanoseconds: 200_000_000)
        
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertEqual(sut.errorMessage, "Login Failed")
        XCTAssertEqual(sut.path.count, 0, "Should not navigate on failure")
    }

    // MARK: - Logout Tests

    @MainActor
    func test_logout_clearsPathAndAuth() {
        sut.path.append(GameMode.play(.Beginner))
        mockAuth.isLoggedIn = true
        
        sut.logout()
        
        XCTAssertEqual(sut.path.count, 0)
        XCTAssertFalse(sut.isLoggedIn)
    }
}
