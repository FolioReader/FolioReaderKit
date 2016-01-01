//
//  FolioReaderPage.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 10/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import SafariServices
import UIMenuItem_CXAImageSupport
import JSQWebViewController

@objc protocol FolioPageDelegate {
    optional func pageDidLoad(page: FolioReaderPage)
}

class FolioReaderPage: UICollectionViewCell, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    var pageNumber: Int!
    var webView: UIWebView!
    var delegate: FolioPageDelegate!
    private var shouldShowBar = true
    private var menuIsVisible = false
    
    // MARK: - View life cicle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        
        if webView == nil {
            webView = UIWebView(frame: webViewFrame())
            webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            webView.dataDetectorTypes = [.None, .Link]
            webView.backgroundColor = UIColor.clearColor()
            self.contentView.addSubview(webView)
        }
        webView.delegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        webView.addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        webView.frame = webViewFrame()
    }
    
    func webViewFrame() -> CGRect {
        if readerConfig.shouldHideNavigationOnTap == false {
            let statusbarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
            let navBarHeight = FolioReader.sharedInstance.readerCenter.navigationController?.navigationBar.frame.size.height
            let navTotal = statusbarHeight + navBarHeight!
            let newFrame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y+navTotal, width: self.bounds.width, height: self.bounds.height-navTotal)
            return newFrame
        } else {
            return self.bounds
        }
    }
    
    func loadHTMLString(string: String!, baseURL: NSURL!) {
        
        var html = (string as NSString)
        
        // Restore highlights
        let highlights = Highlight.allByBookId((kBookId as NSString).stringByDeletingPathExtension, andPage: pageNumber)
        
        if highlights.count > 0 {
            for item in highlights {
                let style = HighlightStyle.classForStyle(item.type.integerValue)
                let tag = "<highlight id=\"\(item.highlightId)\" onclick=\"callHighlightURL(this);\" class=\"\(style)\">\(item.content)</highlight>"
                let locator = item.contentPre + item.content + item.contentPost
                let range: NSRange = html.rangeOfString(locator, options: .LiteralSearch)
                
                if range.location != NSNotFound {
                    let newRange = NSRange(location: range.location + item.contentPre.characters.count, length: item.content.characters.count)
                    html = html.stringByReplacingCharactersInRange(newRange, withString: tag)
                }
            }
        }
        
        webView.alpha = 0
        webView.loadHTMLString(html as String, baseURL: baseURL)
    }
    
    // MARK: - UIWebView Delegate
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        webView.scrollView.contentSize = CGSizeMake(pageWidth, webView.scrollView.contentSize.height)
        
        if scrollDirection == .Down && isScrolling {
            let bottomOffset = CGPointMake(0, webView.scrollView.contentSize.height - webView.scrollView.bounds.height)
            if bottomOffset.y >= 0 {
                dispatch_async(dispatch_get_main_queue(), {
                    webView.scrollView.setContentOffset(bottomOffset, animated: false)
                })
            }
        }
        
        UIView.animateWithDuration(0.2, animations: {webView.alpha = 1}) { finished in
            webView.isColors = false
            self.webView.createMenu(options: false)
        }
        
        delegate.pageDidLoad!(self)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let url = request.URL
        
        if url?.scheme == "highlight" {
            
            shouldShowBar = false
            
            let decoded = url?.absoluteString.stringByRemovingPercentEncoding as String!
            let rect = CGRectFromString(decoded.substringFromIndex(decoded.startIndex.advancedBy(12)))
            
            webView.createMenu(options: true)
            webView.setMenuVisible(true, andRect: rect)
            menuIsVisible = true
            
            return false
        } else if url?.scheme == "file" {
            
            let anchorFromURL = url?.fragment
            
            // Handle internal url
            if (url!.path! as NSString).pathExtension != "" {
                let base = (book.opfResource.href as NSString).stringByDeletingLastPathComponent
                let path = url?.path
                let splitedPath = path!.componentsSeparatedByString(base)
                let href = splitedPath[1].stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "/"))
                let hrefPage = FolioReader.sharedInstance.readerCenter.findPageByHref(href)+1
                
                if hrefPage == pageNumber {
                    // Handle internal #anchor
                    if anchorFromURL != nil {
                        handleAnchor(anchorFromURL!, avoidBeginningAnchors: false, animating: true)
                        return false
                    }
                } else {
                    FolioReader.sharedInstance.readerCenter.changePageWith(href: href)
                }
                
                return false
            }
            
            // Handle internal #anchor
            if anchorFromURL != nil {
                handleAnchor(anchorFromURL!, avoidBeginningAnchors: false, animating: true)
                return false
            }
            
            return true
        } else if url?.scheme == "mailto" {
            print("Email")
            return true
        } else if request.URL!.absoluteString != "about:blank" && navigationType == .LinkClicked {
            
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(URL: request.URL!)
                safariVC.view.tintColor = readerConfig.toolBarBackgroundColor
                FolioReader.sharedInstance.readerCenter.presentViewController(safariVC, animated: true, completion: nil)
            } else {
                let webViewController = WebViewController(url: request.URL!)
                let nav = UINavigationController(rootViewController: webViewController)
                nav.view.tintColor = readerConfig.toolBarBackgroundColor
                FolioReader.sharedInstance.readerCenter.presentViewController(nav, animated: true, completion: nil)
            }
            
            return false
        }
        
        return true
    }
    
    // MARK: Gesture recognizer
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.view is UIWebView {
            if otherGestureRecognizer is UILongPressGestureRecognizer {
                if UIMenuController.sharedMenuController().menuVisible {
                    webView.setMenuVisible(false)
                }
                return false
            }
            return true
        }
        return false
    }
    
    func handleTapGesture(recognizer: UITapGestureRecognizer) {
//        webView.setMenuVisible(false)
        
        if FolioReader.sharedInstance.readerCenter.navigationController!.navigationBarHidden {
            let menuIsVisibleRef = menuIsVisible
            
            let selected = webView.js("getSelectedText()")

            if selected == nil || selected!.characters.count == 0 {
                let seconds = 0.4
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    
                    if self.shouldShowBar && !menuIsVisibleRef {
                        FolioReader.sharedInstance.readerCenter.toggleBars()
                    }
                    self.shouldShowBar = true
                })
            }
        } else if readerConfig.shouldHideNavigationOnTap == true {
            FolioReader.sharedInstance.readerCenter.hideBars()
        }
        
        // Reset menu
        menuIsVisible = false
    }
    
    // MARK: - Scroll positioning
    
    func scrollPageToOffset(offset: String, animating: Bool) {
        let jsCommand = "window.scrollTo(0,\(offset));"
        if animating {
            UIView.animateWithDuration(0.35, animations: {
                self.webView.js(jsCommand)
            })
        } else {
            webView.js(jsCommand)
        }
    }
    
    func handleAnchor(anchor: String,  avoidBeginningAnchors: Bool, animating: Bool) {
        if !anchor.isEmpty {
            let offset = getAnchorOffset(anchor)
            let isBeginning = CGFloat((offset as NSString).floatValue) > self.frame.height/2
            
            if !avoidBeginningAnchors {
                scrollPageToOffset(offset, animating: animating)
            } else if avoidBeginningAnchors && isBeginning {
                scrollPageToOffset(offset, animating: animating)
            }
        }
    }
    
    func getAnchorOffset(anchor: String) -> String {
        let jsAnchorHandler = "(function() {var target = '\(anchor)';var elem = document.getElementById(target); if (!elem) elem=document.getElementsByName(target)[0];return elem.offsetTop;})();"
        
        return webView.js(jsAnchorHandler)!
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if UIMenuController.sharedMenuController().menuItems?.count == 0 {
            webView.isColors = false
            webView.createMenu(options: false)
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
}

// MARK: - WebView Highlight and share implementation

private var cAssociationKey: UInt8 = 0
private var sAssociationKey: UInt8 = 0

extension UIWebView {
    
    var isColors: Bool {
        get { return objc_getAssociatedObject(self, &cAssociationKey) as! Bool }
        set(newValue) {
            objc_setAssociatedObject(self, &cAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var isShare: Bool {
        get {return objc_getAssociatedObject(self, &sAssociationKey) as! Bool}
        set(newValue) {
            objc_setAssociatedObject(self, &sAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if isShare {
            if action == "colors:" || action == "share:" || action == "remove:" {
                return true
            }
            return false
        } else if isColors {
            if action == "setYellow:" || action == "setGreen:" || action == "setBlue:" || action == "setPink:" || action == "setUnderline:" {
                return true
            }
            return false
        } else {
            if action == "highlight:" || action == "share:" || action == "copy:" {
                return true
            }
            return false
        }
    }
    
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func share(sender: UIMenuController) {
        
        if isShare {
            if let textToShare = js("getHighlightContent()") {
                FolioReader.sharedInstance.readerCenter.shareHighlight(textToShare, rect: sender.menuFrame)
            }
        } else {
            if let textToShare = js("getSelectedText()") {
                FolioReader.sharedInstance.readerCenter.shareHighlight(textToShare, rect: sender.menuFrame)
            }
        }
        
        setMenuVisible(false)
    }
    
    func colors(sender: UIMenuController?) {
        isColors = true
        createMenu(options: false)
        setMenuVisible(true)
    }
    
    func remove(sender: UIMenuController?) {
        if let removedId = js("removeThisHighlight()") {
            Highlight.removeById(removedId)
        }
        
        setMenuVisible(false)
    }
    
    func highlight(sender: UIMenuController?) {
        let highlightAndReturn = js("highlightString()")
        let jsonData = highlightAndReturn?.dataUsingEncoding(NSUTF8StringEncoding)
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as! NSArray
            let dic = json.firstObject as! [String: String]
            let rect = CGRectFromString(dic["rect"]!)
            
            // Force remove text selection
            userInteractionEnabled = false
            userInteractionEnabled = true
            
            createMenu(options: true)
            setMenuVisible(true, andRect: rect)
            
            // Persist
            let html = js("getHTML()")
            if let highlight = FRHighlight.matchHighlight(html, andId: dic["id"]!) {
                Highlight.persistHighlight(highlight, completion: nil)
            }
        } catch {
            print("Could not receive JSON")
        }
    }
    
    // MARK: - Set highlight styles
    
    func setYellow(sender: UIMenuController?) {
        if let updateId = js("setYellow()") {
            Highlight.updateById(updateId, type: .Yellow)
        }
        colors(sender)
    }
    
    func setGreen(sender: UIMenuController?) {
        if let updateId = js("setGreen()") {
            Highlight.updateById(updateId, type: .Green)
        }
        colors(sender)
    }
    
    func setBlue(sender: UIMenuController?) {
        if let updateId = js("setBlue()") {
            Highlight.updateById(updateId, type: .Blue)
        }
        colors(sender)
    }
    
    func setPink(sender: UIMenuController?) {
        if let updateId = js("setPink()") {
            Highlight.updateById(updateId, type: .Pink)
        }
        colors(sender)
    }
    
    func setUnderline(sender: UIMenuController?) {
        if let updateId = js("setUnderline()") {
            Highlight.updateById(updateId, type: .Underline)
        }
        colors(sender)
    }
    
    // MARK: - Create and show menu
    
    func createMenu(options options: Bool) {
        isShare = options
        
        let colors = UIImage(readerImageNamed: "colors-marker")
        let share = UIImage(readerImageNamed: "share-marker")
        let remove = UIImage(readerImageNamed: "no-marker")
        let yellow = UIImage(readerImageNamed: "yellow-marker")
        let green = UIImage(readerImageNamed: "green-marker")
        let blue = UIImage(readerImageNamed: "blue-marker")
        let pink = UIImage(readerImageNamed: "pink-marker")
        let underline = UIImage(readerImageNamed: "underline-marker")
        
        let highlightItem = UIMenuItem(title: readerConfig.localizedHighlightMenu, action: "highlight:")
        let colorsItem = UIMenuItem(title: "C", image: colors!, action: "colors:")
        let shareItem = UIMenuItem(title: "S", image: share!, action: "share:")
        let removeItem = UIMenuItem(title: "R", image: remove!, action: "remove:")
        let yellowItem = UIMenuItem(title: "Y", image: yellow!, action: "setYellow:")
        let greenItem = UIMenuItem(title: "G", image: green!, action: "setGreen:")
        let blueItem = UIMenuItem(title: "B", image: blue!, action: "setBlue:")
        let pinkItem = UIMenuItem(title: "P", image: pink!, action: "setPink:")
        let underlineItem = UIMenuItem(title: "U", image: underline!, action: "setUnderline:")
        
        var menuItems = [highlightItem, colorsItem, removeItem, yellowItem, greenItem, blueItem, pinkItem, underlineItem]
        if !isColors { menuItems.append(shareItem) }
        UIMenuController.sharedMenuController().menuItems = menuItems
    }
    
    func setMenuVisible(menuVisible: Bool, animated: Bool = true, andRect rect: CGRect = CGRectZero) {
        if !menuVisible && isShare || !menuVisible && isColors {
            isColors = false
            isShare = false
        }
        
        if menuVisible  {
            if !CGRectEqualToRect(rect, CGRectZero) {
                UIMenuController.sharedMenuController().setTargetRect(rect, inView: self)
            }
        }
        
        UIMenuController.sharedMenuController().setMenuVisible(menuVisible, animated: animated)
    }
    
    func js(script: String) -> String? {
        let callback = self.stringByEvaluatingJavaScriptFromString(script)
        if callback!.isEmpty { return nil }
        return callback
    }
}

extension UIMenuItem {
    convenience init(title: String, image: UIImage, action: Selector) {
        self.init(title: title, action: action)
        self.cxa_initWithTitle(title, action: action, image: image, hidesShadow: true)
    }
}
