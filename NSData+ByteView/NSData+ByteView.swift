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
    
    public enum DataError: Error {
        case conversionError
    }
    
    
    // MARK: - Creating NSData Objects
    
    // MARK: Byte
    public convenience init<S: Sequence>(byteSequence: S) where S.Iterator.Element == Byte {
        let byteArray = Array.init(byteSequence)
        self.init(bytes: byteArray, length: byteArray.count)
    }
    
    public convenience init(bytes: Byte...) {
        self.init(bytes: bytes, length: bytes.count)
    }
    
    // MARK: Word
    public convenience init<S: Sequence>(wordSequence: S, byteOrder: ByteOrder = .bigEndian) where S.Iterator.Element == SingleWord {
        var tempByteArray = ByteArray()
        for word in wordSequence {
			tempByteArray.append(contentsOf: byteOrder.composeBytesFor(word))
        }
        self.init(bytes: tempByteArray, length: tempByteArray.count)
    }
    
    public convenience init(bigEndianWords words: SingleWord...) {
        self.init(wordSequence: words, byteOrder: .bigEndian)
    }
    
    public convenience init(litteEndianWords words: SingleWord...) {
        self.init(wordSequence: words, byteOrder: .littleEndian)
    }
    
    // MARK: DoubleWord
    public convenience init<S: Sequence>(doubleWordSequence: S, byteOrder: ByteOrder = .bigEndian) where S.Iterator.Element == DoubleWord {
        var tempByteArray = ByteArray()
        for dWord in doubleWordSequence {
			tempByteArray.append(contentsOf: byteOrder.composeBytesFor(dWord))
        }
        self.init(bytes: tempByteArray, length: tempByteArray.count)
    }
    
    public convenience init(bigEndianDoubleWords words: DoubleWord...) {
        self.init(doubleWordSequence: words, byteOrder: .bigEndian)
    }
    
    public convenience init(litteEndianDoubleWords words: DoubleWord...) {
        self.init(doubleWordSequence: words, byteOrder: .littleEndian)
    }
    
    // MARK: Long
    public convenience init<S: Sequence>(longSequence: S, byteOrder: ByteOrder = .bigEndian) where S.Iterator.Element == Long {
        var tempByteArray = ByteArray()
        for long in longSequence {
			tempByteArray.append(contentsOf: byteOrder.composeBytesFor(long))
        }
        self.init(bytes: tempByteArray, length: tempByteArray.count)
    }
    
    public convenience init(bigEndianLongs longs: Long...) {
        self.init(longSequence: longs, byteOrder: .bigEndian)
    }
    
    public convenience init(littleEndianLongs longs: Long...) {
        self.init(longSequence: longs, byteOrder: .littleEndian)
    }
    

    // MARK: Bool
    public convenience init<S: Sequence>(booleanSequence: S) where S.Iterator.Element == Bool {
        var booleanArray = Array.init(booleanSequence)
        if booleanArray.isEmpty {
            self.init()
        } else {
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
                let byteOrder = ByteOrder.bigEndian
                
                switch correctedBoolCount {
                case 0..<256:               tempByteArray = [Byte(correctedBoolCount)]
                case 256..<65536:           tempByteArray = byteOrder.composeBytesFor(SingleWord(correctedBoolCount))
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
                    shiftingWidth += 1
                }
                tempByteArray.append(tempByte)
            }
            self.init(byteSequence: tempByteArray)
        }
    }
    
    public convenience init(booleans: Bool...) {
        self.init(booleanSequence: booleans)
    }
    
    
    // MARK: HexString
    public convenience init(hexString: String) throws {
        let characterCount = hexString.characters.count
        guard characterCount > 0 && characterCount % 2 == 0 else {
            throw HexStringError.insufficientLength
        }
        
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]", options: .caseInsensitive)
        
        let correctCharacterCount = regex.numberOfMatches(in: hexString, options: [], range: NSMakeRange(0, characterCount))
        if correctCharacterCount != characterCount {
            throw HexStringError.insufficientCharacters
        }
        
        var tempByteArray = ByteArray()
        
        var actualIndex = hexString.startIndex
        while actualIndex < hexString.endIndex {
			let nextIndex = hexString.index(after: actualIndex)
            let range = actualIndex ... nextIndex
            let byteString = hexString[range]
			let num = UInt8(byteString.withCString { strtoul($0, nil, 16) })
            tempByteArray.append(num)
			
			actualIndex = hexString.index(after: nextIndex)
        }
        
        self.init(byteSequence: tempByteArray)
    }
    
    // MARK: - Accessing Data
    
    public var hexString: String {
        var tempByte: Byte = 0
        var tempByteRange = NSRange(location: 0, length: 1)
        var hexString = ""
        
        for _ in 0..<self.length {
            self.getBytes(&tempByte, range: tempByteRange)
            hexString += String(format: "%02x", tempByte)
            tempByteRange.location += 1
        }
        
        return hexString
    }
    
    // MARK: Byte
    public var byteArray: [Byte] {
        let count = self.length / MemoryLayout<Byte>.size
        var bytesArray = ByteArray(repeating: 0, count: count)
        self.getBytes(&bytesArray, length:self.length)
        return bytesArray
    }
    
    public func byteSequence() -> AnySequence<Byte>{
        return AnySequence(byteArray)
    }
    
    // MARK: Word
    public func wordSequence(byteOrder: ByteOrder = .bigEndian) throws -> AnySequence<SingleWord> {
        guard self.length % MemoryLayout<SingleWord>.size == 0 else {
            throw DataError.conversionError
        }
        
        let count = self.length / MemoryLayout<SingleWord>.size
        var wordArray = WordArray(repeating: 0, count: count)
        var tempByteRange = NSRange(location: 0, length: 1)
        
        for index in 0..<count {
            let biw: BytesOfWord = (
                b0: getByteAndIncreaseRangeLocation(&tempByteRange),
                b1: getByteAndIncreaseRangeLocation(&tempByteRange)
            )
            wordArray[index] = byteOrder.decomposeBytes(biw)
        }
        return AnySequence(wordArray)
    }
    
    // MARK: DoubleWord
    public func doubleWordSequence(byteOrder: ByteOrder = .bigEndian) throws -> AnySequence<DoubleWord> {
        guard self.length % MemoryLayout<DoubleWord>.size == 0 else {
            throw DataError.conversionError
        }
        
        let count = self.length / MemoryLayout<DoubleWord>.size
        var dWordArray = DoubleWordArray(repeating: 0, count: count)
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
        return AnySequence(dWordArray)
    }
    
    // MARK: Long
    public func longSequence(byteOrder: ByteOrder = .bigEndian) throws -> AnySequence<Long> {
        guard self.length % MemoryLayout<Long>.size == 0 else {
            throw DataError.conversionError
        }
        
        let count = self.length / MemoryLayout<Long>.size
        var longArray = LongArray(repeating: 0, count: count)
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
        return AnySequence(longArray)
    }
    
    // MARK: Bool
    public func booleanSequence() -> AnySequence<Bool> {
        var tempBooleanArray = BooleanArray()
        var byteArray = self.byteArray
        let expectedSize: Int
        let byteOrder = ByteOrder.bigEndian
        
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
        
        return AnySequence(tempBooleanArray)
    }
    
    
    // MARK: - Private Stuff
    fileprivate func getByteAndIncreaseRangeLocation(_ range: inout NSRange) -> Byte {
        var tempByte: Byte = 0
        self.getBytes(&tempByte, range: range)
        range.location += 1
        return tempByte
    }
    
 }
