//
//  FolioReaderCenter.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import ZFDragableModalTransition
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


let reuseIdentifier = "Cell"
var pageWidth: CGFloat!
var pageHeight: CGFloat!
var previousPageNumber: Int!
var currentPageNumber: Int!
var nextPageNumber: Int!
var pageScrollDirection = ScrollDirection()
var isScrolling = false

/// Protocol which is used from `FolioReaderCenter`s.
@objc public protocol FolioReaderCenterDelegate: class {

	/**
	Notifies that a page appeared. This is triggered is a page is chosen and displayed.

	- parameter page: The appeared page
	*/
	@objc optional func pageDidAppear(_ page: FolioReaderPage)

	/**
	Passes and returns the HTML content as `String`. Implement this method if you want to modify the HTML content of a `FolioReaderPage`.

	- parameter page: The `FolioReaderPage`
	- parameter htmlContent: The current HTML content as `String`

	- returns: The adjusted HTML content as `String`. This is the content which will be loaded into the given `FolioReaderPage`
	*/
	@objc optional func htmlContentForPage(_ page: FolioReaderPage, htmlContent: String) -> String
}

open class FolioReaderCenter: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

	/// This delegate receives the events from the current `FolioReaderPage`s delegate.
	open weak var delegate: FolioReaderCenterDelegate?
	open weak var pageDelegate: FolioReaderPageDelegate?

    var collectionView: UICollectionView!
    let collectionViewLayout = UICollectionViewFlowLayout()
    var loadingView: UIActivityIndicatorView!
    var pages: [String]!
    var totalPages: Int!
    var tempFragment: String?
	open fileprivate(set) var currentPage: FolioReaderPage?
    var animator: ZFModalTransitionAnimator!
    var pageIndicatorView: FolioReaderPageIndicator?
	var pageIndicatorHeight: CGFloat = 20

    var recentlyScrolled = false
    var recentlyScrolledDelay = 2.0 // 2 second delay until we clear recentlyScrolled
    var recentlyScrolledTimer: Timer!
    var scrollScrubber: ScrollScrubber?
    
    fileprivate var screenBounds: CGRect!
    fileprivate var pointNow = CGPoint.zero
    fileprivate var pageOffsetRate: CGFloat = 0
    fileprivate var tempReference: FRTocReference?
    fileprivate var isFirstLoad = true
	fileprivate var currentWebViewScrollPositions = [Int: CGPoint]()
	fileprivate var currentOrientation: UIInterfaceOrientation?
    
    // MARK: - Init
    
    init() {
        super.init(nibName: nil, bundle: Bundle.frameworkBundle())
        initialization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialization()
    }
    
    /**
     Common Initialization
     */
    fileprivate func initialization() {
        
        if (readerConfig.hideBars == true) {
            self.pageIndicatorHeight = 0
        }
        
        totalPages = book.spine.spineReferences.count
        
        // Loading indicator
        let style: UIActivityIndicatorViewStyle = isNight(.white, .gray)
        loadingView = UIActivityIndicatorView(activityIndicatorStyle: style)
        loadingView.hidesWhenStopped = true
        loadingView.startAnimating()
        view.addSubview(loadingView)
    }
    
    // MARK: - View life cicle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        screenBounds = self.view.frame
        setPageSize(UIApplication.shared.statusBarOrientation)
        
        // Layout
        collectionViewLayout.sectionInset = UIEdgeInsets.zero
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .direction()
        
        let background = isNight(readerConfig.nightModeBackground, UIColor.white)
        view.backgroundColor = background
        
        // CollectionView
        collectionView = UICollectionView(frame: screenBounds, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = background
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
		enableScrollBetweenChapters(scrollEnabled: true)
        view.addSubview(collectionView)
        
        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }
        
        // Register cell classes
        collectionView!.register(FolioReaderPage.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Configure navigation bar and layout
        automaticallyAdjustsScrollViewInsets = false
        extendedLayoutIncludesOpaqueBars = true
        configureNavBar()

		// Page indicator view
        if !readerConfig.hidePageIndicator {
            pageIndicatorView = FolioReaderPageIndicator(frame: self.frameForPageIndicatorView())
            if let pageIndicatorView = pageIndicatorView {
                view.addSubview(pageIndicatorView)
            }
        }

		scrollScrubber = ScrollScrubber(frame: self.frameForScrollScrubber())
		scrollScrubber?.delegate = self
		if let scrollScrubber = scrollScrubber {
			view.addSubview(scrollScrubber.slider)
		}
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update pages
        pagesForCurrentPage(currentPage)
        pageIndicatorView?.reloadView(updateShadow: true)
    }

	override open func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		screenBounds = view.frame
        loadingView.center = view.center

		setPageSize(UIApplication.shared.statusBarOrientation)
		updateSubviewFrames()
	}

	// MARK: Layout

	/**
	Enable or disable the scrolling between chapters (`FolioReaderPage`s). If this is enabled it's only possible to read the current chapter. If another chapter should be displayed is has to be triggered programmatically with `changePageWith`.

	- parameter scrollEnabled: `Bool` which enables or disables the scrolling between `FolioReaderPage`s.
	*/
	open func enableScrollBetweenChapters(scrollEnabled: Bool) {
		self.collectionView.isScrollEnabled = scrollEnabled
	}

	fileprivate func updateSubviewFrames() {
		self.pageIndicatorView?.frame = self.frameForPageIndicatorView()
		self.scrollScrubber?.frame = self.frameForScrollScrubber()
	}

	fileprivate func frameForPageIndicatorView() -> CGRect {
		return CGRect(x: 0, y: view.frame.height-pageIndicatorHeight, width: view.frame.width, height: pageIndicatorHeight)
	}

	fileprivate func frameForScrollScrubber() -> CGRect {
		let scrubberY: CGFloat = ((readerConfig.shouldHideNavigationOnTap == true || readerConfig.hideBars == true) ? 50 : 74)
		return CGRect(x: pageWidth + 10, y: scrubberY, width: 40, height: pageHeight - 100)
	}

    func configureNavBar() {
        let navBackground = isNight(readerConfig.nightModeMenuBackground, UIColor.white)
        let tintColor = readerConfig.tintColor
        let navText = isNight(UIColor.white, UIColor.black)
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
    }
    
    func configureNavBarButtons() {

        // Navbar buttons
        let shareIcon = UIImage(readerImageNamed: "icon-navbar-share")?.ignoreSystemTint()
        let audioIcon = UIImage(readerImageNamed: "icon-navbar-tts")?.ignoreSystemTint() //man-speech-icon
        let closeIcon = UIImage(readerImageNamed: "icon-navbar-close")?.ignoreSystemTint()
        let tocIcon = UIImage(readerImageNamed: "icon-navbar-toc")?.ignoreSystemTint()
        let fontIcon = UIImage(readerImageNamed: "icon-navbar-font")?.ignoreSystemTint()
        let space = 70 as CGFloat

        let menu = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action:#selector(closeReader(_:)))
        let toc = UIBarButtonItem(image: tocIcon, style: .plain, target: self, action:#selector(presentChapterList(_:)))
        
        navigationItem.leftBarButtonItems = [menu, toc]
        
        var rightBarIcons = [UIBarButtonItem]()

        if readerConfig.allowSharing {
            rightBarIcons.append(UIBarButtonItem(image: shareIcon, style: .plain, target: self, action:#selector(shareChapter(_:))))
        }

        if book.hasAudio() || readerConfig.enableTTS {
            rightBarIcons.append(UIBarButtonItem(image: audioIcon, style: .plain, target: self, action:#selector(presentPlayerMenu(_:))))
        }
        
        let font = UIBarButtonItem(image: fontIcon, style: .plain, target: self, action: #selector(presentFontsMenu))
        font.width = space
        
        rightBarIcons.append(contentsOf: [font])
        navigationItem.rightBarButtonItems = rightBarIcons
    }

    func reloadData() {
        loadingView.stopAnimating()
        totalPages = book.spine.spineReferences.count

        collectionView.reloadData()
        configureNavBarButtons()
        setCollectionViewProgressiveDirection()
        
        if let position = FolioReader.defaults.value(forKey: kBookId) as? NSDictionary,
            let pageNumber = position["pageNumber"] as? Int , pageNumber > 0 {
            changePageWith(page: pageNumber)
            currentPageNumber = pageNumber
            return
        }
        
        currentPageNumber = 1
    }
    
    // MARK: Change page progressive direction
    
    func setCollectionViewProgressiveDirection() {
        if FolioReader.needsRTLChange {
            collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            collectionView.transform = CGAffineTransform.identity
        }
    }
    
    func setPageProgressiveDirection(_ page: FolioReaderPage) {
        if FolioReader.needsRTLChange {
//            if page.transform.a == -1 { return }
            page.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            page.transform = CGAffineTransform.identity
        }
    }

    
    // MARK: Change layout orientation
    
    func setScrollDirection(_ direction: FolioReaderScrollDirection) {
        guard let currentPage = currentPage else { return }
        
        // Get internal page offset before layout change
        let pageScrollView = currentPage.webView.scrollView
        pageOffsetRate = pageScrollView.contentOffset.forDirection() / pageScrollView.contentSize.forDirection()
        
        // Change layout
        readerConfig.scrollDirection = direction
        collectionViewLayout.scrollDirection = .direction()
        currentPage.setNeedsLayout()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setContentOffset(frameForPage(currentPageNumber).origin, animated: false)
        
        // Page progressive direction
        setCollectionViewProgressiveDirection()
        delay(0.2) { self.setPageProgressiveDirection(currentPage) }
        
        
        /**
         *  This delay is needed because the page will not be ready yet
         *  so the delay wait until layout finished the changes.
         */
        delay(0.1) {
            var pageOffset = pageScrollView.contentSize.forDirection() * self.pageOffsetRate
            
            // Fix the offset for paged scroll
            if readerConfig.scrollDirection == .horizontal {
                let page = round(pageOffset / pageWidth)
                pageOffset = page * pageWidth
            }
            
            let pageOffsetPoint = isDirection(CGPoint(x: 0, y: pageOffset), CGPoint(x: pageOffset, y: 0))
            pageScrollView.setContentOffset(pageOffsetPoint, animated: true)
        }
    }

    // MARK: Status bar and Navigation bar

    func hideBars() {

        if readerConfig.shouldHideNavigationOnTap == false { return }

        let shouldHide = true
        FolioReader.shared.readerContainer.shouldHideStatusBar = shouldHide
        
        UIView.animate(withDuration: 0.25, animations: {
            FolioReader.shared.readerContainer.setNeedsStatusBarAppearanceUpdate()
            
            // Show minutes indicator
//            self.pageIndicatorView.minutesLabel.alpha = 0
        })
        navigationController?.setNavigationBarHidden(shouldHide, animated: true)
    }
    
    func showBars() {
        configureNavBar()
        
        let shouldHide = false
        FolioReader.shared.readerContainer.shouldHideStatusBar = shouldHide
        
        UIView.animate(withDuration: 0.25, animations: {
            FolioReader.shared.readerContainer.setNeedsStatusBarAppearanceUpdate()
        })
        navigationController?.setNavigationBarHidden(shouldHide, animated: true)
    }
    
    func toggleBars() {
        if readerConfig.shouldHideNavigationOnTap == false { return }
        
        let shouldHide = !navigationController!.isNavigationBarHidden
        if !shouldHide { configureNavBar() }
        
        FolioReader.shared.readerContainer.shouldHideStatusBar = shouldHide
        
        UIView.animate(withDuration: 0.25, animations: {
            FolioReader.shared.readerContainer.setNeedsStatusBarAppearanceUpdate()
            
            // Show minutes indicator
//            self.pageIndicatorView.minutesLabel.alpha = shouldHide ? 0 : 1
        })
        navigationController?.setNavigationBarHidden(shouldHide, animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalPages
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FolioReaderPage
        
        cell.pageNumber = (indexPath as NSIndexPath).row+1
        cell.webView.scrollView.delegate = self
        cell.webView.setupScrollDirection()
        cell.webView.frame = cell.webViewFrame()
        cell.delegate = self
        cell.backgroundColor = UIColor.clear
        
        setPageProgressiveDirection(cell)
        
        // Configure the cell
		if let resource = book.spine.spineReferences[(indexPath as NSIndexPath).row].resource,
            var html = try? String(contentsOfFile: resource.fullHref, encoding: String.Encoding.utf8) {
			let mediaOverlayStyleColors = "\"\(readerConfig.mediaOverlayColor.hexString(false))\", \"\(readerConfig.mediaOverlayColor.highlightColor().hexString(false))\""

			// Inject CSS
			let jsFilePath = Bundle.frameworkBundle().path(forResource: "Bridge", ofType: "js")
			let cssFilePath = Bundle.frameworkBundle().path(forResource: "Style", ofType: "css")
			let cssTag = "<link rel=\"stylesheet\" type=\"text/css\" href=\"\(cssFilePath!)\">"
			let jsTag = "<script type=\"text/javascript\" src=\"\(jsFilePath!)\"></script>" +
				"<script type=\"text/javascript\">setMediaOverlayStyleColors(\(mediaOverlayStyleColors))</script>"

			let toInject = "\n\(cssTag)\n\(jsTag)\n</head>"
			html = html.replacingOccurrences(of: "</head>", with: toInject)

			// Font class name
			var classes = FolioReader.currentFont.cssIdentifier
			classes += " "+FolioReader.currentMediaOverlayStyle.className()

			// Night mode
			if FolioReader.nightMode {
				classes += " nightMode"
			}

			// Font Size
			classes += " \(FolioReader.currentFontSize.cssIdentifier)"

			html = html.replacingOccurrences(of: "<html ", with: "<html class=\"\(classes)\"")

			// Let the delegate adjust the html string
			if let modifiedHtmlContent = self.delegate?.htmlContentForPage?(cell, htmlContent: html) {
				html = modifiedHtmlContent
			}

			cell.loadHTMLString(html, baseURL: URL(fileURLWithPath: (resource.fullHref as NSString).deletingLastPathComponent))
		}

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    // MARK: - Device rotation
    
    override open func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        guard FolioReader.isReaderReady else { return }
        
        setPageSize(toInterfaceOrientation)
        updateCurrentPage()

		if (self.currentOrientation == nil || (self.currentOrientation?.isPortrait != toInterfaceOrientation.isPortrait)) {

			var pageIndicatorFrame = pageIndicatorView?.frame
			pageIndicatorFrame?.origin.y = ((screenBounds.size.height < screenBounds.size.width) ? (self.collectionView.frame.height - pageIndicatorHeight) : (self.collectionView.frame.width - pageIndicatorHeight))
			pageIndicatorFrame?.origin.x = 0
			pageIndicatorFrame?.size.width = ((screenBounds.size.height < screenBounds.size.width) ? (self.collectionView.frame.width) : (self.collectionView.frame.height))
			pageIndicatorFrame?.size.height = pageIndicatorHeight

			var scrollScrubberFrame = scrollScrubber?.slider.frame;
			scrollScrubberFrame?.origin.x = ((screenBounds.size.height < screenBounds.size.width) ? (view.frame.width - 100) : (view.frame.height + 10))
			scrollScrubberFrame?.size.height = ((screenBounds.size.height < screenBounds.size.width) ? (self.collectionView.frame.height - 100) : (self.collectionView.frame.width - 100))

			self.collectionView.collectionViewLayout.invalidateLayout()

			UIView.animate(withDuration: duration, animations: {

				// Adjust page indicator view
				if let pageIndicatorFrame = pageIndicatorFrame {
					self.pageIndicatorView?.frame = pageIndicatorFrame
					self.pageIndicatorView?.reloadView(updateShadow: true)
				}

				// Adjust scroll scrubber slider
				if let scrollScrubberFrame = scrollScrubberFrame {
					self.scrollScrubber?.slider.frame = scrollScrubberFrame
				}

				// Adjust collectionView
				self.collectionView.contentSize = isDirection(
					CGSize(width: pageWidth, height: pageHeight * CGFloat(self.totalPages)),
					CGSize(width: pageWidth * CGFloat(self.totalPages), height: pageHeight),
					CGSize(width: pageWidth * CGFloat(self.totalPages), height: pageHeight)
				)
				self.collectionView.setContentOffset(self.frameForPage(currentPageNumber).origin, animated: false)
				self.collectionView.collectionViewLayout.invalidateLayout()

				// Adjust internal page offset
				guard let currentPage = self.currentPage else { return }
				let pageScrollView = currentPage.webView.scrollView
				self.pageOffsetRate = pageScrollView.contentOffset.forDirection() / pageScrollView.contentSize.forDirection()
			})
		}

		self.currentOrientation = toInterfaceOrientation
    }
    
    override open func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        guard FolioReader.isReaderReady else { return }
        guard let currentPage = currentPage else { return }
        
        // Update pages
        pagesForCurrentPage(currentPage)
        currentPage.refreshPageMode()
        
        scrollScrubber?.setSliderVal()
        
        // After rotation fix internal page offset
        var pageOffset = currentPage.webView.scrollView.contentSize.forDirection() * pageOffsetRate
        
        // Fix the offset for paged scroll
        if readerConfig.scrollDirection == .horizontal {
            let page = round(pageOffset / pageWidth)
            pageOffset = page * pageWidth
        }

		let pageOffsetPoint = isDirection(CGPoint(x: 0, y: pageOffset), CGPoint(x: pageOffset, y: 0))
		currentPage.webView.scrollView.setContentOffset(pageOffsetPoint, animated: true)
    }
    
    override open func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        guard FolioReader.isReaderReady else { return }
        
		self.collectionView.scrollToItem(at: IndexPath(row: currentPageNumber - 1, section: 0), at: UICollectionViewScrollPosition(), animated: false)
        if currentPageNumber+1 >= totalPages {
            UIView.animate(withDuration: duration, animations: {
                self.collectionView.setContentOffset(self.frameForPage(currentPageNumber).origin, animated: false)
            })
        }
    }
    
    // MARK: - Page
    
    func setPageSize(_ orientation: UIInterfaceOrientation) {
        if orientation.isPortrait {
            if screenBounds.size.width < screenBounds.size.height {
                pageWidth = self.view.frame.width
                pageHeight = self.view.frame.height
            } else {
                pageWidth = self.view.frame.height
                pageHeight = self.view.frame.width
            }
        } else {
            if screenBounds.size.width > screenBounds.size.height {
                pageWidth = self.view.frame.width
                pageHeight = self.view.frame.height
            } else {
                pageWidth = self.view.frame.height
                pageHeight = self.view.frame.width
            }
        }
    }
    
    func updateCurrentPage(_ completion: (() -> Void)? = nil) {
        updateCurrentPage(nil) { () -> Void in
            completion?()
        }
    }
    
    func updateCurrentPage(_ page: FolioReaderPage? = nil, completion: (() -> Void)? = nil) {
        if let page = page {
            currentPage = page
            previousPageNumber = page.pageNumber-1
            currentPageNumber = page.pageNumber
        } else {
            let currentIndexPath = getCurrentIndexPath()
			currentPage = collectionView.cellForItem(at: currentIndexPath) as? FolioReaderPage

            previousPageNumber = (currentIndexPath as NSIndexPath).row
            currentPageNumber = (currentIndexPath as NSIndexPath).row+1
        }
        
        nextPageNumber = currentPageNumber+1 <= totalPages ? currentPageNumber+1 : currentPageNumber
        
//        // Set navigation title
//        if let chapterName = getCurrentChapterName() {
//            title = chapterName
//        } else { title = ""}
        
        // Set pages
        guard let currentPage = currentPage else {
            completion?()
            return
        }
        
        scrollScrubber?.setSliderVal()
        
        if let readingTime = currentPage.webView.js("getReadingTime()") {
            pageIndicatorView?.totalMinutes = Int(readingTime)!
        } else {
            pageIndicatorView?.totalMinutes = 0
        }
        pagesForCurrentPage(currentPage)

        delegate?.pageDidAppear?(currentPage)

        completion?()
    }
    
    func pagesForCurrentPage(_ page: FolioReaderPage?) {
        guard let page = page else { return }

		let pageSize = isDirection(pageHeight, pageWidth)
		pageIndicatorView?.totalPages = Int(ceil(page.webView.scrollView.contentSize.forDirection()/pageSize!))

		let pageOffSet = isDirection(page.webView.scrollView.contentOffset.x, page.webView.scrollView.contentOffset.x, page.webView.scrollView.contentOffset.y)
		let webViewPage = pageForOffset(pageOffSet, pageHeight: pageSize!)

        pageIndicatorView?.currentPage = webViewPage
    }
    
    func pageForOffset(_ offset: CGFloat, pageHeight height: CGFloat) -> Int {
        let page = Int(ceil(offset / height))+1
        return page
    }
    
    func getCurrentIndexPath() -> IndexPath {
        let indexPaths = collectionView.indexPathsForVisibleItems
        var indexPath = IndexPath()
        
        if indexPaths.count > 1 {
            let first = indexPaths.first! as IndexPath
            let last = indexPaths.last! as IndexPath
            
            switch pageScrollDirection {
            case .up:
                if (first as NSIndexPath).compare(last) == .orderedAscending {
                    indexPath = last
                } else {
                    indexPath = first
                }
            default:
                if (first as NSIndexPath).compare(last) == .orderedAscending {
                    indexPath = first
                } else {
                    indexPath = last
                }
            }
        } else {
            indexPath = indexPaths.first ?? IndexPath(row: 0, section: 0)
        }
        
        return indexPath
    }
    
    func frameForPage(_ page: Int) -> CGRect {
        return isDirection(
            CGRect(x: 0, y: pageHeight * CGFloat(page-1), width: pageWidth, height: pageHeight),
            CGRect(x: pageWidth * CGFloat(page-1), y: 0, width: pageWidth, height: pageHeight)
        )
    }
    
    func changePageWith(page: Int, andFragment fragment: String, animated: Bool = false, completion: (() -> Void)? = nil) {
        if currentPageNumber == page {
            if let currentPage = currentPage , fragment != "" {
                currentPage.handleAnchor(fragment, avoidBeginningAnchors: true, animated: animated)
            }
            completion?()
        } else {
            tempFragment = fragment
            changePageWith(page: page, animated: animated, completion: { () -> Void in
                self.updateCurrentPage({ () -> Void in
                    completion?()
                })
            })
        }
    }
    
	func changePageWith(href: String, animated: Bool = false, completion: (() -> Void)? = nil) {
        let item = findPageByHref(href)
        let indexPath = IndexPath(row: item, section: 0)
        changePageWith(indexPath: indexPath, animated: animated, completion: { () -> Void in
            self.updateCurrentPage({ () -> Void in
                completion?()
            })
        })
    }

    func changePageWith(href: String, andAudioMarkID markID: String) {
        if recentlyScrolled { return } // if user recently scrolled, do not change pages or scroll the webview
        guard let currentPage = currentPage else { return }

        let item = findPageByHref(href)
        let pageUpdateNeeded = item+1 != currentPage.pageNumber
        let indexPath = IndexPath(row: item, section: 0)
        changePageWith(indexPath: indexPath, animated: true) { () -> Void in
            if pageUpdateNeeded {
                self.updateCurrentPage({ () -> Void in
                    currentPage.audioMarkID(markID)
                })
            } else {
                currentPage.audioMarkID(markID)
            }
        }
    }

    func changePageWith(indexPath: IndexPath, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard indexPathIsValid(indexPath) else {
            print("ERROR: Attempt to scroll to invalid index path")
            completion?()
            return
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            self.collectionView.scrollToItem(at: indexPath, at: .direction(), animated: false)
        }) { (finished: Bool) -> Void in
            completion?()
        }
    }

    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = (indexPath as NSIndexPath).section
        let row = (indexPath as NSIndexPath).row
        let lastSectionIndex = numberOfSections(in: collectionView) - 1
        
        //Make sure the specified section exists
        if section > lastSectionIndex {
            return false
        }
        
        let rowCount = self.collectionView(collectionView, numberOfItemsInSection: (indexPath as NSIndexPath).section) - 1
        return row <= rowCount
    }
    
    func isLastPage() -> Bool{
        return currentPageNumber == nextPageNumber
    }

    func changePageToNext(_ completion: (() -> Void)? = nil) {
        changePageWith(page: nextPageNumber, animated: true) { () -> Void in
            completion?()
        }
    }
    
    func changePageToPrevious(_ completion: (() -> Void)? = nil) {
        changePageWith(page: previousPageNumber, animated: true) { () -> Void in
            completion?()
        }
    }

    /**
     Find a page by FRTocReference.
    */
    func findPageByResource(_ reference: FRTocReference) -> Int {
        var count = 0
        for item in book.spine.spineReferences {
            if let resource = reference.resource , item.resource == resource {
                return count
            }
            count += 1
        }
        return count
    }
    
    /**
     Find a page by href.
    */
    func findPageByHref(_ href: String) -> Int {
        var count = 0
        for item in book.spine.spineReferences {
            if item.resource.href == href {
                return count
            }
            count += 1
        }
        return count
    }
    
    /**
     Find and return the current chapter resource.
    */
    func getCurrentChapter() -> FRResource? {
        if let currentPageNumber = currentPageNumber {
            for item in book.flatTableOfContents {
                if let reference = book.spine.spineReferences[safe: currentPageNumber-1], let resource = item.resource
                    , resource == reference.resource {
                    return item.resource
                }
            }
        }
        return nil
    }

    /**
     Find and return the current chapter name.
     */
    func getCurrentChapterName() -> String? {
        if let currentPageNumber = currentPageNumber {
            for item in book.flatTableOfContents {
                if let reference = book.spine.spineReferences[safe: currentPageNumber-1], let resource = item.resource
                    , resource == reference.resource {
                    if let title = item.title {
                        return title
                    }
                    return nil
                }
            }
        }
        return nil
    }

	// MARK: Public page methods

	/**
	Changes the current page of the reader.
	
	- parameter page: The target page index. Note: The page index starts at 1 (and not 0).
	- parameter animated: En-/Disables the animation of the page change.
	- parameter completion: A Closure which is called if the page change is completed.
	*/
	open func changePageWith(page: Int, animated: Bool = false, completion: (() -> Void)? = nil) {
		if page > 0 && page-1 < totalPages {
			let indexPath = IndexPath(row: page-1, section: 0)
			changePageWith(indexPath: indexPath, animated: animated, completion: { () -> Void in
				self.updateCurrentPage({ () -> Void in
					completion?()
				})
			})
		}
	}
    
    // MARK: - Audio Playing

    func audioMark(href: String, fragmentID: String) {
        changePageWith(href: href, andAudioMarkID: fragmentID)
    }

    // MARK: - Sharing
    
    /**
     Sharing chapter method.
    */
    func shareChapter(_ sender: UIBarButtonItem) {
        guard let currentPage = currentPage else { return }
        
        if let chapterText = currentPage.webView.js("getBodyText()") {
            let htmlText = chapterText.replacingOccurrences(of: "[\\n\\r]+", with: "<br />", options: .regularExpression)
            var subject = readerConfig.localizedShareChapterSubject
            var html = ""
            var text = ""
            var bookTitle = ""
            var chapterName = ""
            var authorName = ""
            var shareItems = [AnyObject]()
            
            // Get book title
            if let title = book.title() {
                bookTitle = title
                subject += " “\(title)”"
            }
            
            // Get chapter name
            if let chapter = getCurrentChapterName() {
                chapterName = chapter
            }
            
            // Get author name
            if let author = book.metadata.creators.first {
                authorName = author.name
            }
            
            // Sharing html and text
            html = "<html><body>"
            html += "<br /><hr> <p>\(htmlText)</p> <hr><br />"
            html += "<center><p style=\"color:gray\">"+readerConfig.localizedShareAllExcerptsFrom+"</p>"
            html += "<b>\(bookTitle)</b><br />"
            html += readerConfig.localizedShareBy+" <i>\(authorName)</i><br />"
            
            if let bookShareLink = readerConfig.localizedShareWebLink {
                html += "<a href=\"\(bookShareLink.absoluteString)\">\(bookShareLink.absoluteString)</a>"
                shareItems.append(bookShareLink as AnyObject)
            }
            
            html += "</center></body></html>"
            text = "\(chapterName)\n\n“\(chapterText)” \n\n\(bookTitle) \n\(readerConfig.localizedShareBy) \(authorName)"
            
            let act = FolioReaderSharingProvider(subject: subject, text: text, html: html)
            shareItems.insert(contentsOf: [act, "" as AnyObject], at: 0)
            
            let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToVimeo]
            
            // Pop style on iPad
            if let actv = activityViewController.popoverPresentationController {
                actv.barButtonItem = sender
            }
            
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    /**
     Sharing highlight method.
    */
    func shareHighlight(_ string: String, rect: CGRect) {
        var subject = readerConfig.localizedShareHighlightSubject
        var html = ""
        var text = ""
        var bookTitle = ""
        var chapterName = ""
        var authorName = ""
        var shareItems = [AnyObject]()
        
        // Get book title
        if let title = book.title() {
            bookTitle = title
            subject += " “\(title)”"
        }
        
        // Get chapter name
        if let chapter = getCurrentChapterName() {
            chapterName = chapter
        }
        
        // Get author name
        if let author = book.metadata.creators.first {
            authorName = author.name
        }
        
        // Sharing html and text
        html = "<html><body>"
        html += "<br /><hr> <p>\(chapterName)</p>"
        html += "<p>\(string)</p> <hr><br />"
        html += "<center><p style=\"color:gray\">"+readerConfig.localizedShareAllExcerptsFrom+"</p>"
        html += "<b>\(bookTitle)</b><br />"
        html += readerConfig.localizedShareBy+" <i>\(authorName)</i><br />"
        
        if let bookShareLink = readerConfig.localizedShareWebLink {
            html += "<a href=\"\(bookShareLink.absoluteString)\">\(bookShareLink.absoluteString)</a>"
            shareItems.append(bookShareLink as AnyObject)
        }
        
        html += "</center></body></html>"
        text = "\(chapterName)\n\n“\(string)” \n\n\(bookTitle) \n\(readerConfig.localizedShareBy) \(authorName)"
        
        let act = FolioReaderSharingProvider(subject: subject, text: text, html: html)
        shareItems.insert(contentsOf: [act, "" as AnyObject], at: 0)
        
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToVimeo]
        
        // Pop style on iPad
        if let actv = activityViewController.popoverPresentationController {
            actv.sourceView = currentPage
            actv.sourceRect = rect
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - ScrollView Delegate
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
        clearRecentlyScrolled()
        recentlyScrolled = true
        pointNow = scrollView.contentOffset
        
        if let currentPage = currentPage {
            currentPage.webView.createMenu(options: true)
            currentPage.webView.setMenuVisible(false)
        }
        
        scrollScrubber?.scrollViewWillBeginDragging(scrollView)
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !navigationController!.isNavigationBarHidden {
            toggleBars()
        }
        
        scrollScrubber?.scrollViewDidScroll(scrollView)
        
        // Update current reading page
        if scrollView is UICollectionView {} else {
            let pageSize = isDirection(pageHeight, pageWidth)
            
            if let page = currentPage
                , page.webView.scrollView.contentOffset.forDirection()+pageSize! <= page.webView.scrollView.contentSize.forDirection() {

				let webViewPage = pageForOffset(page.webView.scrollView.contentOffset.forDirection(), pageHeight: pageSize!)

				if (readerConfig.scrollDirection == .horizontalWithVerticalContent),
					let cell = ((scrollView.superview as? UIWebView)?.delegate as? FolioReaderPage) {

					let currentIndexPathRow = cell.pageNumber - 1

					// if the cell reload don't save the top position offset
					if let oldOffSet = self.currentWebViewScrollPositions[currentIndexPathRow]
					, (abs(oldOffSet.y - scrollView.contentOffset.y) > 100) {} else {
						self.currentWebViewScrollPositions[currentIndexPathRow] = scrollView.contentOffset
					}
				}

                if pageIndicatorView?.currentPage != webViewPage {
                    pageIndicatorView?.currentPage = webViewPage
                }
            }
        }
        
        pageScrollDirection = scrollView.contentOffset.forDirection() < pointNow.forDirection() ? .negative() : .positive()
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false

		if (readerConfig.scrollDirection == .horizontalWithVerticalContent),
			let cell = ((scrollView.superview as? UIWebView)?.delegate as? FolioReaderPage) {
				let currentIndexPathRow = cell.pageNumber - 1
				self.currentWebViewScrollPositions[currentIndexPathRow] = scrollView.contentOffset
		}

        if scrollView is UICollectionView {
            if totalPages > 0 { updateCurrentPage() }
        }
        
        scrollScrubber?.scrollViewDidEndDecelerating(scrollView)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        recentlyScrolledTimer = Timer(timeInterval:recentlyScrolledDelay, target: self, selector: #selector(FolioReaderCenter.clearRecentlyScrolled), userInfo: nil, repeats: false)
        RunLoop.current.add(recentlyScrolledTimer, forMode: RunLoopMode.commonModes)
    }

    func clearRecentlyScrolled() {
        if(recentlyScrolledTimer != nil) {
            recentlyScrolledTimer.invalidate()
            recentlyScrolledTimer = nil
        }
        recentlyScrolled = false
    }

    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollScrubber?.scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    
    // MARK: NavigationBar Actions
    
    func closeReader(_ sender: UIBarButtonItem) {
        dismiss()
        FolioReader.close()
    }
    
    /**
     Present chapter list
     */
    func presentChapterList(_ sender: UIBarButtonItem) {
        FolioReader.saveReaderState()
        
        let chapter = FolioReaderChapterList()
        chapter.delegate = self
        let highlight = FolioReaderHighlightList()
        
        let pageController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options:nil)
        pageController.viewControllerOne = chapter
        pageController.viewControllerTwo = highlight
        pageController.segmentedControlItems = [readerConfig.localizedContentsTitle, readerConfig.localizedHighlightsTitle]
        
        let nav = UINavigationController(rootViewController: pageController)
        present(nav, animated: true, completion: nil)
    }
    
    /**
     Present fonts and settings menu
     */
    func presentFontsMenu() {
        FolioReader.saveReaderState()
        hideBars()
        
        let menu = FolioReaderFontsMenu()
        menu.modalPresentationStyle = .custom

        animator = ZFModalTransitionAnimator(modalViewController: menu)
        animator.isDragable = false
        animator.bounces = false
        animator.behindViewAlpha = 0.4
        animator.behindViewScale = 1
        animator.transitionDuration = 0.6
        animator.direction = ZFModalTransitonDirection.bottom

        menu.transitioningDelegate = animator
        present(menu, animated: true, completion: nil)
    }

    /**
     Present audio player menu
     */
    func presentPlayerMenu(_ sender: UIBarButtonItem) {
        FolioReader.saveReaderState()
        hideBars()

        let menu = FolioReaderPlayerMenu()
        menu.modalPresentationStyle = .custom

        animator = ZFModalTransitionAnimator(modalViewController: menu)
        animator.isDragable = true
        animator.bounces = false
        animator.behindViewAlpha = 0.4
        animator.behindViewScale = 1
        animator.transitionDuration = 0.6
        animator.direction = ZFModalTransitonDirection.bottom

        menu.transitioningDelegate = animator
        present(menu, animated: true, completion: nil)
    }
    
    /**
     Present Quote Share
     */
    func presentQuoteShare(_ string: String) {
        let quoteShare = FolioReaderQuoteShare(initWithText: string)
        let nav = UINavigationController(rootViewController: quoteShare)

        if isPad {
            nav.modalPresentationStyle = .formSheet
        }
        
        present(nav, animated: true, completion: nil)
    }
}

// MARK: FolioPageDelegate

extension FolioReaderCenter: FolioReaderPageDelegate {
    
    public func pageDidLoad(_ page: FolioReaderPage) {
        
        if let position = FolioReader.defaults.value(forKey: kBookId) as? NSDictionary {
            let pageNumber = position["pageNumber"]! as! Int
			let offset = isDirection(position["pageOffsetY"], position["pageOffsetX"]) as? CGFloat
			let pageOffset = offset

            if isFirstLoad {
                updateCurrentPage(page)
                isFirstLoad = false
                
                if currentPageNumber == pageNumber && pageOffset > 0 {
                    page.scrollPageToOffset(pageOffset!, animated: false)
                }
            } else if !isScrolling && FolioReader.needsRTLChange {
                page.scrollPageToBottom()
            }
        } else if isFirstLoad {
            updateCurrentPage(page)
            isFirstLoad = false
        }
        
        // Go to fragment if needed
        if let fragmentID = tempFragment, let currentPage = currentPage , fragmentID != "" {
            currentPage.handleAnchor(fragmentID, avoidBeginningAnchors: true, animated: true)
            tempFragment = nil
        }

		if (readerConfig.scrollDirection == .horizontalWithVerticalContent),
			let offsetPoint = self.currentWebViewScrollPositions[page.pageNumber - 1] {
				page.webView.scrollView.setContentOffset(offsetPoint, animated: false)
		}

		// Pass the event to the centers `pageDelegate`
		pageDelegate?.pageDidLoad?(page)
    }

	public func pageWillLoad(_ page: FolioReaderPage) {
		// Pass the event to the centers `pageDelegate`
		pageDelegate?.pageWillLoad?(page)
	}
}

// MARK: FolioReaderChapterListDelegate

extension FolioReaderCenter: FolioReaderChapterListDelegate {

    func chapterList(_ chapterList: FolioReaderChapterList, didSelectRowAtIndexPath indexPath: IndexPath, withTocReference reference: FRTocReference) {
        let item = findPageByResource(reference)
        
        if item < totalPages {
            let indexPath = IndexPath(row: item, section: 0)
            changePageWith(indexPath: indexPath, animated: false, completion: { () -> Void in
                self.updateCurrentPage()
            })
            tempReference = reference
        } else {
            print("Failed to load book because the requested resource is missing.")
        }
    }
    
    func chapterList(didDismissedChapterList chapterList: FolioReaderChapterList) {
        updateCurrentPage()
        
        // Move to #fragment
        if let reference = tempReference {
            if let fragmentID = reference.fragmentID, let currentPage = currentPage , fragmentID != "" {
                currentPage.handleAnchor(reference.fragmentID!, avoidBeginningAnchors: true, animated: true)
            }
            tempReference = nil
        }
    }
}
