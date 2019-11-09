//
//  FolioReaderPage.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 10/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import WebKit
import SafariServices
import MenuItemKit

/// Protocol which is used from `FolioReaderPage`s.
@objc public protocol FolioReaderPageDelegate: class {

    /**
     Notify that the page will be loaded. Note: The webview content itself is already loaded at this moment. But some java script operations like the adding of class based on click listeners will happen right after this method. If you want to perform custom java script before this happens this method is the right choice. If you want to modify the html content (and not run java script) you have to use `htmlContentForPage()` from the `FolioReaderCenterDelegate`.

     - parameter page: The loaded page
     */
    @objc optional func pageWillLoad(_ page: FolioReaderPage)

    /**
     Notifies that page did load. A page load doesn't mean that this page is displayed right away, use `pageDidAppear` to get informed about the appearance of a page.

     - parameter page: The loaded page
     */
    @objc optional func pageDidLoad(_ page: FolioReaderPage)
    
    /**
     Notifies that page receive tap gesture.
     
     - parameter recognizer: The tap recognizer
     */
    @objc optional func pageTap(_ recognizer: UITapGestureRecognizer)
}

open class FolioReaderPage: UICollectionViewCell, UIGestureRecognizerDelegate {
    weak var delegate: FolioReaderPageDelegate?
    weak var readerContainer: FolioReaderContainer?

    /// The index of the current page. Note: The index start at 1!
    open var pageNumber: Int!
    open var webView: FolioReaderWebView?

    fileprivate var shouldShowBar = true
    fileprivate var menuIsVisible = false

    fileprivate var readerConfig: FolioReaderConfig {
        guard let readerContainer = readerContainer else { return FolioReaderConfig() }
        return readerContainer.readerConfig
    }

    fileprivate var book: FRBook {
        guard let readerContainer = readerContainer else { return FRBook() }
        return readerContainer.book
    }

    fileprivate var folioReader: FolioReader {
        guard let readerContainer = readerContainer else { return FolioReader() }
        return readerContainer.folioReader
    }

    // MARK: - View life cicle

