//
//  BLEPracticeTests.swift
//  BLEPracticeTests
//
//  Created by 贾捷飞 on 2021/12/6.
//

import XCTest
@testable import BLEPractice

class BLEPracticeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        var data = Data(count: 3)
        data[0] = 0xAA
        data[1] = 0xBB
        data[2] = 0xCC
        print(DataUtil.dataToHexString(data: data))
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
