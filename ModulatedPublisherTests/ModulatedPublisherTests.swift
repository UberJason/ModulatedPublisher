//
//  ModulatedPublisherTests.swift
//  ModulatedPublisherTests
//
//  Created by Jason Ji on 12/17/19.
//  Copyright © 2019 Jason Ji. All rights reserved.
//

import Combine
import XCTest
@testable import ModulatedPublisher

class ModulatedPublisherTests: XCTestCase {
    
    lazy var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm:ss.ssss"
        return f
    }()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCustomPublisher() {
        let expectation = XCTestExpectation(description: "async")
        var events = [Event]()
        
        let passthroughSubject = PassthroughSubject<Int, Never>()
        let cancellable = passthroughSubject
            .modulatedPublisher(interval: 1.0)
            .sink { value in
                events.append(Event(value: value, date: Date()))
                print("value received: \(value) at \(self.dateFormatter.string(from:Date()))")
        }
        
        // WHEN I send 3 events, wait 6 seconds, and send 3 more events
        passthroughSubject.send(1)
        passthroughSubject.send(2)
        passthroughSubject.send(3)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(6000)) {
            passthroughSubject.send(4)
            passthroughSubject.send(5)
            passthroughSubject.send(6)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(4000)) {
                
                // THEN I expect the stored events to be no closer together in time than the interval of 1.0s
                for i in 1 ..< events.count {
                    let interval = events[i].date.timeIntervalSince(events[i-1].date)
                    print("Interval: \(interval)")
                    
                    // There's some small error in the interval but it should be about 1 second since I'm using a 1s modulated publisher.
                    XCTAssertTrue(interval > 0.99)
                }
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 15)
    }
    
}

struct Event {
    let value: Int
    let date: Date
}
