//
//  Data+ByteView.swift
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

public extension Data {

	public enum DataError: Error {
		case conversionError
	}
	
	
	// MARK: - Creating Data Objects
	
	// MARK: Byte
	public init<S: Sequence>(byteSequence: S) where S.Iterator.Element == Byte {
		let byteArray = Array.init(byteSequence)
		self.init(bytes: byteArray)
		//(self as NSData).init(bytes: byteArray, length: byteArray.count)
	}

	public init(bytes: Byte...) {
		self.init(bytes: bytes)
		//(self as NSData).init(bytes: bytes, length: bytes.count)
	}

	// MARK: Word
	public init<S: Sequence>(wordSequence: S, byteOrder: ByteOrder = .bigEndian) where S.Iterator.Element == SingleWord {
		var tempByteArray = ByteArray()
		for word in wordSequence {
			tempByteArray.append(contentsOf: byteOrder.composeBytesFor(word))
		}
		self.init(tempByteArray)
		//(self as NSData).init(bytes: tempByteArray, length: tempByteArray.count)
	}
	
	public init(bigEndianWords words: SingleWord...) {
		self.init(wordSequence: words, byteOrder: .bigEndian)
	}
	
	public init(litteEndianWords words: SingleWord...) {
		self.init(wordSequence: words, byteOrder: .littleEndian)
	}
	
	// MARK: DoubleWord
	public init<S: Sequence>(doubleWordSequence: S, byteOrder: ByteOrder = .bigEndian) where S.Iterator.Element == DoubleWord {
		var tempByteArray = ByteArray()
		for dWord in doubleWordSequence {
			tempByteArray.append(contentsOf: byteOrder.composeBytesFor(dWord))
		}
		self.init(tempByteArray)
		//(self as NSData).init(bytes: tempByteArray, length: tempByteArray.count)
	}
	
	public init(bigEndianDoubleWords words: DoubleWord...) {
		self.init(doubleWordSequence: words, byteOrder: .bigEndian)
	}
	
	public init(litteEndianDoubleWords words: DoubleWord...) {
		self.init(doubleWordSequence: words, byteOrder: .littleEndian)
	}
	
	// MARK: Long
	public init<S: Sequence>(longSequence: S, byteOrder: ByteOrder = .bigEndian) where S.Iterator.Element == Long {
		var tempByteArray = ByteArray()
		for long in longSequence {
			tempByteArray.append(contentsOf: byteOrder.composeBytesFor(long))
		}
		self.init(tempByteArray)
		//(self as NSData).init(bytes: tempByteArray, length: tempByteArray.count)
	}
	
	public init(bigEndianLongs longs: Long...) {
		self.init(longSequence: longs, byteOrder: .bigEndian)
	}
	
	public init(littleEndianLongs longs: Long...) {
		self.init(longSequence: longs, byteOrder: .littleEndian)
	}
	
	
	// MARK: Bool
	public init<S: Sequence>(booleanSequence: S) where S.Iterator.Element == Bool {
		var booleanArray = Array.init(booleanSequence)
		if booleanArray.isEmpty {
			self.init()
			//(self as NSData).init()
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
				// More than 5 booleans have to be stored along with the size information in dedicated bytes
				tempByteStartingValue = 0
				let byteOrder = ByteOrder.bigEndian
				
				switch correctedBoolCount {
				case 0..<256:               tempByteArray = [Byte(correctedBoolCount)]
				case 256..<65_536:          tempByteArray = byteOrder.composeBytesFor(SingleWord(correctedBoolCount))
				case 65_536..<Int.max:		tempByteArray = byteOrder.composeBytesFor(DoubleWord(correctedBoolCount))
				default:                    tempByteArray = byteOrder.composeBytesFor(Long(correctedBoolCount))
				}
			}
			
			// Compose one byte out of eight boolean values
			let startBitPosition: Byte = 0b00000001
			while booleanArray.count > 0 {
				let chunckCount = booleanArray.count < 8 ? booleanArray.count : 8	// TODO: Check why min(booleanArray.count,8) does not work here but in NSData+ByteView
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

	public init(booleans: Bool...) {
		self.init(booleanSequence: booleans)
	}
	
	
	// MARK: HexString
	public init(hexString: String) throws {
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
		return (self as NSData).hexString
	}

	// MARK: Byte
	public var byteArray: [Byte] {
		return (self as NSData).byteArray
	}

	public func byteSequence() -> AnySequence<Byte>{
		return AnySequence(byteArray)
	}

	// MARK: Word
	public func wordSequence(byteOrder: ByteOrder = .bigEndian) throws -> AnySequence<SingleWord> {
		return try (self as NSData).wordSequence(byteOrder: byteOrder)
	}
	
	// MARK: DoubleWord
	public func doubleWordSequence(byteOrder: ByteOrder = .bigEndian) throws -> AnySequence<DoubleWord> {
		return try (self as NSData).doubleWordSequence(byteOrder: byteOrder)
	}
	
	// MARK: Long
	public func longSequence(byteOrder: ByteOrder = .bigEndian) throws -> AnySequence<Long> {
		return try (self as NSData).longSequence(byteOrder: byteOrder)
	}
	
	// MARK: Bool
	public func booleanSequence() -> AnySequence<Bool> {
		return (self as NSData).booleanSequence()
	}
}
