//
//  FunMemoryTests.swift
//  FunMemoryTests
//
//  Created by 柴田晃輔 on 2019/08/08.
//  Copyright © 2019 shibata. All rights reserved.
//

import XCTest
@testable import FunMemory

class FunMemoryTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testUserData() {
        let userData = UserData()
        let inRange = "aaaaa"
        let outRange = "aaaaaaaaaaa"

        // 文字数制限内
        userData.saveData(str: inRange)
        XCTAssertNotNil(userData.readData())
        XCTAssertEqual(userData.readData(), inRange)

        // 文字数制限以上→表示時に切り捨てるため、格納&読み出しは可能
        userData.saveData(str: outRange)
        XCTAssertNotNil(userData.readData())
        XCTAssertEqual(userData.readData(), outRange)

    }

    func testCardData() {
        let cardNo = 1
        let card = CardData(no: cardNo)

        var imageName = card.getImageName()
        XCTAssertNotNil(imageName)
        XCTAssertEqual(imageName, "CardBack")

        card.isFront.toggle()
        imageName = card.getImageName()

        XCTAssertNotNil(imageName)
        XCTAssertEqual(imageName, card.imageName)

    }

}
