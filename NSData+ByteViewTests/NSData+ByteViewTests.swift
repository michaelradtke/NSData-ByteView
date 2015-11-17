//
//  NSData_ByteViewTests.swift
//  NSData+ByteViewTests
//
//  Created by Michael Radtke on 15.11.15.
//  Copyright © 2015 abigale solutions. All rights reserved.
//

import XCTest
@testable import NSData_ByteView

class NSData_ByteViewTests: XCTestCase {
    let byteArray: ByteArray = [0, 1, (Byte.max - 1), Byte.max]
    let wordArray: WordArray = [1, (Word.max - 1)]
    let doubleWordArray: DoubleWordArray = [1, (DoubleWord.max - 1), 0x34dc296e]
    let longArray: LongArray = [1, (Long.max - 1), 0x8712dc4fa30d7af9]

    
    // MARK: -
    
    func testHexString() {
        let testHash = "€@&Ai∆".dataUsingEncoding(NSUTF8StringEncoding)!  // Has a hex value of e282ac40264169e28886
        
        XCTAssertEqual(testHash.hexString, "e282ac40264169e28886")
    }
    
    
    // MARK: - Test that NSData can be created from different values
    
    func testByteCreateable() {
        let d = NSData(byteArray: byteArray)
        XCTAssertEqual(d.hexString, "0001feff")
    }
    
    func testWordAsBigEndianCreateable() {
        let d = NSData(wordArray: wordArray)
        XCTAssertEqual(d.hexString, "0001fffe")
    }
    
    func testWordAsLittleEndianCreateable() {
        let d = NSData(wordArray: wordArray, byteOrder: .LittleEndian)
        XCTAssertEqual(d.hexString, "0100feff")
    }
    
    func testDoubleWordAsBigEndianCreateable() {
        let d = NSData(doubleWordArray: doubleWordArray)
        XCTAssertEqual(d.hexString, "00000001fffffffe34dc296e")
    }
    
    func testDoubleWordAsLittleEndianCreateable() {
        let d = NSData(doubleWordArray: doubleWordArray, byteOrder: .LittleEndian)
        XCTAssertEqual(d.hexString, "01000000feffffff6e29dc34")
    }
    
    func testLongAsBigEndianCreateable() {
        let d = NSData(longArray: longArray)
        XCTAssertEqual(d.hexString, "0000000000000001fffffffffffffffe8712dc4fa30d7af9")
    }
    
    func testLongAsLitteEndianCreateable() {
        let d = NSData(longArray: longArray, byteOrder: .LittleEndian)
        XCTAssertEqual(d.hexString, "0100000000000000fefffffffffffffff97a0da34fdc1287")
    }

    
    // MARK: - Test that values can be retored from NSData
    
    func testByteRestoreable() {
        let d = NSData(byteArray: byteArray)
        XCTAssertEqual(d.byteArray, byteArray)
    }
    
    func testWordAsBigEndianRestoreable() {
        let d = NSData(wordArray: wordArray)
        let restored = try! d.getWordArray()
        XCTAssertEqual(restored, wordArray)
    }
    
    func testWordAsLittleEndianRestoreable() {
        let d = NSData(wordArray: wordArray, byteOrder: .LittleEndian)
        let restored = try! d.getWordArray(byteOrder: .LittleEndian)
        XCTAssertEqual(restored, wordArray)
    }
    
    func testDoubleWordAsBigEndianRestoreable() {
        let d = NSData(doubleWordArray: doubleWordArray)
        let restored = try! d.getDoubleWordArray()
        XCTAssertEqual(restored, doubleWordArray)
    }
    
    func testDoubleWordAsLittleEndianRestoreable() {
        let d = NSData(doubleWordArray: doubleWordArray, byteOrder: .LittleEndian)
        let restored = try! d.getDoubleWordArray(byteOrder: .LittleEndian)
        XCTAssertEqual(restored, doubleWordArray)
    }
    
    func testLongAsBigEndianRestoreable() {
        let d = NSData(longArray: longArray)
        let restored = try! d.getLongArray()
        XCTAssertEqual(restored, longArray)
    }
    
    func testLongAsLitteEndianRestoreable() {
        let d = NSData(longArray: longArray, byteOrder: .LittleEndian)
        let restored = try! d.getLongArray(byteOrder: .LittleEndian)
        XCTAssertEqual(restored, longArray)
    }
    
}
