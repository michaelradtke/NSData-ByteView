//
//  ByteOrder.swift
//  NSData+ByteView
//
//  Created by Michael Radtke on 24.11.15.
//  Copyright © 2015 abigale solutions. All rights reserved.
//

import Foundation

public enum ByteOrder {
    case BigEndian
    case LittleEndian
}


extension ByteOrder {
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
    
    func decomposeBytes(var bytes: BytesOfWord) -> Word {
        if self == .LittleEndian {
            swap(&bytes.b0, &bytes.b1)
        }
        let word = Word(bytes.b0) << 8 + Word(bytes.b1)
        return word
    }
    
    func decomposeBytes(var bytes: BytesOfDoubleWord) -> DoubleWord {
        if self == .LittleEndian {
            swap(&bytes.b0, &bytes.b3)
            swap(&bytes.b1, &bytes.b2)
        }
        let dWord1 = DoubleWord(bytes.b0) << 24 + DoubleWord(bytes.b1) << 16
        let dWord2 = DoubleWord(bytes.b2) << 8 + DoubleWord(bytes.b3)
        return dWord1 + dWord2
    }
    
    func decomposeBytes(var bytes: BytesOfLong) -> Long {
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
