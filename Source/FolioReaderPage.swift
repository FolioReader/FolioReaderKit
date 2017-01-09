//
//  FolioReaderPage.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 10/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import SafariServices
import MenuItemKit
import JSQWebViewController

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
}

open class FolioReaderPage: UICollectionViewCell, UIWebViewDelegate, UIGestureRecognizerDelegate {
    
    weak var delegate: FolioReaderPageDelegate?
	/// The index of the current page. Note: The index start at 1!
	open var pageNumber: Int!
	var webView: FolioReaderWebView!
    fileprivate var colorView: UIView!
    fileprivate var shouldShowBar = true
    fileprivate var menuIsVisible = false
    
    // MARK: - View life cicle
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        
        // TODO: Put the notification name in a Constants file
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPageMode), name: NSNotification.Name(rawValue: "needRefreshPageMode"), object: nil)
        
        if webView == nil {
            webView = FolioReaderWebView(frame: webViewFrame())
            webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            webView.dataDetectorTypes = .link
            webView.scrollView.showsVerticalScrollIndicator = false
            webView.scrollView.showsHorizontalScrollIndicator = false
            webView.backgroundColor = UIColor.clear
            
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
        webView.scrollView.delegate = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        webView.setupScrollDirection()
        webView.frame = webViewFrame()
    }
    
    func webViewFrame() -> CGRect {
		guard readerConfig.hideBars == false else {
            return bounds
        }

        let statusbarHeight = UIApplication.shared.statusBarFrame.size.height
        let navBarHeight = FolioReader.shared.readerCenter?.navigationController?.navigationBar.frame.size.height ?? CGFloat(0)
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
    
    func loadHTMLString(_ htmlContent: String!, baseURL: URL!) {
		// Insert the stored highlights to the HTML
		let tempHtmlContent = htmlContentWithInsertHighlights(htmlContent)
        // Load the html into the webview
        webView.alpha = 0
        webView.loadHTMLString(tempHtmlContent, baseURL: baseURL)
    }

	// MARK: - Highlights

	fileprivate func htmlContentWithInsertHighlights(_ htmlContent: String) -> String {
		var tempHtmlContent = htmlContent as NSString
		// Restore highlights
		let highlights = Highlight.allByBookId((kBookId as NSString).deletingPathExtension, andPage: pageNumber as NSNumber?)

		if highlights.count > 0 {
			for item in highlights {
				let style = HighlightStyle.classForStyle(item.type)
				let tag = "<highlight id=\"\(item.highlightId!)\" onclick=\"callHighlightURL(this);\" class=\"\(style)\">\(item.content!)</highlight>"
				var locator = item.contentPre + item.content
                locator += item.contentPost
				locator = Highlight.removeSentenceSpam(locator) /// Fix for Highlights
				let range: NSRange = tempHtmlContent.range(of: locator, options: .literal)

				if range.location != NSNotFound {
					let newRange = NSRange(location: range.location + item.contentPre.characters.count, length: item.content.characters.count)
					tempHtmlContent = tempHtmlContent.replacingCharacters(in: newRange, with: tag) as NSString
				}
				else {
					print("highlight range not found")
				}
			}
		}
		return tempHtmlContent as String
	}

    // MARK: - UIWebView Delegate
    
    open func webViewDidFinishLoad(_ webView: UIWebView) {
		guard let webView = webView as? FolioReaderWebView else {
			return
		}

		delegate?.pageWillLoad?(self)

		// Add the custom class based onClick listener
		self.setupClassBasedOnClickListeners()

        refreshPageMode()
        
        if readerConfig.enableTTS && !book.hasAudio() {
            webView.js("wrappingSentencesWithinPTags()")
            
            if let audioPlayer = FolioReader.shared.readerAudioPlayer , audioPlayer.isPlaying() {
                audioPlayer.readCurrentSentence()
            }
        }
        
        let direction: ScrollDirection = FolioReader.needsRTLChange ? .positive() : .negative()
        
        if pageScrollDirection == direction && isScrolling && readerConfig.scrollDirection != .horizontalWithVerticalContent {
            scrollPageToBottom()
        }
        
        UIView.animate(withDuration: 0.2, animations: {webView.alpha = 1}, completion: { finished in
            webView.isColors = false
            self.webView.createMenu(options: false)
        }) 

        delegate?.pageDidLoad?(self)
    }
    
    open func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		guard let webView = webView as? FolioReaderWebView else {
			return true
		}

        guard let url = request.url else { return false }
        
        if url.scheme == "highlight" {
            
            shouldShowBar = false
            
            guard let decoded = url.absoluteString.removingPercentEncoding else { return false }
            let rect = CGRectFromString(decoded.substring(from: decoded.index(decoded.startIndex, offsetBy: 12)))
            
            webView.createMenu(options: true)
            webView.setMenuVisible(true, andRect: rect)
            menuIsVisible = true
            
            return false
        } else if url.scheme == "play-audio" {

            guard let decoded = url.absoluteString.removingPercentEncoding else { return false }
            let playID = decoded.substring(from: decoded.index(decoded.startIndex, offsetBy: 13))
            let chapter = FolioReader.shared.readerCenter?.getCurrentChapter()
            let href = chapter?.href ?? ""
            FolioReader.shared.readerAudioPlayer?.playAudio(href, fragmentID: playID)

            return false
        } else if url.scheme == "file" {
            
            let anchorFromURL = url.fragment
            
            // Handle internal url
            if (url.path as NSString).pathExtension != "" {
                let base = (book.opfResource.href as NSString).deletingLastPathComponent
                let path = url.path
                let splitedPath = path.components(separatedBy: base.isEmpty ? kBookId : base)
                
                // Return to avoid crash
                if splitedPath.count <= 1 || splitedPath[1].isEmpty {
                    return true
                }
                
                let href = splitedPath[1].trimmingCharacters(in: CharacterSet(charactersIn: "/"))
                let hrefPage = (FolioReader.shared.readerCenter?.findPageByHref(href) ?? 0) + 1
                
                if hrefPage == pageNumber {
                    // Handle internal #anchor
                    if anchorFromURL != nil {
                        handleAnchor(anchorFromURL!, avoidBeginningAnchors: false, animated: true)
                        return false
                    }
                } else {
                    FolioReader.shared.readerCenter?.changePageWith(href: href, animated: true)
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
        } else if url.absoluteString != "about:blank" && url.scheme!.contains("http") && navigationType == .linkClicked {
            
            if #available(iOS 9.0, *) {
                let safariVC = SFSafariViewController(url: request.url!)
                safariVC.view.tintColor = readerConfig.tintColor
                FolioReader.shared.readerCenter?.present(safariVC, animated: true, completion: nil)
            } else {
                let webViewController = WebViewController(url: request.url!)
                let nav = UINavigationController(rootViewController: webViewController)
                nav.view.tintColor = readerConfig.tintColor
                FolioReader.shared.readerCenter?.present(nav, animated: true, completion: nil)
            }
            return false
		} else {
			// Check if the url is a custom class based onClick listerner
			var isClassBasedOnClickListenerScheme = false
			for listener in readerConfig.classBasedOnClickListeners {

				if url.scheme == listener.schemeName,
                    let absoluteURLString = request.url?.absoluteString,
                    let range = absoluteURLString.range(of: "/clientX=") {
                    let baseURL = absoluteURLString.substring(to: range.lowerBound)
                    let positionString = absoluteURLString.substring(from: range.lowerBound)
                    if let point = getEventTouchPoint(fromPositionParameterString: positionString) {
                        let attributeContentString = (baseURL.replacingOccurrences(of: "\(url.scheme)://", with: "").removingPercentEncoding)
                        // Call the on click action block
                        listener.onClickAction(attributeContentString, point)
                        // Mark the scheme as class based click listener scheme
                        isClassBasedOnClickListenerScheme = true
                    }
				}
			}

			if isClassBasedOnClickListenerScheme == false {
				// Try to open the url with the system if it wasn't a custom class based click listener
				if UIApplication.shared.canOpenURL(url) {
					UIApplication.shared.openURL(url)
					return false
				}
			} else {
				return false
			}
		}

        return true
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
                    webView.setMenuVisible(false)
                }
                return false
            }
            return true
        }
        return false
    }
    
    open func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
