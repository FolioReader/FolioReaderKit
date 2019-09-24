//
//  DataExtensions.swift
//  MarathonApp
//
//  Created by Shawn Miller on 9/9/19.
//

import Foundation
import CommonCrypto

public extension Data {
    /// Determines whether the data constitutes a valid JPEG
    ///
    /// - SeeAlso:
    ///     - [Based on this answer](http://stackoverflow.com/a/6790907)
    ///     - [and here](http://stackoverflow.com/a/9990940)
    ///     - [and verified here](http://en.wikipedia.org/wiki/JPEG#Syntax_and_structure)
    var isValidJPEG: Bool {
        guard count >= 4 else { return false }
        var isValid = false
        
        withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
            if pointer[0] == 0xFF, pointer[1] == 0xD8,
                pointer[count - 2] == 0xFF, pointer[count - 1] == 0xD9 {
                isValid = true
            }
        }
        return isValid
    }
    
    /// Convenience variable to return the data as a UInt8 array.
    var bytes: [UInt8] {
        let array = withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: count))
        }
        
        return array
    }
    
    /// Creates a data object with the contents of a URL. The contents of the
    /// file will be XOR'd with the provided key.
    ///
    /// If there is an issue opening the file at the URL, nil will be returned
    /// from this initializer.
    ///
    /// - Parameters:
    ///   - xorFileUrl: The URL of the file to open and perform the XOR on.
    ///   - withKey: The key to use to XOR the bytes.
    init?(xorFileUrl url: URL, withKey key: Data) {
        guard let stream = InputStream(url: url) else { return nil }
        self.init()
        stream.open()
        
        // Using a size too small here will slow things down.
        // This usually equals 1024. Which is a nice size here.
        let repeatingCount = 32
        let size = (key.count * repeatingCount)
        
        // Creating a repeated data array that matches the length of the desired size
        // this appears to be faster than accessing the index of the smaller array using
        // a mod'd value.
        let repeatingKey: [UInt8] = Array(repeating: key.bytes, count: repeatingCount)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: size)
        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: size)
            guard read != 0 else { break }
            
            // Using UnsafeMutablePointer here since it's also faster than
            // creating an array [UInt8] and calling `append` on it.
            let temp = UnsafeMutablePointer<UInt8>.allocate(capacity: read)
            
            for i in 0..<read {
                let xor = buffer[i] ^ repeatingKey[i]
                temp[i] = xor
            }
            
            self.append(temp, count: read)
            temp.deallocate()
        }
        
        buffer.deallocate()
        stream.close()
    }
    
    /// Returns a new Data block with all of the bytes XOR'd with the provided key.
    ///
    /// - Parameter keyData: the key to use to XOR the bytes.
    /// - Returns: A new Data object where all of the bytes are XOR'd with the key.
    /// - SeeAlso: [Swift Bitwise Operations](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/AdvancedOperators.html)
    func bitwiseXOR(with keyData: Data) -> Data {
        let keyBytes = keyData.bytes
        let temp = UnsafeMutablePointer<UInt8>.allocate(capacity: count)
        
        withUnsafeBytes { (pointer: UnsafePointer<UInt8>) in
            for i in 0..<count {
                let xor = pointer[i] ^ keyBytes[i % keyBytes.count]
                temp[i] = xor
            }
        }
        
        let newData = Data(bytes: temp, count: count)
        temp.deallocate()
        
        return newData
    }
    
    
    func sha256(data : Data) -> Data {
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return Data(hash)
    }
}


extension Array {
    init(repeating: [Element], count: Int) {
        self.init([[Element]](repeating: repeating, count: count).flatMap{$0})
    }
    
    func repeated(count: Int) -> [Element] {
        return [Element](repeating: self, count: count)
    }
}