    public override init(frame: CGRect) {
        // Init explicit attributes with a default value. The `setup` function MUST be called to configure the current object with valid attributes.
        readerContainer = FolioReaderContainer(withConfig: FolioReaderConfig(), folioReader: FolioReader(), epubPath: "")
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPageMode), name: NSNotification.Name(rawValue: "needRefreshPageMode"), object: nil)
    }

    public func setup(withReaderContainer readerContainer: FolioReaderContainer) {
        self.readerContainer = readerContainer
        guard let readerContainer = self.readerContainer else { return }

        if webView == nil {
            webView = FolioReaderWebView(frame: webViewFrame(), readerContainer: readerContainer)
            webView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            webView?.scrollView.showsVerticalScrollIndicator = false
            webView?.scrollView.showsHorizontalScrollIndicator = false
            webView?.scrollView.isUserInteractionEnabled = true
            webView?.backgroundColor = .clear
            contentView.addSubview(webView!)
        }
        webView?.navigationDelegate = self
        
        // Remove all gestures before adding new one
        webView?.gestureRecognizers?.forEach({ gesture in
            webView?.removeGestureRecognizer(gesture)
        })
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.delegate = self
        webView?.addGestureRecognizer(tapGestureRecognizer)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }

    deinit {
        webView?.scrollView.delegate = nil
        webView?.navigationDelegate = nil
        NotificationCenter.default.removeObserver(self)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        webView?.setupScrollDirection()
        webView?.frame = webViewFrame()
    }

    func webViewFrame() -> CGRect {
        guard (self.readerConfig.hideBars == false) else {
            return bounds
        }

        let statusbarHeight = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight = self.folioReader.readerCenter?.navigationController?.navigationBar.frame.size.height ?? CGFloat(0)
        let navTotal = self.readerConfig.shouldHideNavigationOnTap ? 0 : statusbarHeight + navBarHeight
        let paddingTop: CGFloat = 20
        let paddingBottom: CGFloat = 30

        return CGRect(
            x: bounds.origin.x,
            y: readerConfig.isDirection(bounds.origin.y + navTotal, bounds.origin.y + navTotal + paddingTop, bounds.origin.y + navTotal),
            width: bounds.width,
            height: readerConfig.isDirection(bounds.height - navTotal, bounds.height - navTotal - paddingTop - paddingBottom, bounds.height - navTotal)
        )
    }

    func loadHTMLString(_ htmlContent: String!, baseURL: URL!) {
        let tempHtmlContent = htmlContentWithInsertHighlights(htmlContent)
        webView?.alpha = 0
        webView?.loadHTMLString(tempHtmlContent, baseURL: baseURL)
    }
    
    func loadFileURL(_ fileURL: URL, allowingReadAccessTo: URL) {
        webView?.alpha = 0
        webView?.loadFileURL(fileURL, allowingReadAccessTo: allowingReadAccessTo)
    }

    // MARK: - Highlights

    fileprivate func htmlContentWithInsertHighlights(_ htmlContent: String) -> String {
        var tempHtmlContent = htmlContent as NSString
        // Restore highlights
        guard let bookId = (self.book.name as NSString?)?.deletingPathExtension else {
            return tempHtmlContent as String
        }
        
        let highlights = Highlight.allByBookId(withConfiguration: self.readerConfig, bookId: bookId, andPage: pageNumber as NSNumber?)
        if (highlights.count > 0) {
            for item in highlights {
                let style = HighlightStyle.classForStyle(item.type)
                
                var tag = ""
                if let _ = item.noteForHighlight {
                    tag = "<highlight id=\"\(item.highlightId!)\" onclick=\"callHighlightWithNoteURL(this);\" class=\"\(style)\">\(item.content!)</highlight>"
                } else {
                    tag = "<highlight id=\"\(item.highlightId!)\" onclick=\"callHighlightURL(this);\" class=\"\(style)\">\(item.content!)</highlight>"
                }
                
                var locator = item.contentPre + item.content
                locator += item.contentPost
                locator = Highlight.removeSentenceSpam(locator) /// Fix for Highlights
                
                let range: NSRange = tempHtmlContent.range(of: locator, options: .literal)
                
                if range.location != NSNotFound {
                    let newRange = NSRange(location: range.location + item.contentPre.count, length: item.content.count)
                    tempHtmlContent = tempHtmlContent.replacingCharacters(in: newRange, with: tag) as NSString
                } else {
                    print("highlight range not found")
                }
            }
        }
        return tempHtmlContent as String
    }

    fileprivate func getEventTouchPoint(fromPositionParameterString positionParameterString: String) -> CGPoint? {
        // Remove the parameter names: "/clientX=188&clientY=292" -> "188&292"
        var positionParameterString = positionParameterString.replacingOccurrences(of: "/clientX=", with: "")
        positionParameterString = positionParameterString.replacingOccurrences(of: "clientY=", with: "")
        // Separate both position values into an array: "188&292" -> [188],[292]
        let positionStringValues = positionParameterString.components(separatedBy: "&")
        // Multiply the raw positions with the screen scale and return them as CGPoint
        if
            positionStringValues.count == 2,
            let xPos = Int(positionStringValues[0]),
            let yPos = Int(positionStringValues[1]) {
            return CGPoint(x: xPos, y: yPos)
        }
        return nil
    }

    // MARK: Gesture recognizer

    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer.view is FolioReaderWebView {
            if otherGestureRecognizer is UILongPressGestureRecognizer {
                if UIMenuController.shared.isMenuVisible {
                    webView?.setMenuVisible(false)
                }
                return false
                
            }
            return true
            
        }
        return false
    }
    
    @objc open func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        delegate?.pageTap?(recognizer)
        
        if let _navigationController = folioReader.readerCenter?.navigationController, (_navigationController.isNavigationBarHidden == true) {
            let script = "getSelectedText()"
            webView?.js(script, completion: { [weak self] value in
                guard let weakSelf = self, (value == nil || (value as? String)?.isEmpty == true) else { return }
                let dispatchTime = (DispatchTime.now() + .milliseconds(400))
                DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: { [weak self] in
                    guard let weakSelf = self else { return }
                    if (weakSelf.shouldShowBar == true && weakSelf.menuIsVisible == false) {
                        weakSelf.folioReader.readerCenter?.toggleBars()
                    }
                })
            })
        } else if (self.readerConfig.shouldHideNavigationOnTap == true) {
            folioReader.readerCenter?.hideBars()
            menuIsVisible = false
        }
    }

    // MARK: - Public scroll postion setter

    /**
     Scrolls the page to a given offset

     - parameter offset:   The offset to scroll
     - parameter animated: Enable or not scrolling animation
     */
    open func scrollPageToOffset(_ offset: CGFloat, animated: Bool) {
        let pageOffsetPoint = self.readerConfig.isDirection(CGPoint(x: 0, y: offset), CGPoint(x: offset, y: 0), CGPoint(x: 0, y: offset))
        webView?.scrollView.setContentOffset(pageOffsetPoint, animated: animated)
    }

    /**
     Scrolls the page to bottom
     */
    open func scrollPageToBottom() {
        guard let webView = webView else { return }
        let bottomOffset = self.readerConfig.isDirection(
            CGPoint(x: 0, y: webView.scrollView.contentSize.height - webView.scrollView.bounds.height),
            CGPoint(x: webView.scrollView.contentSize.width - webView.scrollView.bounds.width, y: 0),
            CGPoint(x: webView.scrollView.contentSize.width - webView.scrollView.bounds.width, y: 0)
        )

        if bottomOffset.forDirection(withConfiguration: self.readerConfig) >= 0 {
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.webView?.scrollView.setContentOffset(bottomOffset, animated: false)
            }
        }
    }

    /**
     Handdle #anchors in html, get the offset and scroll to it

     - parameter anchor:                The #anchor
     - parameter avoidBeginningAnchors: Sometimes the anchor is on the beggining of the text, there is not need to scroll
     - parameter animated:              Enable or not scrolling animation
     */
    open func handleAnchor(_ anchor: String,  avoidBeginningAnchors: Bool, animated: Bool) {
        if !anchor.isEmpty {
            
            getAnchorOffset(anchor, completion: { [weak self] offset in
                guard let weakSelf = self else { return }
                switch weakSelf.readerConfig.scrollDirection {
                case .vertical, .defaultVertical:
                    let isBeginning = (offset < weakSelf.frame.forDirection(withConfiguration: weakSelf.readerConfig) * 0.5)

                    if !avoidBeginningAnchors {
                        weakSelf.scrollPageToOffset(offset, animated: animated)
                    } else if avoidBeginningAnchors && !isBeginning {
                        weakSelf.scrollPageToOffset(offset, animated: animated)
                    }
                case .horizontal, .horizontalWithVerticalContent:
                    weakSelf.scrollPageToOffset(offset, animated: animated)
                }
            })
        }
    }

    // MARK: Helper

    /**
     Get the #anchor offset in the page

     - parameter anchor: The #anchor id
     - returns: The element offset ready to scroll
     */
    func getAnchorOffset(_ anchor: String, completion: @escaping((_ value:CGFloat) -> Void)) {
        let horizontal = readerConfig.scrollDirection == .horizontal
        guard let webView = webView else {
            completion(0)
            return
        }
        
        let script = "getAnchorOffset('\(anchor)', \(horizontal.description))"
        webView.js(script, completion: { value in
            guard let offset = value as? CGFloat else {
                completion(0)
                return
            }
            completion(offset)
        })
    }

    // MARK: Mark ID

    /**
     Audio Mark ID - marks an element with an ID with the given class and scrolls to it

     - parameter identifier: The identifier
     */
    func audioMarkID(_ identifier: String) {
        guard let currentPage = self.folioReader.readerCenter?.currentPage else {
            return
        }

        let playbackActiveClass = self.book.playbackActiveClass
        let script = "audioMarkID('\(playbackActiveClass)','\(identifier)')"
        currentPage.webView?.js(script, completion: { _ in })
    }

    // MARK: UIMenu visibility

    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        guard let webView = webView else { return false }

        if UIMenuController.shared.menuItems?.count == 0 {
            webView.isColors = false
            webView.createMenu(options: false)
        }

        if !webView.isShare && !webView.isColors {
            let script = "getSelectedText()"
            webView.js(script, completion: { [weak self] value in
                guard let weakSelf = self, let stringValue = value as? String else { return }
                if stringValue.components(separatedBy: " ").count == 1 {
                    webView.isOneWord = true
                    webView.createMenu(options: false)
                } else {
                    webView.isOneWord = false
                }
            })
        }
        
        return super.canPerformAction(action, withSender: sender)
    }

    // MARK: ColorView fix for horizontal layout
    @objc func refreshPageMode() {
        guard let webView = webView else { return }
        
        let darkModeScript = "nightMode(\(folioReader.nightMode))"
        webView.js(darkModeScript, completion: { _ in })
        
        let fontTypeScript = "setFontName('\(folioReader.currentFont.cssIdentifier)')"
        webView.js(fontTypeScript, completion: { _ in })
        
        let fontSizeScript = "setFontSize('\(folioReader.currentFontSize.cssIdentifier)')"
        webView.js(fontSizeScript, completion: { _ in })
    }
    
    // MARK: - Class based click listener
    fileprivate func setupClassBasedOnClickListeners() {
        for listener in self.readerConfig.classBasedOnClickListeners {
            let script = "addClassBasedOnClickListener(\"\(listener.schemeName)\", \"\(listener.querySelector)\", \"\(listener.attributeName)\", \"\(listener.selectAll)\")"
            webView?.js(script, completion: { _ in })
        }
    }
}

