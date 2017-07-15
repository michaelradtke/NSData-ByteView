//
//  Types.swift
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


public typealias Byte            = UInt8
public typealias SingleWord      = UInt16
public typealias DoubleWord      = UInt32
public typealias Long            = UInt64

public enum HexStringError: Error {
    case insufficientLength
    case insufficientCharacters
}


typealias ByteArray       = [Byte]
typealias SingleWordArray = [SingleWord]
typealias DoubleWordArray = [DoubleWord]
typealias LongArray       = [Long]
typealias BooleanArray    = [Bool]

typealias BytesOfSingleWord = (b0: Byte, b1: Byte)
typealias BytesOfDoubleWord = (b0: Byte, b1: Byte, b2: Byte, b3:Byte)
typealias BytesOfLong       = (b0: Byte, b1: Byte, b2: Byte, b3:Byte, b4: Byte, b5: Byte, b6: Byte, b7:Byte)
