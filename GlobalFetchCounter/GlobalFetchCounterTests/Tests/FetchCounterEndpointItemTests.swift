//
//  FetchCounterEndpointItemTests.swift
//  GlobalFetchCounterTests
//
//  Created by Can Kurtur on 11.02.2025.
//

import XCTest
@testable import GlobalFetchCounter

class FetchCounterEndpointItemTests: XCTestCase {
    
    func test_getRoot_path() {
        let endpoint = FetchCounterEndpointItem.getRoot
        XCTAssertEqual(endpoint.path, "")
    }
    
    func test_getRoot_method() {
        let endpoint = FetchCounterEndpointItem.getRoot
        XCTAssertEqual(endpoint.method, .get)
    }
    
    func test_getResponseCode_path() {
        let testPath = "/test/path"
        let endpoint = FetchCounterEndpointItem.getResponseCode(testPath)
        XCTAssertEqual(endpoint.path, testPath)
    }
    
    func test_getResponseCode_method() {
        let testPath = "/test/path"
        let endpoint = FetchCounterEndpointItem.getResponseCode(testPath)
        XCTAssertEqual(endpoint.method, .get)
    }
}
