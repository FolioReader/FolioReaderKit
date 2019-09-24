//
//  EpubDecryptor.swift
//  MarathonApp
//
//  Created by Shawn Miller on 9/11/19.
//

import Foundation
import CommonCrypto

public struct ePubDecryptor {
    public var ePubData: NSData
    public var keyData: NSData
    public var initializationVector: NSData
    public var sizeData: NSData
    
    public init(with encryptedData: NSData, and keyData: NSData) {
        self.keyData = keyData
        self.sizeData = ePubDecryptor.getSize(from: encryptedData)
        self.initializationVector = ePubDecryptor.getInitializationVector(from: encryptedData)
        self.ePubData = ePubDecryptor.getEncryptedEpubData(from: encryptedData)
    }
    
    public func decrypt() throws -> Data? {
        var status: CCCryptorStatus
        let result = NSMutableData(length: ePubData.length) ?? NSMutableData()
        var resultLength: size_t = 0
        
        status = CCCrypt(CCOperation(kCCDecrypt),
                         CCAlgorithm(kCCAlgorithmAES),
                         0,
                         keyData.bytes,
                         keyData.length,
                         initializationVector.bytes,
                         ePubData.bytes,
                         ePubData.length,
                         result.mutableBytes,
                         result.length,
                         &resultLength)
        
        if status != kCCSuccess {
            throw NSError(domain: "ePubDecryptor", code: 1, userInfo: ["statusCode": status])
        }
        
        let size = sizeOfData
        result.length = resultLength
        
        let range = NSRange(location: 0, length: size)
        return result.subdata(with: range)
    }
    
}

extension ePubDecryptor {
    public var sizeOfData: Int {
        var size: Int = 0
        sizeData.getBytes(&size, length: MemoryLayout.size(ofValue: size))
        return size
    }
    
    static public func getSize(from data: NSData) -> NSData {
        let length: Int = 8
        let range = NSRange(location: 0, length: length)
        return NSData(data: data.subdata(with: range))
    }
    
    static public func getInitializationVector(from data: NSData) -> NSData {
        let length: Int = 16
        let range = NSRange(location: 8, length: length)
        return NSData(data: data.subdata(with: range))
    }
    
    static public func getEncryptedEpubData(from data: NSData) -> NSData {
        let start: Int = 24
        let length = data.length - start
        let range = NSRange(location: start, length: length)
        return NSData(data: data.subdata(with: range))
    }
}
