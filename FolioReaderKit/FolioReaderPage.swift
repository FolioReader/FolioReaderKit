//
//  FolioReaderPage.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 10/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import WebKit

@objc protocol FolioPageDelegate {
    optional func pageDidLoad(page: FolioReaderPage)
}

//private let hasWebKit = NSClassFromString("WKWebView") != nil
private let hasWebKit = false

class FolioReaderPage: UICollectionViewCell, WKNavigationDelegate, UIWebViewDelegate {
    
    var webView: AnyObject!
    var delegate: FolioPageDelegate!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.whiteColor()
        
        if webView == nil {
            if hasWebKit {
                let config = WKWebViewConfiguration()
                webView = WKWebView(frame: self.bounds, configuration: config)
            } else {
                webView = UIWebView(frame: self.bounds)
            }
        }
        
        if hasWebKit {
            let wkWebView = (webView as! WKWebView)
            wkWebView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            wkWebView.navigationDelegate = self
            wkWebView.backgroundColor = UIColor.whiteColor()
            self.addSubview(wkWebView)
        }
        else {
            let uiWebView = (webView as! UIWebView)
            uiWebView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            uiWebView.delegate = self
            uiWebView.backgroundColor = UIColor.whiteColor()
            self.addSubview(uiWebView)
        }
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadHTMLString(string: String) {
        if hasWebKit {
            var castWebView = (webView as! WKWebView)
            castWebView.alpha = 0
            castWebView.loadHTMLString(string, baseURL: nil)
        } else {
            var castWebView = (webView as! UIWebView)
            castWebView.alpha = 0
            castWebView.loadHTMLString(string, baseURL: nil)
        }
    }
    
    // MARK: - WKWebView Navigation Delegate
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        if scrollDirection == .Down {
            let bottomOffset = CGPointMake(0, webView.scrollView.contentSize.height - webView.scrollView.bounds.height)
            if bottomOffset.y >= 0 {
                dispatch_async(dispatch_get_main_queue(), {
                    webView.scrollView.setContentOffset(bottomOffset, animated: false)
                })
            }
        }
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            webView.alpha = 1
        })
        
        delegate.pageDidLoad!(self)
    }
    
    // MARK: - UIWebView Delegate
    
    func webViewDidFinishLoad(webView: UIWebView) {
        if scrollDirection == .Down {
            let bottomOffset = CGPointMake(0, webView.scrollView.contentSize.height - webView.scrollView.bounds.height)
            if bottomOffset.y >= 0 {
                dispatch_async(dispatch_get_main_queue(), {
                    webView.scrollView.setContentOffset(bottomOffset, animated: false)
                })
            }
        }
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            webView.alpha = 1
        })
        
        delegate.pageDidLoad!(self)
    }
    
}
