//
//  TimerService.swift
//  Map Guessr
//
//  Created by Abir Pal on 16/04/2026.
//

import Foundation
internal import Combine

protocol TimerProvider {
    func countdown(from seconds: Int) -> AnyPublisher<Int, Never>
}

@MainActor
class GameTimerProvider: TimerProvider {
    func countdown(from seconds: Int) -> AnyPublisher<Int, Never> {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .scan(seconds) { remaining, _ in remaining - 1 }
            .prepend(seconds) // Send the starting number immediately [3]
            .prefix(seconds + 1) // Stops the stream at 0
            .eraseToAnyPublisher()
    }
}
