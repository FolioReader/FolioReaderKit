//
//  BookProviderURLProtocol.swift
//  FolioReaderKit
//
//  Created by David Pei on 9/24/19.
//

import Foundation


final class BookProviderURLProtocol: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        print("URLProtocol intercepts: \(request)")
        if let url = request.url,
            !url.hasDirectoryPath,
            url.absoluteString.hasPrefix( BookProvider.shared.currentBook.baseURL.absoluteString) {
            return true
        }
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        print("start loading: \(request.url)")
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: BookProviderURLProtocolError.urlNotExist)
            return
        }
        var hrefSubStr = url.absoluteString.dropFirst(BookProvider.shared.currentBook.baseURL.absoluteString.count)
        if hrefSubStr.hasPrefix("/") {
            hrefSubStr = hrefSubStr.dropFirst()
        }
        let href = String(hrefSubStr)
        
        if let data = BookProvider.shared.currentBook.resources.findByHref(String(href))?.data {
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
    }
    
    override func stopLoading() {
        //do nothing
    }
    
}

enum BookProviderURLProtocolError: Error {
    case urlNotExist
}
