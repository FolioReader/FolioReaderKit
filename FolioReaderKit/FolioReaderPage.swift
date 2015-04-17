//
//  FolioReaderPage.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 10/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

@objc protocol FolioPageDelegate {
    optional func pageDidLoad(page: FolioReaderPage)
}

class FolioReaderPage: UICollectionViewCell, UIWebViewDelegate {
    
    var webView: UIWebView!
    var delegate: FolioPageDelegate!
    
    // MARK: - View life cicle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        
        if webView == nil {
            webView = UIWebView(frame: self.bounds)
            webView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            webView.backgroundColor = UIColor.whiteColor()
            self.addSubview(webView)
        }
        webView.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func loadHTMLString(string: String) {
        webView.alpha = 0
        webView.loadHTMLString(string, baseURL: nil)
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
