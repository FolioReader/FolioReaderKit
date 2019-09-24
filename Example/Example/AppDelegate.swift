//
//  AppDelegate.swift
//  Example
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import FolioReaderKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        URLProtocol.registerClass(MockURLProtocol.self)
        return true
    }
}

final class MockURLProtocol: URLProtocol {
    
    override class func canInit(with request: URLRequest) -> Bool {
        print("MockURLProtocol intercepts: \(request)")
        if let url = request.url, url.absoluteString == "file:///localHost/Styles/style.css" {
            return true
        }
        return false
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        print("start loading: \(request.url)")
        //do nothing
//        self.client?.urlProtocol(self, didLoad: Data())
//        client?.urlProtocol(self, didReceive: URLResponse(url: request.url!, mimeType: nil, expectedContentLength: -1, textEncodingName: nil), cacheStoragePolicy: .allowed)
        let cssString = ""
        client?.urlProtocol(self, didLoad: cssString.data(using: .utf8)!)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        //do nothing
    }
    
}
