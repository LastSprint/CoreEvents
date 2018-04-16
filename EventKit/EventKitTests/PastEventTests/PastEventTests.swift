//
//  PastEventTests.swift
//  EventKitTests
//
//  Created by Alexander Kravchenkov on 13.04.2018.
//  Copyright © 2018 Alexander Kravchenkov. All rights reserved.
//

import XCTest
@testable import EventKit

class PastEventTests: XCTestCase {

    // MARK: - Nested types

    private struct EventContainer {
        var event = PastEvent<String>()

        func emit(value: String) {
            event.invoke(with: value)
        }
    }

    // MARK: - Lifecycle

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    // MARK: - Positive tests

    func testThatEventEmitsValue() {

        // Arrange

        let emiter = EventContainer()
        let message = "Hello world"

        // Act

        var emited: String?

        emiter.event += { value in
            emited = value
        }

        emiter.emit(value: message)

        // Assert

        XCTAssertEqual(message, emited)
    }

    func testThatEventCanEmitMulticast() {
        // Arrange

        let emiter = EventContainer()
        let message = "Hello world"
        let listenersCount = 10

        // Act

        var emited = [String]()

        for _ in 0..<listenersCount {
            emiter.event += { value in
                emited.append(value)
            }
        }

        emiter.emit(value: message)

        // Assert

        XCTAssertEqual(emited.count, listenersCount)
        emited.forEach { XCTAssertEqual($0, message) }
    }

    func testThatEventEmitsManyTimes() {
        // Arrange

        let emiter = EventContainer()
        let message = "Hello world"
        let emitCount = 10

        // Act

        var emited = [String]()

        emiter.event += { value in
            emited.append(value)
        }

        for _ in 0..<emitCount {
            emiter.emit(value: message)
        }

        // Assert

        XCTAssertEqual(emited.count, emitCount)
        emited.forEach { XCTAssertEqual($0, message) }
    }

    func testThatEventEmitsAllLastEmitedMessage() {
        // Arrange

        let emiter = EventContainer()
        let firstMessage = "Hello world"
        let secondMessage = "Hello (:"
        let thirdMessage = "How are you?"

        // Act

        var allEmited = [String]()

        emiter.event += { value in
            allEmited.append(value)
        }

        emiter.emit(value: firstMessage)
        emiter.emit(value: secondMessage)

        var newEmited = [String]()

        emiter.event += { value in
            newEmited.append(value)
        }

        let afterSubscribeMessageCount = newEmited.count

        emiter.emit(value: thirdMessage)

        // Assert

        XCTAssertEqual(newEmited.count, allEmited.count)
        XCTAssertEqual(afterSubscribeMessageCount, newEmited.count - 1)

        for index in 0..<3 {
            XCTAssertEqual(newEmited[index], allEmited[index])
        }

    }

    func testThatClearMethodWorkSuccess() {
        // Arrange

        let emiter = EventContainer()
        let firstMessage = "Hello world"
        let lastMessage = "Hello (:"

        // Act

        var emited = [String]()

        emiter.event += { value in
            emited.append(value)
        }

        emiter.emit(value: firstMessage)

        emiter.event.clear()

        emiter.emit(value: lastMessage)

        // Assert

        XCTAssertEqual(emited.count, 1)
    }
}
