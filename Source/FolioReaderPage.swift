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

/// Protocol which is used from `FolioReaderPage`s.
public protocol FolioReaderPageDelegate: class {
    /**
     Notify that page did loaded
     
     - parameter page: The loaded page
     */
    func pageDidLoad(page: FolioReaderPage)
}

public class FolioReaderPage: UICollectionViewCell, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    weak var delegate: FolioReaderPageDelegate?
	/// The index of the current page. Note: The index start at 1!
	public var pageNumber: Int!
	var webView: UIWebView!
    private var colorView: UIView!
    private var shouldShowBar = true
    private var menuIsVisible = false
    
    // MARK: - View life cicle
    
    override public init(frame: CGRect) {
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

    required public init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        webView.setupScrollDirection()
        webView.frame = webViewFrame()
    }
    
    func webViewFrame() -> CGRect {
		guard readerConfig.hideBars == false else {
            return bounds
        }

        let statusbarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        let navBarHeight = FolioReader.sharedInstance.readerCenter?.navigationController?.navigationBar.frame.size.height ?? CGFloat(0)
        let navTotal = readerConfig.shouldHideNavigationOnTap ? 0 : statusbarHeight + navBarHeight
		let paddingTop: CGFloat = 20
        let paddingBottom: CGFloat = 30

        return CGRect(
            x: bounds.origin.x,
            y: isDirection(bounds.origin.y + navTotal, bounds.origin.y + navTotal + paddingTop),
            width: bounds.width,
            height: isDirection(bounds.height - navTotal, bounds.height - navTotal - paddingTop - paddingBottom)
        )
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
    
    public func webViewDidFinishLoad(webView: UIWebView) {

		// Add the custom class based onClick listener
		self.setupClassBasedOnClickListeners()

        refreshPageMode()
        
        if readerConfig.enableTTS && !book.hasAudio() {
            webView.js("wrappingSentencesWithinPTags()")
            
            if let audioPlayer = FolioReader.sharedInstance.readerAudioPlayer where audioPlayer.isPlaying() {
                audioPlayer.readCurrentSentence()
            }
        }
        
        let direction: ScrollDirection = FolioReader.needsRTLChange ? .positive() : .negative()
        
        if pageScrollDirection == direction && isScrolling && readerConfig.scrollDirection != .horizontalWithVerticalContent {
            scrollPageToBottom()
        }
        
        UIView.animateWithDuration(0.2, animations: {webView.alpha = 1}) { finished in
            webView.isColors = false
            self.webView.createMenu(options: false)
        }

        delegate?.pageDidLoad(self)
    }
    
    public func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        guard let url = request.URL else { return false }
        
        if url.scheme == "highlight" {
            
            shouldShowBar = false
            
            let decoded = url.absoluteString.stringByRemovingPercentEncoding as String!
            let rect = CGRectFromString(decoded.substringFromIndex(decoded.startIndex.advancedBy(12)))
            
            webView.createMenu(options: true)
            webView.setMenuVisible(true, andRect: rect)
            menuIsVisible = true
            
            return false
        } else if url.scheme == "play-audio" {

            let decoded = url.absoluteString.stringByRemovingPercentEncoding as String!
            let playID = decoded.substringFromIndex(decoded.startIndex.advancedBy(13))
            let chapter = FolioReader.sharedInstance.readerCenter?.getCurrentChapter()
            let href = chapter != nil ? chapter!.href : "";
            FolioReader.sharedInstance.readerAudioPlayer?.playAudio(href, fragmentID: playID)

            return false
        } else if url.scheme == "file" {
            
            let anchorFromURL = url.fragment
            
            // Handle internal url
            if (url.path! as NSString).pathExtension != "" {
                let base = (book.opfResource.href as NSString).stringByDeletingLastPathComponent
                let path = url.path
                let splitedPath = path!.componentsSeparatedByString(base.isEmpty ? kBookId : base)
                
                // Return to avoid crash
                if splitedPath.count <= 1 || splitedPath[1].isEmpty {
                    return true
                }
                
                let href = splitedPath[1].stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "/"))
                let hrefPage = (FolioReader.sharedInstance.readerCenter?.findPageByHref(href) ?? 0) + 1
                
                if hrefPage == pageNumber {
                    // Handle internal #anchor
                    if anchorFromURL != nil {
                        handleAnchor(anchorFromURL!, avoidBeginningAnchors: false, animated: true)
                        return false
                    }
                } else {
                    FolioReader.sharedInstance.readerCenter?.changePageWith(href: href, animated: true)
                }
                
                return false
            }
            
            // Handle internal #anchor
            if anchorFromURL != nil {
                handleAnchor(anchorFromURL!, avoidBeginningAnchors: false, animated: true)
                return false
            }
            
            return true
        } else if url.scheme == "mailto" {
            print("Email")
            return true
        } else if url.absoluteString != "about:blank" && url.scheme.containsString("http") && navigationType == .LinkClicked {
            
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(URL: request.URL!)
                safariVC.view.tintColor = readerConfig.tintColor
                FolioReader.sharedInstance.readerCenter?.presentViewController(safariVC, animated: true, completion: nil)
            } else {
                let webViewController = WebViewController(url: request.URL!)
                let nav = UINavigationController(rootViewController: webViewController)
                nav.view.tintColor = readerConfig.tintColor
                FolioReader.sharedInstance.readerCenter?.presentViewController(nav, animated: true, completion: nil)
            }
            return false
		} else {
			// Check if the url is a custom class based onClick listerner
			var isClassBasedOnClickListenerScheme = false
			for listener in readerConfig.classBasedOnClickListeners {
				if
					url.scheme == listener.schemeName,
					let absoluteURLString = request.URL?.absoluteString,
					range = absoluteURLString.rangeOfString("/clientX=") {
						let baseURL = absoluteURLString.substringToIndex(range.startIndex)
						let positionString = absoluteURLString.substringFromIndex(range.startIndex)
						if let point = getEventTouchPoint(fromPositionParameterString: positionString) {
							let attributeContentString = (baseURL.stringByReplacingOccurrencesOfString("\(url.scheme)://", withString: "").stringByRemovingPercentEncoding)
							// Call the on click action block
							listener.onClickAction(attributeContent: attributeContentString, touchPointRelativeToWebView: point)
							// Mark the scheme as class based click listener scheme
							isClassBasedOnClickListenerScheme = true
						}
				}
			}

			if isClassBasedOnClickListenerScheme == false {
				// Try to open the url with the system if it wasn't a custom class based click listener
				if UIApplication.sharedApplication().canOpenURL(url) {
					UIApplication.sharedApplication().openURL(url)
					return false
				}
			} else {
				return false
			}
		}

        return true
    }

	private func getEventTouchPoint(fromPositionParameterString positionParameterString: String) -> CGPoint? {
		// Remove the parameter names: "/clientX=188&clientY=292" -> "188&292"
		var positionParameterString = positionParameterString.stringByReplacingOccurrencesOfString("/clientX=", withString: "")
		positionParameterString = positionParameterString.stringByReplacingOccurrencesOfString("clientY=", withString: "")
		// Separate both position values into an array: "188&292" -> [188],[292]
		let positionStringValues = positionParameterString.componentsSeparatedByString("&")
		// Multiply the raw positions with the screen scale and return them as CGPoint
		if
			positionStringValues.count == 2,
			let xPos = Int(positionStringValues[0]),
			yPos = Int(positionStringValues[1]) {
				return CGPoint(x: xPos, y: yPos)
		}
		return nil
	}
    
    // MARK: Gesture recognizer
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
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
    
    public func handleTapGesture(recognizer: UITapGestureRecognizer) {
//        webView.setMenuVisible(false)
        
		if	let _navigationController = FolioReader.sharedInstance.readerCenter?.navigationController where _navigationController.navigationBarHidden {
            let menuIsVisibleRef = menuIsVisible
            
            let selected = webView.js("getSelectedText()")

            if selected == nil || selected!.characters.count == 0 {
                let seconds = 0.4
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))

                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    
                    if self.shouldShowBar && !menuIsVisibleRef {
                        FolioReader.sharedInstance.readerCenter?.toggleBars()
                    }
                    self.shouldShowBar = true
                })
            }
        } else if readerConfig.shouldHideNavigationOnTap == true {
            FolioReader.sharedInstance.readerCenter?.hideBars()
        }
        
        // Reset menu
        menuIsVisible = false
    }

	// MARK: - Public scroll postion setter

	/**
	Scrolls the page to a given offset

	- parameter offset:   The offset to scroll
	- parameter animated: Enable or not scrolling animation
	*/
	public func scrollPageToOffset(offset: CGFloat, animated: Bool) {
        let pageOffsetPoint = isDirection(CGPoint(x: 0, y: offset), CGPoint(x: offset, y: 0))
		webView.scrollView.setContentOffset(pageOffsetPoint, animated: animated)
	}

	/**
	Scrolls the page to bottom
	*/
	public func scrollPageToBottom() {
		let bottomOffset = isDirection(
			CGPointMake(0, webView.scrollView.contentSize.height - webView.scrollView.bounds.height),
			CGPointMake(webView.scrollView.contentSize.width - webView.scrollView.bounds.width, 0),
			CGPointMake(webView.scrollView.contentSize.width - webView.scrollView.bounds.width, 0)
		)

		if bottomOffset.forDirection() >= 0 {
			dispatch_async(dispatch_get_main_queue(), {
				self.webView.scrollView.setContentOffset(bottomOffset, animated: false)
			})
		}
	}

	/**
	Handdle #anchors in html, get the offset and scroll to it

	- parameter anchor:                The #anchor
	- parameter avoidBeginningAnchors: Sometimes the anchor is on the beggining of the text, there is not need to scroll
	- parameter animated:              Enable or not scrolling animation
	*/
	public func handleAnchor(anchor: String,  avoidBeginningAnchors: Bool, animated: Bool) {
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

	// MARK: Helper

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
        guard let currentPage = FolioReader.sharedInstance.readerCenter?.currentPage else { return }
        currentPage.webView.js("audioMarkID('\(book.playbackActiveClass())','\(ID)')")
    }
    
    // MARK: UIMenu visibility
    
    override public func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if UIMenuController.sharedMenuController().menuItems?.count == 0 {
            webView.isColors = false
            webView.createMenu(options: false)
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    // MARK: ColorView fix for horizontal layout
    func refreshPageMode() {
        if FolioReader.nightMode {
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

	// MARK: - Class based click listener

	private func setupClassBasedOnClickListeners() {

		for listener in readerConfig.classBasedOnClickListeners {
			self.webView.js("addClassBasedOnClickListener(\"\(listener.schemeName)\", \"\(listener.querySelector)\", \"\(listener.attributeName)\", \"\(listener.selectAll)\")");
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
        
        if(readerConfig == nil){
            return super.canPerformAction(action, withSender: sender)
        }

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
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let shareImage = UIAlertAction(title: readerConfig.localizedShareImageQuote, style: .Default, handler: { (action) -> Void in
            if self.isShare {
                if let textToShare = self.js("getHighlightContent()") {
                    FolioReader.sharedInstance.readerCenter?.presentQuoteShare(textToShare)
                }
            } else {
                if let textToShare = self.js("getSelectedText()") {
                    FolioReader.sharedInstance.readerCenter?.presentQuoteShare(textToShare)
                    self.userInteractionEnabled = false
                    self.userInteractionEnabled = true
                }
            }
            self.setMenuVisible(false)
        })
        
        let shareText = UIAlertAction(title: readerConfig.localizedShareTextQuote, style: .Default) { (action) -> Void in
            if self.isShare {
                if let textToShare = self.js("getHighlightContent()") {
                    FolioReader.sharedInstance.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
                }
            } else {
                if let textToShare = self.js("getSelectedText()") {
                    FolioReader.sharedInstance.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
                }
            }
            self.setMenuVisible(false)
        }
        
        let cancel = UIAlertAction(title: readerConfig.localizedCancel, style: .Cancel, handler: nil)
        
        alertController.addAction(shareImage)
        alertController.addAction(shareText)
        alertController.addAction(cancel)
        
        FolioReader.sharedInstance.readerCenter?.presentViewController(alertController, animated: true, completion: nil)
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
        let highlightAndReturn = js("highlightString('\(HighlightStyle.classForStyle(FolioReader.currentHighlightStyle))')")
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
        FolioReader.sharedInstance.readerAudioPlayer?.play()

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
        FolioReader.currentHighlightStyle = style.rawValue

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
    
    // MARK: WebView direction config
    
    func setupScrollDirection() {
        switch readerConfig.scrollDirection {
        case .vertical, .horizontalWithVerticalContent:
            scrollView.pagingEnabled = false
            paginationMode = .Unpaginated
            scrollView.bounces = true
            break
        case .horizontal:
            scrollView.pagingEnabled = true
            paginationMode = .LeftToRight
            paginationBreakingMode = .Page
            scrollView.bounces = false
            break
        }
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
