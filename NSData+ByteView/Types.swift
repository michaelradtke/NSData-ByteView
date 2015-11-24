//
//  Types.swift
//  NSData+ByteView
//
//  Created by Michael Radtke on 24.11.15.
//  Copyright © 2015 abigale solutions. All rights reserved.
//

public typealias Byte            = UInt8
public typealias Word            = UInt16
public typealias DoubleWord      = UInt32
public typealias Long            = UInt64

public typealias ByteArray       = [Byte]
public typealias WordArray       = [Word]
public typealias DoubleWordArray = [DoubleWord]
public typealias LongArray       = [Long]
public typealias BooleanArray    = [Bool]

typealias BytesOfWord            = (b0: Byte, b1: Byte)
typealias BytesOfDoubleWord      = (b0: Byte, b1: Byte, b2: Byte, b3:Byte)
typealias BytesOfLong            = (b0: Byte, b1: Byte, b2: Byte, b3:Byte, b4: Byte, b5: Byte, b6: Byte, b7:Byte)