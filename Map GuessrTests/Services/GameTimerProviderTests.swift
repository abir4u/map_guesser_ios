//
//  GameTimerProviderTests.swift
//  Map Guessr
//
//  Created by Abir Pal on 19/04/2026.
//

import XCTest
import Combine
@testable import Map_Guessr

final class GameTimerProviderTests: XCTestCase {
    var sut: GameTimerProvider!
    var cancellables: Set<AnyCancellable>!

    @MainActor
    override func setUp() {
        super.setUp()
        sut = GameTimerProvider()
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Countdown Tests
    @MainActor
    func test_countdown_emitsCorrectValuesAndFinishes() {
        let startSeconds = 3
        var receivedValues: [Int] = []
        let expectation = expectation(description: "Timer should emit 3, 2, 1, 0 and finish")
        
        sut.countdown(from: startSeconds)
            .sink(receiveCompletion: { completion in
                if case .finished = completion {
                    expectation.fulfill()
                }
            }, receiveValue: { value in
                receivedValues.append(value)
            })
            .store(in: &cancellables)

        // Using a slightly longer timeout because the real timer takes 1s per tick
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(receivedValues, [3, 2, 1, 0], "The countdown should include the starting number and 0")
    }
}
