 //
 //  NSData+ByteView.swift
 //  NSData+ByteView
 //
 //  Created by Michael Radtke on 15.11.15.
 //  Copyright © 2015 abigale solutions. All rights reserved.
 //
 
 import Foundation
 
 public typealias Byte            = UInt8
 public typealias Word            = UInt16
 public typealias DoubleWord      = UInt32
 public typealias Long            = UInt64
 
 public typealias ByteArray       = [Byte]
 public typealias WordArray       = [Word]
 public typealias DoubleWordArray = [DoubleWord]
 public typealias LongArray       = [Long]
 
 
 public extension NSData {
    
    typealias BytesInWord         = (b0: Byte, b1: Byte)
    typealias BytesInDoubleWord   = (b0: Byte, b1: Byte, b2: Byte, b3:Byte)
    typealias BytesInLong         = (b0: Byte, b1: Byte, b2: Byte, b3:Byte, b4: Byte, b5: Byte, b6: Byte, b7:Byte)
    
    
    public enum ByteOrder {
        case BigEndian
        case LittleEndian
    }
    
    
    public enum DataError: ErrorType {
        case ConversionError
    }
    
    //MARK: - Creating Data Objects
    
    class public func withByteArray(byteArray: ByteArray) -> NSData {
        return NSData(bytes: byteArray, length: byteArray.count)
    }
    
    class public func withWordArray(wordArray: WordArray, byteOrder: ByteOrder = .BigEndian) -> NSData {
        var tempByteArray = ByteArray()
        for word in wordArray {
            tempByteArray.appendContentsOf(byteOrder.composeBytesFor(word))
        }
        return NSData.withByteArray(tempByteArray)
    }
    
    class public func withDoubleWordArray(doubleWordArray: DoubleWordArray, byteOrder: ByteOrder = .BigEndian) -> NSData {
        var tempByteArray = ByteArray()
        for dWord in doubleWordArray {
            tempByteArray.appendContentsOf(byteOrder.composeBytesFor(dWord))
        }
        return NSData.withByteArray(tempByteArray)
    }
    
    class public func withLongArray(longArray: LongArray, byteOrder: ByteOrder = .BigEndian) -> NSData {
        var tempByteArray = ByteArray()
        for long in longArray {
            tempByteArray.appendContentsOf(byteOrder.composeBytesFor(long))
        }
        return NSData.withByteArray(tempByteArray)
    }
    
    public convenience init(byteArray: ByteArray) {
        self.init(data: NSData.withByteArray(byteArray))
    }
    
    public convenience init(wordArray: WordArray, byteOrder: ByteOrder = .BigEndian) {
        self.init(data: NSData.withWordArray(wordArray, byteOrder: byteOrder))
    }
    
    public convenience init(doubleWordArray: DoubleWordArray, byteOrder: ByteOrder = .BigEndian) {
        self.init(data: NSData.withDoubleWordArray(doubleWordArray, byteOrder: byteOrder))
    }
    
    public convenience init(longArray: LongArray, byteOrder: ByteOrder = .BigEndian) {
        self.init(data: NSData.withLongArray(longArray, byteOrder: byteOrder))
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
            let biw: BytesInWord = (
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
            let bidw: BytesInDoubleWord = (
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
            let bil: BytesInLong = (
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
    
    // MARK: - Private Stuff
    private func getByteAndIncreaseRangeLocation(inout range: NSRange) -> Byte {
        var tempByte: Byte = 0
        self.getBytes(&tempByte, range: range)
        range.location++
        return tempByte
    }
    
 }
 
 private extension NSData.ByteOrder {
    func composeBytesFor(word: Word) -> ByteArray {
        let byteArray: ByteArray = [
            Byte(word >> 8),
            Byte(word & 0x00FF)
        ]
        return respectByteOrder(byteArray)
    }
    
    func composeBytesFor(dWord: DoubleWord) -> ByteArray {
        let byteArray: ByteArray = [
            Byte(dWord >> 24),
            Byte((dWord & 0x00FF0000) >> 16),
            Byte((dWord & 0x0000FF00) >> 8),
            Byte( dWord & 0x000000FF)
        ]
        return respectByteOrder(byteArray)
    }
    
    func composeBytesFor(long: Long) -> ByteArray {
        let byteArray: ByteArray = [
            Byte(long >> 56),
            Byte((long & 0x00FF000000000000) >> 48),
            Byte((long & 0x0000FF0000000000) >> 40),
            Byte((long & 0x000000FF00000000) >> 32),
            Byte((long & 0x00000000FF000000) >> 24),
            Byte((long & 0x0000000000FF0000) >> 16),
            Byte((long & 0x000000000000FF00) >> 8),
            Byte( long & 0x00000000000000FF)
        ]
        return respectByteOrder(byteArray)
    }
    
    func decomposeBytes(var bytes: NSData.BytesInWord) -> Word {
        if self == .LittleEndian {
            swap(&bytes.b0, &bytes.b1)
        }
        let word = Word(bytes.b0) << 8 + Word(bytes.b1)
        return word
    }
    
    func decomposeBytes(var bytes: NSData.BytesInDoubleWord) -> DoubleWord {
        if self == .LittleEndian {
            swap(&bytes.b0, &bytes.b3)
            swap(&bytes.b1, &bytes.b2)
        }
        let dWord1 = DoubleWord(bytes.b0) << 24 + DoubleWord(bytes.b1) << 16
        let dWord2 = DoubleWord(bytes.b2) << 8 + DoubleWord(bytes.b3)
        return dWord1 + dWord2
    }
    
    func decomposeBytes(var bytes: NSData.BytesInLong) -> Long {
        if self == .LittleEndian {
            swap(&bytes.b0, &bytes.b7)
            swap(&bytes.b1, &bytes.b6)
            swap(&bytes.b2, &bytes.b5)
            swap(&bytes.b3, &bytes.b4)
        }
        let long1 = Long(bytes.b0) << 56 + Long(bytes.b1) << 48
        let long2 = Long(bytes.b2) << 40 + Long(bytes.b3) << 32
        let long3 = Long(bytes.b4) << 24 + Long(bytes.b5) << 16
        let long4 = Long(bytes.b6) << 8 + Long(bytes.b7)
        return long1 + long2 + long3 + long4
    }
    
    
    func respectByteOrder(byteArray: ByteArray) -> ByteArray {
        switch self {
        case .BigEndian:
            return byteArray
        case .LittleEndian:
            return byteArray.reverse()
        }
    }
    
 }