//        webView.setMenuVisible(false)
        
		if	let _navigationController = FolioReader.shared.readerCenter?.navigationController , _navigationController.isNavigationBarHidden {
            let menuIsVisibleRef = menuIsVisible
            
            let selected = webView.js("getSelectedText()")

            if selected == nil || selected!.characters.count == 0 {
                let seconds = 0.4
                let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)

                DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                    
                    if self.shouldShowBar && !menuIsVisibleRef {
                        FolioReader.shared.readerCenter?.toggleBars()
                    }
                    self.shouldShowBar = true
                })
            }
        } else if readerConfig.shouldHideNavigationOnTap == true {
            FolioReader.shared.readerCenter?.hideBars()
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
	open func scrollPageToOffset(_ offset: CGFloat, animated: Bool) {
        let pageOffsetPoint = isDirection(CGPoint(x: 0, y: offset), CGPoint(x: offset, y: 0))
		webView.scrollView.setContentOffset(pageOffsetPoint, animated: animated)
	}

	/**
	Scrolls the page to bottom
	*/
	open func scrollPageToBottom() {
		let bottomOffset = isDirection(
			CGPoint(x: 0, y: webView.scrollView.contentSize.height - webView.scrollView.bounds.height),
			CGPoint(x: webView.scrollView.contentSize.width - webView.scrollView.bounds.width, y: 0),
			CGPoint(x: webView.scrollView.contentSize.width - webView.scrollView.bounds.width, y: 0)
		)

		if bottomOffset.forDirection() >= 0 {
			DispatchQueue.main.async(execute: {
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
	open func handleAnchor(_ anchor: String,  avoidBeginningAnchors: Bool, animated: Bool) {
		if !anchor.isEmpty {
			let offset = getAnchorOffset(anchor)

			switch readerConfig.scrollDirection {
            case .vertical, .defaultVertical:
				let isBeginning = offset < frame.forDirection()/2

				if !avoidBeginningAnchors {
					scrollPageToOffset(offset, animated: animated)
				} else if avoidBeginningAnchors && !isBeginning {
					scrollPageToOffset(offset, animated: animated)
				}
            case .horizontal, .horizontalWithVerticalContent:
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
	func getAnchorOffset(_ anchor: String) -> CGFloat {
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
    func audioMarkID(_ ID: String) {
        guard let currentPage = FolioReader.shared.readerCenter?.currentPage else { return }
        currentPage.webView.js("audioMarkID('\(book.playbackActiveClass())','\(ID)')")
    }
    
    // MARK: UIMenu visibility
    
    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		if UIMenuController.shared.menuItems?.count == 0 {
            webView.isColors = false
            webView.createMenu(options: false)
        }
        
        if !webView.isShare && !webView.isColors {
            if let result = webView.js("getSelectedText()") , result.components(separatedBy: " ").count == 1 {
                webView.isOneWord = true
                webView.createMenu(options: false)
            } else {
                webView.isOneWord = false
            }
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    // MARK: ColorView fix for horizontal layout
    func refreshPageMode() {
        if FolioReader.nightMode {
            // omit create webView and colorView
            let script = "document.documentElement.offsetHeight"
            let contentHeight = webView.stringByEvaluatingJavaScript(from: script)
            let frameHeight = webView.frame.height
            let lastPageHeight = frameHeight * CGFloat(webView.pageCount) - CGFloat(Double(contentHeight!)!)
            colorView.frame = CGRect(x: webView.frame.width * CGFloat(webView.pageCount-1), y: webView.frame.height - lastPageHeight, width: webView.frame.width, height: lastPageHeight)
        } else {
            colorView.frame = CGRect.zero
        }
    }

	// MARK: - Class based click listener

	fileprivate func setupClassBasedOnClickListeners() {

		for listener in readerConfig.classBasedOnClickListeners {
			self.webView.js("addClassBasedOnClickListener(\"\(listener.schemeName)\", \"\(listener.querySelector)\", \"\(listener.attributeName)\", \"\(listener.selectAll)\")");
		}
	}

	// MARK: - Public Java Script injection

	/** 
	Runs a JavaScript script and returns it result. The result of running the JavaScript script passed in the script parameter, or nil if the script fails.

	- returns: The result of running the JavaScript script passed in the script parameter, or nil if the script fails.
	*/
	open func performJavaScript(_ javaScriptCode: String) -> String? {
		return webView.js(javaScriptCode)
	}
}
