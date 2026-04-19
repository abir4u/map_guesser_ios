//
//  MockTimerProvider.swift
//  Map Guessr
//
//  Created by Abir Pal on 19/04/2026.
//

import XCTest
import Combine
@testable import Map_Guessr

class MockTimerProvider: TimerProvider {
    var subject = PassthroughSubject<Int, Never>()

    func countdown(from seconds: Int) -> AnyPublisher<Int, Never> {
        return subject.eraseToAnyPublisher()
    }
    
    // Call this in your test to simulate the timer ticking
    func sendTicks(_ ticks: [Int]) {
        for tick in ticks {
            subject.send(tick)
        }
        subject.send(completion: .finished)
    }
}
