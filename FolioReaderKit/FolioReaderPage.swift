//
//  FolioReaderPage.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 10/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import WebKit

class FolioReaderPage: UICollectionViewCell {
    
    var webView: AnyObject!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.redColor()
        
        if webView == nil {
            if (NSClassFromString("WKWebView") != nil) {
                let config = WKWebViewConfiguration()
                webView = WKWebView(frame: self.bounds, configuration: config)
                (webView as! WKWebView).backgroundColor = getRandomColor()
                (webView as! WKWebView).autoresizingMask = .FlexibleWidth | .FlexibleHeight
                self.addSubview(webView as! WKWebView)
            }
            else {
                webView = UIWebView(frame: self.bounds)
                (webView as! UIWebView).autoresizingMask = .FlexibleWidth | .FlexibleHeight
                self.addSubview(webView as! UIWebView)
            }
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadHTMLString(string: String) {
        var castWebView = (webView as! WKWebView)
        castWebView.loadHTMLString(string, baseURL: nil)
    }
    
    func getRandomColor() -> UIColor {
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}
