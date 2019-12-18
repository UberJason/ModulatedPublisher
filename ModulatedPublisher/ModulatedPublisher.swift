//
//  ModulatedPublisher.swift
//  CustomPublisher
//
//  Created by Jason Ji on 12/17/19.
//  Copyright © 2019 Jason Ji. All rights reserved.
//

import Foundation
import Combine

public extension Publisher where Self.Failure == Never {
    func modulatedPublisher(interval: TimeInterval) -> AnyPublisher<Output, Never> {
        let timerPublisher = Timer
            .publish(every: interval, on: .main, in: .common)
            .autoconnect()
        
        return timerPublisher
            .zip(self, { $1 })                  // should emit one input element ($1) every timer tick
            .eraseToAnyPublisher()
    }
}
