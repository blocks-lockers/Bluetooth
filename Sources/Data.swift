//
//  Data.swift
//  Bluetooth
//
//  Created by Alsey Coleman Miller on 5/30/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation

internal extension Data {
    
    #if swift(>=4.2)
    func subdataNoCopy(in range: Range<Int>) -> Data {
        
        // stored in heap, can reuse buffer
        if count > Data.inlineBufferSize {
            
             return withUnsafeBytes {
                Data(bytesNoCopy: UnsafeMutableRawPointer(mutating: $0.advanced(by: range.lowerBound)),
                     count: range.count,
                     deallocator: .none)
            }
            
        } else {
            
            // stored in stack, must copy
            return subdata(in: range)
        }
    }
    #else
    func subdataNoCopy(in range: CountableRange<Int>) -> Data {
        
        let pointer = withUnsafeBytes { UnsafeMutableRawPointer(mutating: $0).advanced(by: range.lowerBound) }
        return Data(bytesNoCopy: pointer, count: range.count, deallocator: .none)
    }
    
    /// Returns a new copy of the data in a specified range.
    func subdata(in range: CountableRange<Int>) -> Data {
        return Data(self[range])
    }
    #endif
    
    func suffixNoCopy(from index: Int) -> Data {
        
        return subdataNoCopy(in: index ..< count)
    }
    
    func suffixCheckingBounds(from start: Int) -> Data {
        
        if count > start {
            
            return Data(suffix(from: start))
            
        } else {
            
            return Data()
        }
    }
}

#if swift(>=5.0) || swift(>=4.2)
private extension Data {
    
    /// Size of the inline buffer for `Foundation.Data` used in Swift 5.
    ///
    /// Used to determine wheather data is stored on stack or in heap.
    static var inlineBufferSize: Int {
        
        // Keep up to date
        // https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/Data.swift#L621
        #if arch(x86_64) || arch(arm64) || arch(s390x) || arch(powerpc64) || arch(powerpc64le)
        typealias Buffer = (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) //len  //enum
        #elseif arch(i386) || arch(arm)
        typealias Buffer = (UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8)
        #endif
        
        return MemoryLayout<Buffer>.size
    }
}
#endif
