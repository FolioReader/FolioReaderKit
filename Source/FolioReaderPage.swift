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

protocol FolioReaderPageDelegate: class {
    /**
     Notify that page did loaded
     
     - parameter page: The loaded page
     */
    func pageDidLoad(page: FolioReaderPage)
}

class FolioReaderPage: UICollectionViewCell, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    weak var delegate: FolioReaderPageDelegate?
    var pageNumber: Int!
    var webView: UIWebView!
    private var colorView: UIView!
    private var shouldShowBar = true
    private var menuIsVisible = false
    
    // MARK: - View life cicle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        
        // TODO: Put the notification name in a Constants file
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshPageMode), name: "needRefreshPageMode", object: nil)
        
        if webView == nil {
            webView = UIWebView(frame: webViewFrame())
            webView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            webView.dataDetectorTypes = [.None, .Link]
            webView.scrollView.showsVerticalScrollIndicator = false
            webView.scrollView.showsHorizontalScrollIndicator = false
            webView.backgroundColor = UIColor.clearColor()
            
            self.contentView.addSubview(webView)
        }
        webView.delegate = self
        
        if readerConfig.scrollDirection == .horizontal {
            webView.scrollView.pagingEnabled = true
            webView.paginationMode = .LeftToRight
            webView.paginationBreakingMode = .Page
            webView.scrollView.bounces = false
        } else {
            webView.scrollView.bounces = true
        }
        
        if colorView == nil {
            colorView = UIView()
            colorView.backgroundColor = readerConfig.nightModeBackground
            webView.scrollView.addSubview(colorView)
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        webView.addGestureRecognizer(tapGestureRecognizer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        webView.frame = webViewFrame()
    }
    
    func webViewFrame() -> CGRect {
        let paddingTop: CGFloat = 20
        let paddingBottom: CGFloat = 30
        
        guard readerConfig.shouldHideNavigationOnTap else {
            let statusbarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
            let navBarHeight = FolioReader.sharedInstance.readerCenter.navigationController?.navigationBar.frame.size.height
            let navTotal = statusbarHeight + navBarHeight!
            let newFrame = CGRect(
                x: bounds.origin.x,
                y: isVerticalDirection(bounds.origin.y + navTotal, bounds.origin.y + navTotal + paddingTop),
                width: bounds.width,
                height: isVerticalDirection(bounds.height - navTotal, bounds.height - navTotal - paddingTop - paddingBottom))
            return newFrame
        }
        
        let newFrame = CGRect(
            x: bounds.origin.x,
            y: isVerticalDirection(bounds.origin.y, bounds.origin.y + paddingTop),
            width: bounds.width,
            height: isVerticalDirection(bounds.height, bounds.height - paddingTop - paddingBottom))
        return newFrame
    }
    
    func loadHTMLString(string: String!, baseURL: NSURL!) {
        
        var html = (string as NSString)
        
        // Restore highlights
        let highlights = Highlight.allByBookId((kBookId as NSString).stringByDeletingPathExtension, andPage: pageNumber)
        
        if highlights.count > 0 {
            for item in highlights {
                let style = HighlightStyle.classForStyle(item.type)
                let tag = "<highlight id=\"\(item.highlightId)\" onclick=\"callHighlightURL(this);\" class=\"\(style)\">\(item.content)</highlight>"
                var locator = item.contentPre + item.content + item.contentPost
                locator = Highlight.removeSentenceSpam(locator) /// Fix for Highlights
                let range: NSRange = html.rangeOfString(locator, options: .LiteralSearch)
                
                if range.location != NSNotFound {
                    let newRange = NSRange(location: range.location + item.contentPre.characters.count, length: item.content.characters.count)
                    html = html.stringByReplacingCharactersInRange(newRange, withString: tag)
                }
                else {
                    print("highlight range not found")
                }
            }
        }
        
        webView.alpha = 0
        webView.loadHTMLString(html as String, baseURL: baseURL)
    }
    
    // MARK: - UIWebView Delegate
    
    func webViewDidFinishLoad(webView: UIWebView) {
        refreshPageMode()
        
        if readerConfig.enableTTS && !book.hasAudio() {
            webView.js("wrappingSentencesWithinPTags()");
            
            if FolioReader.sharedInstance.readerAudioPlayer.isPlaying() {
                FolioReader.sharedInstance.readerAudioPlayer.readCurrentSentence()
            }
        }
        
        if scrollDirection == .negative() && isScrolling {
            let bottomOffset = isVerticalDirection(
                CGPointMake(0, webView.scrollView.contentSize.height - webView.scrollView.bounds.height),
                CGPointMake(webView.scrollView.contentSize.width - webView.scrollView.bounds.width, 0)
            )
            
            if bottomOffset.forDirection() >= 0 {
                dispatch_async(dispatch_get_main_queue(), {
                    webView.scrollView.setContentOffset(bottomOffset, animated: false)
                })
            }
        }
        
        UIView.animateWithDuration(0.2, animations: {webView.alpha = 1}) { finished in
            webView.isColors = false
            self.webView.createMenu(options: false)
        }

        delegate?.pageDidLoad(self)
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
        } else if url?.scheme == "play-audio" {

            let decoded = url?.absoluteString.stringByRemovingPercentEncoding as String!
            let playID = decoded.substringFromIndex(decoded.startIndex.advancedBy(13))
            let chapter = FolioReader.sharedInstance.readerCenter.getCurrentChapter()
            let href = chapter != nil ? chapter!.href : "";
            FolioReader.sharedInstance.readerAudioPlayer.playAudio(href, fragmentID: playID)

            return false
        } else if url?.scheme == "file" {
            
            let anchorFromURL = url?.fragment
            
            // Handle internal url
            if (url!.path! as NSString).pathExtension != "" {
                let base = (book.opfResource.href as NSString).stringByDeletingLastPathComponent
                let path = url?.path
                let splitedPath = path!.componentsSeparatedByString(base.isEmpty ? kBookId : base)
                
                // Return to avoid crash
                if splitedPath.count <= 1 || splitedPath[1].isEmpty {
                    return true
                }
                
                let href = splitedPath[1].stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "/"))
                let hrefPage = FolioReader.sharedInstance.readerCenter.findPageByHref(href)+1
                
                if hrefPage == pageNumber {
                    // Handle internal #anchor
                    if anchorFromURL != nil {
                        handleAnchor(anchorFromURL!, avoidBeginningAnchors: false, animated: true)
                        return false
                    }
                } else {
                    FolioReader.sharedInstance.readerCenter.changePageWith(href: href, animated: true)
                }
                
                return false
            }
            
            // Handle internal #anchor
            if anchorFromURL != nil {
                handleAnchor(anchorFromURL!, avoidBeginningAnchors: false, animated: true)
                return false
            }
            
            return true
        } else if url?.scheme == "mailto" {
            print("Email")
            return true
        } else if request.URL!.absoluteString != "about:blank" && navigationType == .LinkClicked {
            
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(URL: request.URL!)
                safariVC.view.tintColor = readerConfig.tintColor
                FolioReader.sharedInstance.readerCenter.presentViewController(safariVC, animated: true, completion: nil)
            } else {
                let webViewController = WebViewController(url: request.URL!)
                let nav = UINavigationController(rootViewController: webViewController)
                nav.view.tintColor = readerConfig.tintColor
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
    
    // MARK: - Scroll and positioning
    
    /**
     Scrolls the page to a given offset
     
     - parameter offset:   The offset to scroll
     - parameter animated: Enable or not scrolling animation
     */
    func scrollPageToOffset(offset: CGFloat, animated: Bool) {
        let pageOffsetPoint = isVerticalDirection(CGPoint(x: 0, y: offset), CGPoint(x: offset, y: 0))
        webView.scrollView.setContentOffset(pageOffsetPoint, animated: animated)
    }
    
    /**
     Handdle #anchors in html, get the offset and scroll to it
     
     - parameter anchor:                The #anchor
     - parameter avoidBeginningAnchors: Sometimes the anchor is on the beggining of the text, there is not need to scroll
     - parameter animated:              Enable or not scrolling animation
     */
    func handleAnchor(anchor: String,  avoidBeginningAnchors: Bool, animated: Bool) {
        if !anchor.isEmpty {
            let offset = getAnchorOffset(anchor)
            
            if readerConfig.scrollDirection == .vertical {
                let isBeginning = offset < frame.forDirection()/2
                
                if !avoidBeginningAnchors {
                    scrollPageToOffset(offset, animated: animated)
                } else if avoidBeginningAnchors && !isBeginning {
                    scrollPageToOffset(offset, animated: animated)
                }
            } else {
                scrollPageToOffset(offset, animated: animated)
            }
        }
    }
    
    /**
     Get the #anchor offset in the page
     
     - parameter anchor: The #anchor id
     - returns: The element offset ready to scroll
     */
    func getAnchorOffset(anchor: String) -> CGFloat {
        let horizontal = readerConfig.scrollDirection == .horizontal
        if let strOffset = webView.js("getAnchorOffset('\(anchor)', \(horizontal.description))") {
            return CGFloat((strOffset as NSString).floatValue)
        }
        
        return CGFloat(0)
    }
    
    // MARK: Mark ID
    
    /**
     Audio Mark ID - marks an element with an ID with the given class and scrolls to it
     
     - parameter ID: The ID
     */
    func audioMarkID(ID: String) {
        let currentPage = FolioReader.sharedInstance.readerCenter.currentPage
        currentPage.webView.js("audioMarkID('\(book.playbackActiveClass())','\(ID)')")
    }
    
    // MARK: UIMenu visibility
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if UIMenuController.sharedMenuController().menuItems?.count == 0 {
            webView.isColors = false
            webView.createMenu(options: false)
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    // MARK: ColorView fix for horizontal layout
    func refreshPageMode() {
        if FolioReader.sharedInstance.nightMode {
            // omit create webView and colorView
            let script = "document.documentElement.offsetHeight"
            let contentHeight = webView.stringByEvaluatingJavaScriptFromString(script)
            let frameHeight = webView.frame.height
            let lastPageHeight = frameHeight * CGFloat(webView.pageCount) - CGFloat(Double(contentHeight!)!)
            colorView.frame = CGRectMake(webView.frame.width * CGFloat(webView.pageCount-1), webView.frame.height - lastPageHeight, webView.frame.width, lastPageHeight)
        } else {
            colorView.frame = CGRectZero
        }
    }
}

// MARK: - WebView Highlight and share implementation

private var cAssociationKey: UInt8 = 0
private var sAssociationKey: UInt8 = 0

extension UIWebView {
    
    var isColors: Bool {
        get { return objc_getAssociatedObject(self, &cAssociationKey) as? Bool ?? false }
        set(newValue) {
            objc_setAssociatedObject(self, &cAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    var isShare: Bool {
        get { return objc_getAssociatedObject(self, &sAssociationKey) as? Bool ?? false }
        set(newValue) {
            objc_setAssociatedObject(self, &sAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {

        // menu on existing highlight
        if isShare {
            if action == #selector(UIWebView.colors(_:)) || (action == #selector(UIWebView.share(_:)) && readerConfig.allowSharing) || action == #selector(UIWebView.remove(_:)) {
                return true
            }
            return false

        // menu for selecting highlight color
        } else if isColors {
            if action == #selector(UIWebView.setYellow(_:)) || action == #selector(UIWebView.setGreen(_:)) || action == #selector(UIWebView.setBlue(_:)) || action == #selector(UIWebView.setPink(_:)) || action == #selector(UIWebView.setUnderline(_:)) {
                return true
            }
            return false

        // default menu
        } else {
            var isOneWord = false
            if let result = js("getSelectedText()") where result.componentsSeparatedByString(" ").count == 1 {
                isOneWord = true
            }
            
            if action == #selector(UIWebView.highlight(_:))
            || (action == #selector(UIWebView.define(_:)) && isOneWord)
            || (action == #selector(UIWebView.play(_:)) && (book.hasAudio() || readerConfig.enableTTS))
            || (action == #selector(UIWebView.share(_:)) && readerConfig.allowSharing)
            || (action == #selector(NSObject.copy(_:)) && readerConfig.allowSharing) {
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
        let highlightAndReturn = js("highlightString('\(HighlightStyle.classForStyle(FolioReader.sharedInstance.currentHighlightStyle))')")
        let jsonData = highlightAndReturn?.dataUsingEncoding(NSUTF8StringEncoding)
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as! NSArray
            let dic = json.firstObject as! [String: String]
            let rect = CGRectFromString(dic["rect"]!)
            let startOffset = dic["startOffset"]!
            let endOffset = dic["endOffset"]!
            
            // Force remove text selection
            userInteractionEnabled = false
            userInteractionEnabled = true

            createMenu(options: true)
            setMenuVisible(true, andRect: rect)
            
            // Persist
            let html = js("getHTML()")
            if let highlight = Highlight.matchHighlight(html, andId: dic["id"]!, startOffset: startOffset, endOffset: endOffset) {
                highlight.persist()
            }
        } catch {
            print("Could not receive JSON")
        }
    }

    func define(sender: UIMenuController?) {
        let selectedText = js("getSelectedText()")
        
        setMenuVisible(false)
        userInteractionEnabled = false
        userInteractionEnabled = true
        
        let vc = UIReferenceLibraryViewController(term: selectedText! )
        vc.view.tintColor = readerConfig.tintColor
        FolioReader.sharedInstance.readerContainer.showViewController(vc, sender: nil)
    }

    func play(sender: UIMenuController?) {
        FolioReader.sharedInstance.readerAudioPlayer.play()

        // Force remove text selection
        // @NOTE: this doesn't seem to always work
        userInteractionEnabled = false
        userInteractionEnabled = true
    }


    // MARK: - Set highlight styles
    
    func setYellow(sender: UIMenuController?) {
        changeHighlightStyle(sender, style: .Yellow)
    }
    
    func setGreen(sender: UIMenuController?) {
        changeHighlightStyle(sender, style: .Green)
    }
    
    func setBlue(sender: UIMenuController?) {
        changeHighlightStyle(sender, style: .Blue)
    }
    
    func setPink(sender: UIMenuController?) {
        changeHighlightStyle(sender, style: .Pink)
    }
    
    func setUnderline(sender: UIMenuController?) {
        changeHighlightStyle(sender, style: .Underline)
    }

    func changeHighlightStyle(sender: UIMenuController?, style: HighlightStyle) {
        FolioReader.sharedInstance.currentHighlightStyle = style.rawValue

        if let updateId = js("setHighlightStyle('\(HighlightStyle.classForStyle(style.rawValue))')") {
            Highlight.updateById(updateId, type: style)
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
        
        let highlightItem = UIMenuItem(title: readerConfig.localizedHighlightMenu, action: #selector(UIWebView.highlight(_:)))
        let playAudioItem = UIMenuItem(title: readerConfig.localizedPlayMenu, action: #selector(UIWebView.play(_:)))
        let defineItem = UIMenuItem(title: readerConfig.localizedDefineMenu, action: #selector(UIWebView.define(_:)))
        let colorsItem = UIMenuItem(title: "C", image: colors!, action: #selector(UIWebView.colors(_:)))
        let shareItem = UIMenuItem(title: "S", image: share!, action: #selector(UIWebView.share(_:)))
        let removeItem = UIMenuItem(title: "R", image: remove!, action: #selector(UIWebView.remove(_:)))
        let yellowItem = UIMenuItem(title: "Y", image: yellow!, action: #selector(UIWebView.setYellow(_:)))
        let greenItem = UIMenuItem(title: "G", image: green!, action: #selector(UIWebView.setGreen(_:)))
        let blueItem = UIMenuItem(title: "B", image: blue!, action: #selector(UIWebView.setBlue(_:)))
        let pinkItem = UIMenuItem(title: "P", image: pink!, action: #selector(UIWebView.setPink(_:)))
        let underlineItem = UIMenuItem(title: "U", image: underline!, action: #selector(UIWebView.setUnderline(_:)))
        
        let menuItems = [playAudioItem, highlightItem, defineItem, colorsItem, removeItem, yellowItem, greenItem, blueItem, pinkItem, underlineItem, shareItem]

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
      #if COCOAPODS
        self.init(title: title, action: action)
        self.cxa_initWithTitle(title, action: action, image: image, hidesShadow: true)
      #else
        let settings = CXAMenuItemSettings()
        settings.image = image
        settings.shadowDisabled = true
        self.init(title: title, action: action, settings: settings)
      #endif
    }
}
