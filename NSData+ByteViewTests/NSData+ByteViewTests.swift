//
//  NSData_ByteViewTests.swift
//  
//  Copyright (c) 2015 Michael Radtke
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

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
    
    // MARK: Byte
    func testByteCreateable_Sequence_Array() {
        let data = NSData(byteSequence: byteArray)
        
        XCTAssertEqual(data.hexString, "0001feff")
    }
    
    func testByteCreateable_Sequence_Range() {
        let data = NSData(byteSequence: 251..<255)
        
        XCTAssertEqual(data.hexString, "fbfcfdfe")
    }
    
    func testByteCreateable_Variadic() {
        let data = NSData(bytes: 0, 1, 254, 255)
        
        XCTAssertEqual(data.hexString, "0001feff")
    }
    
    // MARK: Word
    func testWordAsBigEndianCreateable() {
        let data = NSData(wordSequence: wordArray)
        
        XCTAssertEqual(data.hexString, "0001fffe")
    }
    
    func testWordAsLittleEndianCreateable() {
        let data = NSData(wordSequence: wordArray, byteOrder: .LittleEndian)
        
        XCTAssertEqual(data.hexString, "0100feff")
    }
    
    // MARK: DoubleWord
    func testDoubleWordAsBigEndianCreateable() {
        let data = NSData(doubleWordSequence: doubleWordArray)
        
        XCTAssertEqual(data.hexString, "00000001fffffffe34dc296e")
    }
    
    func testDoubleWordAsLittleEndianCreateable() {
        let data = NSData(doubleWordSequence: doubleWordArray, byteOrder: .LittleEndian)
        
        XCTAssertEqual(data.hexString, "01000000feffffff6e29dc34")
    }
    
    // MARK: Long
    func testLongAsBigEndianCreateable() {
        let data = NSData(longSequence: longArray)
        
        XCTAssertEqual(data.hexString, "0000000000000001fffffffffffffffe8712dc4fa30d7af9")
    }
    
    func testLongAsLitteEndianCreateable() {
        let data = NSData(longSequence: longArray, byteOrder: .LittleEndian)
        
        XCTAssertEqual(data.hexString, "0100000000000000fefffffffffffffff97a0da34fdc1287")
    }

    // MARK: Bool
    func testBoolCreateable_SmallSized() {
        let data = NSData(booleans: true, false, true, true, false)
        
        XCTAssertEqual(data.hexString, "8d")
    }
    
    func testBoolCreateable_MediumSized() {
        let data = NSData(booleans: true, false, true, true, true, false, false, false, true, true, true, true)
        
        XCTAssertEqual(data.hexString, "0b1d0f")
    }
    
    func testBoolCreateable_HighSized() {
        var booleanArray = BooleanArray()
        for _ in 1...257 {
            booleanArray.append(randomBoolean)
        }
        let data = NSData(booleanSequence: booleanArray)
        
        XCTAssertEqual(data.length, 35)
    }
    
    func testBoolCreateable_VeryHighSized() {
        var booleanArray = BooleanArray()
        for _ in 1...65537 {
            booleanArray.append(randomBoolean)
        }
        let data = NSData(booleanSequence: booleanArray)
        
        XCTAssertEqual(data.length, 8197)
    }
    
    
    // MARK: - Test that values can be retored from NSData
    
    func testByteRestoreable() {
        let data = NSData(byteSequence: byteArray)
        
        XCTAssertEqual(data.byteArray, byteArray)
    }
    
    func testWordAsBigEndianRestoreable() {
        let data = NSData(wordSequence: wordArray)
        
        let restored = try! data.wordSequence()
        
        XCTAssertEqual(Array.init(restored), wordArray)
    }
    
    func testWordAsLittleEndianRestoreable() {
        let data = NSData(wordSequence: wordArray, byteOrder: .LittleEndian)
        
        let restored = try! data.wordSequence(byteOrder: .LittleEndian)
        
        XCTAssertEqual(Array.init(restored), wordArray)
    }
    
    func testDoubleWordAsBigEndianRestoreable() {
        let data = NSData(doubleWordSequence: doubleWordArray)
        
        let restored = try! data.doubleWordSequence()
        
        XCTAssertEqual(Array.init(restored), doubleWordArray)
    }
    
    func testDoubleWordAsLittleEndianRestoreable() {
        let data = NSData(doubleWordSequence: doubleWordArray, byteOrder: .LittleEndian)
        
        let restored = try! data.doubleWordSequence(byteOrder: .LittleEndian)
        
        XCTAssertEqual(Array.init(restored), doubleWordArray)
    }
    
    func testLongAsBigEndianRestoreable() {
        let data = NSData(longSequence: longArray)
        
        let restored = try! data.longSequence()
        
        XCTAssertEqual(Array.init(restored), longArray)
    }
    
    func testLongAsLitteEndianRestoreable() {
        let data = NSData(longSequence: longArray, byteOrder: .LittleEndian)
        
        let restored = try! data.longSequence(byteOrder: .LittleEndian)
        
        XCTAssertEqual(Array.init(restored), longArray)
    }
    
    func testBoolResoreable_SmallSized() {
        let boolArray: BooleanArray = [true, false, true, true, false]
        let data = NSData(booleanSequence: boolArray)
        
        let restored = Array.init(data.booleanSequence())
        
        XCTAssertEqual(restored.count, 5)
        XCTAssertEqual(restored, boolArray)
    }
    
    func testBoolResoreable_MediumSized() {
        let boolArray: BooleanArray = [true, false, true, true, true, false, false, false, true, true, true, true]
        let data = NSData(booleanSequence: boolArray)
        
        let restored = Array.init(data.booleanSequence())
        
        XCTAssertEqual(restored.count, 12)
        XCTAssertEqual(restored, boolArray)
    }
    
    func testBoolResoreable_HighSized() {
        var booleanArray = BooleanArray()
        for _ in 1...1029 {
            booleanArray.append(randomBoolean)
        }
        let data = NSData(booleanSequence: booleanArray)
        
        let restored = Array.init(data.booleanSequence())
        
        XCTAssertEqual(restored.count, 1029)
        XCTAssertEqual(restored, booleanArray)
    }
    
    func testBoolResoreable_VeryHighSized() {
        var booleanArray = BooleanArray()
        for _ in 1...66321 {
            booleanArray.append(randomBoolean)
        }
        let data = NSData(booleanSequence: booleanArray)
        
        let restored = Array.init(data.booleanSequence())
        
        XCTAssertEqual(restored.count, 66321)
        XCTAssertEqual(restored, booleanArray)
    }

    
    // MARK: - Helper
    var randomBoolean: Bool {
        let randomValue = Int(arc4random_uniform(UInt32(2)))
        return randomValue == 0 ? false : true
    }
}
