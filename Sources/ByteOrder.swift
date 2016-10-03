//
//  ByteOrder.swift
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

public enum ByteOrder {
    case bigEndian
    case littleEndian
}


extension ByteOrder {
    func composeBytesFor(_ word: SingleWord) -> ByteArray {
        let byteArray: ByteArray = [
            Byte(word >> 8),
            Byte(word & 0x00FF)
        ]
        return respectByteOrder(byteArray)
    }
    
    func composeBytesFor(_ dWord: DoubleWord) -> ByteArray {
        let byteArray: ByteArray = [
            Byte(dWord >> 24),
            Byte((dWord & 0x00FF0000) >> 16),
            Byte((dWord & 0x0000FF00) >> 8),
            Byte( dWord & 0x000000FF)
        ]
        return respectByteOrder(byteArray)
    }
    
    func composeBytesFor(_ long: Long) -> ByteArray {
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
    
    func decomposeBytes(_ bytes: BytesOfWord) -> SingleWord {
        var bytes = bytes
        
        if self == .littleEndian {
            swap(&bytes.b0, &bytes.b1)
        }
        let word = SingleWord(bytes.b0) << 8 + SingleWord(bytes.b1)
        return word
    }
    
    func decomposeBytes(_ bytes: BytesOfDoubleWord) -> DoubleWord {
        var bytes = bytes
        
        if self == .littleEndian {
            swap(&bytes.b0, &bytes.b3)
            swap(&bytes.b1, &bytes.b2)
        }
        let dWord1 = DoubleWord(bytes.b0) << 24 + DoubleWord(bytes.b1) << 16
        let dWord2 = DoubleWord(bytes.b2) << 8 + DoubleWord(bytes.b3)
        return dWord1 + dWord2
    }
    
    func decomposeBytes(_ bytes: BytesOfLong) -> Long {
        var bytes = bytes
        
        if self == .littleEndian {
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
    
    
    func respectByteOrder(_ byteArray: ByteArray) -> ByteArray {
        switch self {
        case .bigEndian:
            return byteArray
        case .littleEndian:
            return byteArray.reversed()
        }
    }
    
}