// MARK: - WKNavigationDelegate
extension FolioReaderPage: WKNavigationDelegate {
    
    // MARK: - UKWebView Delegate
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let webView = webView as? FolioReaderWebView else { return }
        delegate?.pageWillLoad?(self)

        // Add the custom class based onClick listener
        setupClassBasedOnClickListeners()
        refreshPageMode()

        if self.readerConfig.enableTTS && !self.book.hasAudio {
            webView.js("wrappingSentencesWithinPTags()", completion: { _ in })
            if let audioPlayer = folioReader.readerAudioPlayer, (audioPlayer.isPlaying() == true) {
                audioPlayer.readCurrentSentence()
            }
        }
        
        let direction: ScrollDirection = folioReader.needsRTLChange ? .positive(withConfiguration: readerConfig) : .negative(withConfiguration: readerConfig)
        if (folioReader.readerCenter?.pageScrollDirection == direction &&
            folioReader.readerCenter?.isScrolling == true &&
            readerConfig.scrollDirection != .horizontalWithVerticalContent) {
            scrollPageToBottom()
        }

        UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveLinear, animations: {
            webView.alpha = 1
        }, completion: { [weak self] finished in
            guard finished else { return }
            webView.isColors = false
            self?.webView?.createMenu(options: false)
        })
        
        delegate?.pageDidLoad?(self)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let webView = webView as? FolioReaderWebView,
            let url = navigationAction.request.url,
            let scheme = navigationAction.request.url?.scheme else {
                decisionHandler(.allow)
                return
        }
        
        
        if scheme == "highlight" || scheme == "highlight-with-note" {
            
            if let decoded = url.absoluteString.removingPercentEncoding {
                let index = decoded.index(decoded.startIndex, offsetBy: 12)
                let rect = NSCoder.cgRect(for: String(decoded[index...]))
                webView.createMenu(options: true)
                webView.setMenuVisible(true, andRect: rect)
                menuIsVisible = true
            }
            
            shouldShowBar = false
            decisionHandler(.cancel)
            return
        }
        
        if scheme == "play-audio" {
            
            if let decoded = url.absoluteString.removingPercentEncoding {
                let index = decoded.index(decoded.startIndex, offsetBy: 13)
                let playID = String(decoded[index...])
                let chapter = self.folioReader.readerCenter?.getCurrentChapter()
                let href = chapter?.href ?? ""
                folioReader.readerAudioPlayer?.playAudio(href, fragmentID: playID)
                decisionHandler(.cancel)
            }
            
            decisionHandler(.cancel)
            return
        }
        
        if scheme == "file" {
            decisionHandler(.allow)
            return
        }
        
        if scheme == "mailto" {
            decisionHandler(.allow)
            return
        }
        
        if url.absoluteString != "about:blank" && scheme.contains("http") && navigationAction.navigationType == .linkActivated {
            let safariVC = SFSafariViewController(url: url)
            safariVC.view.tintColor = readerConfig.tintColor
            folioReader.readerCenter?.present(safariVC, animated: true, completion: nil)
            decisionHandler(.cancel)
            return
        } else {
            // Check if the url is a custom class based onClick listerner
            var isClassBasedOnClickListenerScheme = false
            for listener in readerConfig.classBasedOnClickListeners {
                let absoluteURLString = url.absoluteString
                if scheme == listener.schemeName,
                    let range = absoluteURLString.range(of: "/clientX=") {
                    let baseURL = String(absoluteURLString[..<range.lowerBound])
                    let positionString = String(absoluteURLString[range.lowerBound...])
                    if let point = getEventTouchPoint(fromPositionParameterString: positionString) {
                        let attributeContentString = (baseURL.replacingOccurrences(of: "\(scheme)://", with: "").removingPercentEncoding)
                        listener.onClickAction(attributeContentString, point)
                        isClassBasedOnClickListenerScheme = true
                    }
                }
            }

            if isClassBasedOnClickListenerScheme == false {
                // Try to open the url with the system if it wasn't a custom class based click listener
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.openURL(url)
                    decisionHandler(.cancel)
                    return
                }
            } else {
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
}
