 //
 //  NSData+ByteView.swift
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
 
 import Foundation
 
 
 
 
 public extension NSData {
    
    public enum DataError: ErrorType {
        case ConversionError
    }
    
    
    //MARK: - Creating Data Objects
    
    class public func withByteArray(byteArray: ByteArray) -> NSData {
        guard !byteArray.isEmpty else {
            return NSData()
        }
        
        return NSData(bytes: byteArray, length: byteArray.count)
    }
    
    class public func withWordArray(wordArray: WordArray, byteOrder: ByteOrder = .BigEndian) -> NSData {
        guard !wordArray.isEmpty else {
            return NSData()
        }
        
        var tempByteArray = ByteArray()
        for word in wordArray {
            tempByteArray.appendContentsOf(byteOrder.composeBytesFor(word))
        }
        
        return NSData.withByteArray(tempByteArray)
    }
    
    class public func withDoubleWordArray(doubleWordArray: DoubleWordArray, byteOrder: ByteOrder = .BigEndian) -> NSData {
        guard !doubleWordArray.isEmpty else {
            return NSData()
        }
        
        var tempByteArray = ByteArray()
        for dWord in doubleWordArray {
            tempByteArray.appendContentsOf(byteOrder.composeBytesFor(dWord))
        }
        return NSData.withByteArray(tempByteArray)
    }
    
    class public func withLongArray(longArray: LongArray, byteOrder: ByteOrder = .BigEndian) -> NSData {
        guard !longArray.isEmpty else {
            return NSData()
        }
        
        var tempByteArray = ByteArray()
        for long in longArray {
            tempByteArray.appendContentsOf(byteOrder.composeBytesFor(long))
        }
        return NSData.withByteArray(tempByteArray)
    }
    
    class public func withBooleanArray(var booleanArray: BooleanArray) -> NSData {
        guard !booleanArray.isEmpty else {
            return NSData()
        }
        
        var tempByteArray: ByteArray
        let tempByteStartingValue: Byte
        
        // The count of boolean values must always be stored so we can return the correct count of boolean while reading
        // Attention: The count - 1, so we can have 256 instead of 255 bits stored
        let correctedBoolCount = booleanArray.count - 1
        
        switch booleanArray.count {
        case 1...5:
            // Up to five booleans including the length information can be stored in one byte
            tempByteStartingValue = Byte(correctedBoolCount) << 5
            tempByteArray = ByteArray()
        default:
            // More than 5 booleans must be stored with the size information in dedicated bytes
            tempByteStartingValue = 0
            let byteOrder = ByteOrder.BigEndian
            
            switch correctedBoolCount {
            case 0..<256:               tempByteArray = [Byte(correctedBoolCount)]
            case 256..<65536:           tempByteArray = byteOrder.composeBytesFor(Word(correctedBoolCount))
            case 65536..<4294967296:    tempByteArray = byteOrder.composeBytesFor(DoubleWord(correctedBoolCount))
            default:                    tempByteArray = byteOrder.composeBytesFor(Long(correctedBoolCount))
            }
        }
        
        // Compose one byte out of eight boolean values
        let startBitPosition: Byte = 0b00000001
        while booleanArray.count > 0 {
            let chunckCount = min(booleanArray.count, 8)
            var tempByte: Byte = tempByteStartingValue
            var shiftingWidth: Byte = 0
            
            for _ in 0..<chunckCount {
                if booleanArray.removeFirst() == true {
                    tempByte = tempByte | (startBitPosition << shiftingWidth)
                }
                shiftingWidth++
            }
            tempByteArray.append(tempByte)
        }
        
        return NSData.withByteArray(tempByteArray)
    }
    
    public convenience init(byteArray: ByteArray) {
        self.init(data: NSData.withByteArray(byteArray))
    }
    
    public convenience init(bytes: Byte...) {
        self.init(data: NSData.withByteArray(bytes))
    }
    
    public convenience init(byteOrder: ByteOrder = .BigEndian, wordArray: WordArray) {
        self.init(data: NSData.withWordArray(wordArray, byteOrder: byteOrder))
    }
    
    public convenience init(byteOrder: ByteOrder = .BigEndian, doubleWordArray: DoubleWordArray) {
        self.init(data: NSData.withDoubleWordArray(doubleWordArray, byteOrder: byteOrder))
    }
    
    public convenience init(byteOrder: ByteOrder = .BigEndian, longArray: LongArray) {
        self.init(data: NSData.withLongArray(longArray, byteOrder: byteOrder))
    }
    
    public convenience init(booleanArray: BooleanArray) {
        self.init(data: NSData.withBooleanArray(booleanArray))
    }
    
    public convenience init(booleans: Bool...) {
        self.init(data: NSData.withBooleanArray(booleans))
    }
    
    
    // MARK: Accessing Data
    
    public var hexString: String {
        var tempByte: Byte = 0
        var tempByteRange = NSRange(location: 0, length: 1)
        var hexString = ""
        
        for _ in 0..<self.length {
            self.getBytes(&tempByte, range: tempByteRange)
            hexString += String(format: "%02x", tempByte)
            tempByteRange.location++
        }
        
        return hexString
    }
    
    public var byteArray: ByteArray {
        let count = self.length / sizeof(Byte)
        var bytesArray = ByteArray(count: count, repeatedValue: 0)
        self.getBytes(&bytesArray, length:self.length)
        return bytesArray
    }
    
    public func getWordArray(byteOrder byteOrder: ByteOrder = .BigEndian) throws -> WordArray {
        guard self.length % sizeof(Word) == 0 else {
            throw DataError.ConversionError
        }
        
        let count = self.length / sizeof(Word)
        var wordArray = WordArray(count: count, repeatedValue: 0)
        var tempByteRange = NSRange(location: 0, length: 1)
        
        for index in 0..<count {
            let biw: BytesOfWord = (
                b0: getByteAndIncreaseRangeLocation(&tempByteRange),
                b1: getByteAndIncreaseRangeLocation(&tempByteRange)
            )
            wordArray[index] = byteOrder.decomposeBytes(biw)
        }
        return wordArray
    }
    
    public func getDoubleWordArray(byteOrder byteOrder: ByteOrder = .BigEndian) throws -> DoubleWordArray {
        guard self.length % sizeof(DoubleWord) == 0 else {
            throw DataError.ConversionError
        }
        
        let count = self.length / sizeof(DoubleWord)
        var dWordArray = DoubleWordArray(count: count, repeatedValue: 0)
        var tempByteRange = NSRange(location: 0, length: 1)
        
        for index in 0..<count {
            let bidw: BytesOfDoubleWord = (
                b0: getByteAndIncreaseRangeLocation(&tempByteRange),
                b1: getByteAndIncreaseRangeLocation(&tempByteRange),
                b2: getByteAndIncreaseRangeLocation(&tempByteRange),
                b3: getByteAndIncreaseRangeLocation(&tempByteRange)
            )
            dWordArray[index] = byteOrder.decomposeBytes(bidw)
        }
        return dWordArray
    }
    
    public func getLongArray(byteOrder byteOrder: ByteOrder = .BigEndian) throws -> LongArray {
        guard self.length % sizeof(Long) == 0 else {
            throw DataError.ConversionError
        }
        
        let count = self.length / sizeof(Long)
        var longArray = LongArray(count: count, repeatedValue: 0)
        var tempByteRange = NSRange(location: 0, length: 1)
        
        for index in 0..<count {
            let bil: BytesOfLong = (
                b0: getByteAndIncreaseRangeLocation(&tempByteRange),
                b1: getByteAndIncreaseRangeLocation(&tempByteRange),
                b2: getByteAndIncreaseRangeLocation(&tempByteRange),
                b3: getByteAndIncreaseRangeLocation(&tempByteRange),
                b4: getByteAndIncreaseRangeLocation(&tempByteRange),
                b5: getByteAndIncreaseRangeLocation(&tempByteRange),
                b6: getByteAndIncreaseRangeLocation(&tempByteRange),
                b7: getByteAndIncreaseRangeLocation(&tempByteRange)
            )
            longArray[index] = byteOrder.decomposeBytes(bil)
        }
        return longArray
    }
    
    public func getBooleanArray() -> BooleanArray {
        var tempBooleanArray = BooleanArray()
        var byteArray = self.byteArray
        let expectedSize: Int
        let byteOrder = ByteOrder.BigEndian
        
        switch byteArray.count {
        case 1:
            let byte = byteArray.first!
            let booleanCount: Byte = ((byte & 0b11100000) >> 5) + 1
            expectedSize = Int(booleanCount)
        case 2...33:
            expectedSize = Int(byteArray.removeFirst()) + 1
        case 34...8194:
            let biw = (
                b0: byteArray.removeFirst(), b1: byteArray.removeFirst()
            )
            expectedSize = Int(byteOrder.decomposeBytes(biw)) + 1
        case 8195...536870916:
            let bidw = (
                b0: byteArray.removeFirst(), b1: byteArray.removeFirst(),
                b2: byteArray.removeFirst(), b3: byteArray.removeFirst()
            )
            expectedSize = Int(byteOrder.decomposeBytes(bidw)) + 1
        default:
            let bil = (
                b0: byteArray.removeFirst(), b1: byteArray.removeFirst(),
                b2: byteArray.removeFirst(), b3: byteArray.removeFirst(),
                b4: byteArray.removeFirst(), b5: byteArray.removeFirst(),
                b6: byteArray.removeFirst(), b7: byteArray.removeFirst()
            )
            expectedSize = Int(byteOrder.decomposeBytes(bil)) + 1        }
        
        while !byteArray.isEmpty {
            let byte = byteArray.removeFirst()
            for shiftingWidth: Byte in 0...7 {
                let b:Byte = byte & 0b00000001 << shiftingWidth
                let val = b == 0 ? false : true
                tempBooleanArray.append(val)
            }
        }
        
        // Trim length
        let spareValueCount = tempBooleanArray.count - expectedSize
        for _ in 0..<spareValueCount {
            tempBooleanArray.removeLast()
        }
        
        return tempBooleanArray
    }
    
    
    // MARK: Private Stuff
    private func getByteAndIncreaseRangeLocation(inout range: NSRange) -> Byte {
        var tempByte: Byte = 0
        self.getBytes(&tempByte, range: range)
        range.location++
        return tempByte
    }
    
 }
