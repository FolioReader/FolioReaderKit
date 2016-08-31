//
//  FolioReaderCenter.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import ZFDragableModalTransition

let reuseIdentifier = "Cell"
var pageWidth: CGFloat!
var pageHeight: CGFloat!
var previousPageNumber: Int!
var currentPageNumber: Int!
var nextPageNumber: Int!
var pageScrollDirection = ScrollDirection()
var isScrolling = false


class FolioReaderCenter: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    let collectionViewLayout = UICollectionViewFlowLayout()
    var loadingView: UIActivityIndicatorView!
    var pages: [String]!
    var totalPages: Int!
    var tempFragment: String?
    var currentPage: FolioReaderPage?
    var animator: ZFModalTransitionAnimator!
    var pageIndicatorView: FolioReaderPageIndicator?
    var bookShareLink: String?
	var pageIndicatorHeight: CGFloat = 20

    var recentlyScrolled = false
    var recentlyScrolledDelay = 2.0 // 2 second delay until we clear recentlyScrolled
    var recentlyScrolledTimer: NSTimer!
    var scrollScrubber: ScrollScrubber?
    
    private var screenBounds: CGRect!
    private var pointNow = CGPointZero
    private var pageOffsetRate: CGFloat = 0
    private var tempReference: FRTocReference?
    private var isFirstLoad = true
	private var currentWebViewScrollPositions = [Int: CGPoint]()
	private var currentOrientation: UIInterfaceOrientation?
    
    // MARK: - View life cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if (readerConfig.hideBars == true) {
			self.pageIndicatorHeight = 0
        }

        screenBounds = self.view.frame
        setPageSize(UIApplication.sharedApplication().statusBarOrientation)
        
        // Layout
        collectionViewLayout.sectionInset = UIEdgeInsetsZero
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .direction()
        
        let background = isNight(readerConfig.nightModeBackground, UIColor.whiteColor())
        view.backgroundColor = background
        
        // CollectionView
        collectionView = UICollectionView(frame: screenBounds, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.pagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = background
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        view.addSubview(collectionView)
        
        // Register cell classes
        collectionView!.registerClass(FolioReaderPage.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        totalPages = book.spine.spineReferences.count
        
        // Configure navigation bar and layout
        automaticallyAdjustsScrollViewInsets = false
        extendedLayoutIncludesOpaqueBars = true
        configureNavBar()

		// Page indicator view
		pageIndicatorView = FolioReaderPageIndicator(frame: self.frameForPageIndicatorView())
		if let _pageIndicatorView = pageIndicatorView {
			view.addSubview(_pageIndicatorView)
		}

		scrollScrubber = ScrollScrubber(frame: self.frameForScrollScrubber())
		scrollScrubber?.delegate = self

		if let _scrollScruber = scrollScrubber {
			view.addSubview(_scrollScruber.slider)
		}

        // Update pages
        pagesForCurrentPage(currentPage)
        pageIndicatorView?.reloadView(updateShadow: true)
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		screenBounds = self.view.frame

		setPageSize(UIApplication.sharedApplication().statusBarOrientation)

		self.updateSubviewFrames()

		if (self.loadingView == nil) {
			// Loading indicator
			let style: UIActivityIndicatorViewStyle = isNight(.White, .Gray)
			loadingView = UIActivityIndicatorView(activityIndicatorStyle: style)
			loadingView.center = view.center
			loadingView.hidesWhenStopped = true
			loadingView.startAnimating()
			view.addSubview(loadingView)
		}
	}

	// MARK: Layout

	private func updateSubviewFrames() {
		self.pageIndicatorView?.frame = self.frameForPageIndicatorView()
		self.scrollScrubber?.frame = self.frameForScrollScrubber()
	}

	private func frameForPageIndicatorView() -> CGRect {
		return CGRect(x: 0, y: view.frame.height-pageIndicatorHeight, width: view.frame.width, height: pageIndicatorHeight)
	}

	private func frameForScrollScrubber() -> CGRect {
		let scrubberY: CGFloat = ((readerConfig.shouldHideNavigationOnTap == true || readerConfig.hideBars == true) ? 50 : 74)
		return CGRect(x: pageWidth + 10, y: scrubberY, width: 40, height: pageHeight - 100)
	}

    func configureNavBar() {
        let navBackground = isNight(readerConfig.nightModeMenuBackground, UIColor.whiteColor())
        let tintColor = readerConfig.tintColor
        let navText = isNight(UIColor.whiteColor(), UIColor.blackColor())
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

        let menu = UIBarButtonItem(image: closeIcon, style: .Plain, target: self, action:#selector(closeReader(_:)))
        let toc = UIBarButtonItem(image: tocIcon, style: .Plain, target: self, action:#selector(presentChapterList(_:)))
        
        navigationItem.leftBarButtonItems = [menu, toc]
        
        var rightBarIcons = [UIBarButtonItem]()

        if readerConfig.allowSharing {
            rightBarIcons.append(UIBarButtonItem(image: shareIcon, style: .Plain, target: self, action:#selector(shareChapter(_:))))
        }

        if book.hasAudio() || readerConfig.enableTTS {
            rightBarIcons.append(UIBarButtonItem(image: audioIcon, style: .Plain, target: self, action:#selector(presentPlayerMenu(_:))))
        }
        
        let font = UIBarButtonItem(image: fontIcon, style: .Plain, target: self, action: #selector(presentFontsMenu))
        font.width = space
        
        rightBarIcons.appendContentsOf([font])
        navigationItem.rightBarButtonItems = rightBarIcons
    }

    func reloadData() {
        loadingView.stopAnimating()
        bookShareLink = readerConfig.localizedShareWebLink
        totalPages = book.spine.spineReferences.count

        collectionView.reloadData()
        configureNavBarButtons()
        setCollectionViewProgressiveDirection()
        
        if let position = FolioReader.defaults.valueForKey(kBookId) as? NSDictionary,
            let pageNumber = position["pageNumber"] as? Int where pageNumber > 0 {
            changePageWith(page: pageNumber)
            currentPageNumber = pageNumber
            return
        }
        
        currentPageNumber = 1
    }
    
    // MARK: Change page progressive direction
    
    func setCollectionViewProgressiveDirection() {
        if FolioReader.needsRTLChange {
            collectionView.transform = CGAffineTransformMakeScale(-1, 1)
        } else {
            collectionView.transform = CGAffineTransformIdentity
        }
    }
    
    func setPageProgressiveDirection(page: FolioReaderPage) {
        if FolioReader.needsRTLChange {
//            if page.transform.a == -1 { return }
            page.transform = CGAffineTransformMakeScale(-1, 1)
        } else {
            page.transform = CGAffineTransformIdentity
        }
    }

    
    // MARK: Change layout orientation
    
    func setScrollDirection(direction: FolioReaderScrollDirection) {
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
            
            let pageOffsetPoint = isDirection(CGPoint(x: 0, y: pageOffset), CGPoint(x: pageOffset, y: 0), CGPoint(x: pageOffset, y: 0))
            pageScrollView.setContentOffset(pageOffsetPoint, animated: true)
        }
    }

    // MARK: Status bar and Navigation bar

    func hideBars() {

        if readerConfig.shouldHideNavigationOnTap == false { return }

        let shouldHide = true
        FolioReader.sharedInstance.readerContainer.shouldHideStatusBar = shouldHide
        
        UIView.animateWithDuration(0.25, animations: {
            FolioReader.sharedInstance.readerContainer.setNeedsStatusBarAppearanceUpdate()
            
            // Show minutes indicator
//            self.pageIndicatorView.minutesLabel.alpha = 0
        })
        navigationController?.setNavigationBarHidden(shouldHide, animated: true)
    }
    
    func showBars() {
        configureNavBar()
        
        let shouldHide = false
        FolioReader.sharedInstance.readerContainer.shouldHideStatusBar = shouldHide
        
        UIView.animateWithDuration(0.25, animations: {
            FolioReader.sharedInstance.readerContainer.setNeedsStatusBarAppearanceUpdate()
        })
        navigationController?.setNavigationBarHidden(shouldHide, animated: true)
    }
    
    func toggleBars() {
        if readerConfig.shouldHideNavigationOnTap == false { return }
        
        let shouldHide = !navigationController!.navigationBarHidden
        if !shouldHide { configureNavBar() }
        
        FolioReader.sharedInstance.readerContainer.shouldHideStatusBar = shouldHide
        
        UIView.animateWithDuration(0.25, animations: {
            FolioReader.sharedInstance.readerContainer.setNeedsStatusBarAppearanceUpdate()
            
            // Show minutes indicator
//            self.pageIndicatorView.minutesLabel.alpha = shouldHide ? 0 : 1
        })
        navigationController?.setNavigationBarHidden(shouldHide, animated: true)
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalPages
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FolioReaderPage
        
        cell.pageNumber = indexPath.row+1
        cell.webView.scrollView.delegate = self
        cell.webView.setupScrollDirection()
        cell.delegate = self
        cell.backgroundColor = UIColor.clearColor()
        
        setPageProgressiveDirection(cell)
        
        // Configure the cell
        let resource = book.spine.spineReferences[indexPath.row].resource
        var html = try? String(contentsOfFile: resource.fullHref, encoding: NSUTF8StringEncoding)
        let mediaOverlayStyleColors = "\"\(readerConfig.mediaOverlayColor.hexString(false))\", \"\(readerConfig.mediaOverlayColor.highlightColor().hexString(false))\""

        // Inject CSS
        let jsFilePath = NSBundle.frameworkBundle().pathForResource("Bridge", ofType: "js")
        let cssFilePath = NSBundle.frameworkBundle().pathForResource("Style", ofType: "css")
        let cssTag = "<link rel=\"stylesheet\" type=\"text/css\" href=\"\(cssFilePath!)\">"
        let jsTag = "<script type=\"text/javascript\" src=\"\(jsFilePath!)\"></script>" +
                    "<script type=\"text/javascript\">setMediaOverlayStyleColors(\(mediaOverlayStyleColors))</script>"
        
        let toInject = "\n\(cssTag)\n\(jsTag)\n</head>"
        html = html?.stringByReplacingOccurrencesOfString("</head>", withString: toInject)
        
        // Font class name
        var classes = ""
        let currentFontName = FolioReader.currentFontName
        switch currentFontName {
        case 0:
            classes = "andada"
            break
        case 1:
            classes = "lato"
            break
        case 2:
            classes = "lora"
            break
        case 3:
            classes = "raleway"
            break
        default:
            break
        }
        
        classes += " "+FolioReader.currentMediaOverlayStyle.className()
        
        // Night mode
        if FolioReader.nightMode {
            classes += " nightMode"
        }
        
        // Font Size
        let currentFontSize = FolioReader.currentFontSize
        switch currentFontSize {
        case 0:
            classes += " textSizeOne"
            break
        case 1:
            classes += " textSizeTwo"
            break
        case 2:
            classes += " textSizeThree"
            break
        case 3:
            classes += " textSizeFour"
            break
        case 4:
            classes += " textSizeFive"
            break
        default:
            break
        }
        
        html = html?.stringByReplacingOccurrencesOfString("<html ", withString: "<html class=\"\(classes)\"")
        
        cell.loadHTMLString(html, baseURL: NSURL(fileURLWithPath: (resource.fullHref as NSString).stringByDeletingLastPathComponent))
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.frame.width, collectionView.frame.height)
    }
    
    // MARK: - Device rotation
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
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

			UIView.animateWithDuration(duration, animations: {

				// Adjust page indicator view
				if let _pageIndicatorFrame = pageIndicatorFrame {
					self.pageIndicatorView?.frame = _pageIndicatorFrame
					self.pageIndicatorView?.reloadView(updateShadow: true)
				}

				// Adjust scroll scrubber slider
				if let _scrollScrubberFrame = scrollScrubberFrame {
					self.scrollScrubber?.slider.frame = _scrollScrubberFrame
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
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
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

		let pageOffsetPoint = isDirection(CGPoint(x: 0, y: pageOffset), CGPoint(x: pageOffset, y: 0), CGPoint(x: 0, y: pageOffset))
		currentPage.webView.scrollView.setContentOffset(pageOffsetPoint, animated: true)
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        guard FolioReader.isReaderReady else { return }
        
		self.collectionView.scrollToItemAtIndexPath(NSIndexPath(forRow: currentPageNumber - 1, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.None, animated: false)
        if currentPageNumber+1 >= totalPages {
            UIView.animateWithDuration(duration, animations: {
                self.collectionView.setContentOffset(self.frameForPage(currentPageNumber).origin, animated: false)
            })
        }
    }
    
    // MARK: - Page
    
    func setPageSize(orientation: UIInterfaceOrientation) {
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
    
    func updateCurrentPage(completion: (() -> Void)? = nil) {
        updateCurrentPage(nil) { () -> Void in
            completion?()
        }
    }
    
    func updateCurrentPage(page: FolioReaderPage!, completion: (() -> Void)? = nil) {
        if let page = page {
            currentPage = page
            previousPageNumber = page.pageNumber-1
            currentPageNumber = page.pageNumber
        } else {
            let currentIndexPath = getCurrentIndexPath()
            if currentIndexPath != NSIndexPath(forRow: 0, inSection: 0) {
                currentPage = collectionView.cellForItemAtIndexPath(currentIndexPath) as? FolioReaderPage
            }
            
            previousPageNumber = currentIndexPath.row
            currentPageNumber = currentIndexPath.row+1
        }
        
        nextPageNumber = currentPageNumber+1 <= totalPages ? currentPageNumber+1 : currentPageNumber
        
//        // Set navigation title
//        if let chapterName = getCurrentChapterName() {
//            title = chapterName
//        } else { title = ""}
        
        // Set pages
        if let page = currentPage {
            page.webView.becomeFirstResponder()
            
            scrollScrubber?.setSliderVal()
            
            if let readingTime = page.webView.js("getReadingTime()") {
                pageIndicatorView?.totalMinutes = Int(readingTime)!
                
            } else {
                pageIndicatorView?.totalMinutes = 0
            }
            pagesForCurrentPage(page)
        }
        
        completion?()
    }
    
    func pagesForCurrentPage(page: FolioReaderPage?) {
        guard let page = page else { return }

		let pageSize = isDirection(pageHeight, pageWidth, pageHeight)
		pageIndicatorView?.totalPages = Int(ceil(page.webView.scrollView.contentSize.forDirection()/pageSize))

		let pageOffSet = isDirection(page.webView.scrollView.contentOffset.x, page.webView.scrollView.contentOffset.x, page.webView.scrollView.contentOffset.y)
		let webViewPage = pageForOffset(pageOffSet, pageHeight: pageSize)

        pageIndicatorView?.currentPage = webViewPage
    }
    
    func pageForOffset(offset: CGFloat, pageHeight height: CGFloat) -> Int {
        let page = Int(ceil(offset / height))+1
        return page
    }
    
    func getCurrentIndexPath() -> NSIndexPath {
        let indexPaths = collectionView.indexPathsForVisibleItems()
        var indexPath = NSIndexPath()
        
        if indexPaths.count > 1 {
            let first = indexPaths.first! as NSIndexPath
            let last = indexPaths.last! as NSIndexPath
            
            switch pageScrollDirection {
            case .Up:
                if first.compare(last) == .OrderedAscending {
                    indexPath = last
                } else {
                    indexPath = first
                }
            default:
                if first.compare(last) == .OrderedAscending {
                    indexPath = first
                } else {
                    indexPath = last
                }
            }
        } else {
            indexPath = indexPaths.first ?? NSIndexPath(forRow: 0, inSection: 0)
        }
        
        return indexPath
    }
    
    func frameForPage(page: Int) -> CGRect {
        return isDirection(
            CGRectMake(0, pageHeight * CGFloat(page-1), pageWidth, pageHeight),
            CGRectMake(pageWidth * CGFloat(page-1), 0, pageWidth, pageHeight),
            CGRectMake(0, pageHeight * CGFloat(page-1), pageWidth, pageHeight)
        )
    }
    
    func changePageWith(page page: Int, animated: Bool = false, completion: (() -> Void)? = nil) {
        if page > 0 && page-1 < totalPages {
            let indexPath = NSIndexPath(forRow: page-1, inSection: 0)
            changePageWith(indexPath: indexPath, animated: animated, completion: { () -> Void in
                self.updateCurrentPage({ () -> Void in
                    completion?()
                })
            })
        }
    }
    
    func changePageWith(page page: Int, andFragment fragment: String, animated: Bool = false, completion: (() -> Void)? = nil) {
        if currentPageNumber == page {
            if let currentPage = currentPage where fragment != "" {
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
    
    func changePageWith(href href: String, animated: Bool = false, completion: (() -> Void)? = nil) {
        let item = findPageByHref(href)
        let indexPath = NSIndexPath(forRow: item, inSection: 0)
        changePageWith(indexPath: indexPath, animated: animated, completion: { () -> Void in
            self.updateCurrentPage({ () -> Void in
                completion?()
            })
        })
    }

    func changePageWith(href href: String, andAudioMarkID markID: String) {
        if recentlyScrolled { return } // if user recently scrolled, do not change pages or scroll the webview
        guard let currentPage = currentPage else { return }

        let item = findPageByHref(href)
        let pageUpdateNeeded = item+1 != currentPage.pageNumber
        let indexPath = NSIndexPath(forRow: item, inSection: 0)
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

    func changePageWith(indexPath indexPath: NSIndexPath, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard indexPathIsValid(indexPath) else {
            print("ERROR: Attempt to scroll to invalid index path")
            completion?()
            return
        }
        
        UIView.animateWithDuration(animated ? 0.3 : 0, delay: 0, options: .CurveEaseInOut, animations: { () -> Void in
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .direction(), animated: false)
        }) { (finished: Bool) -> Void in
            completion?()
        }
    }
    
    func indexPathIsValid(indexPath: NSIndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        let lastSectionIndex = numberOfSectionsInCollectionView(collectionView) - 1
        
        //Make sure the specified section exists
        if section > lastSectionIndex {
            return false
        }
        
        let rowCount = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1
        return row <= rowCount
    }
    
    func isLastPage() -> Bool{
        return currentPageNumber == nextPageNumber
    }

    func changePageToNext(completion: (() -> Void)? = nil) {
        changePageWith(page: nextPageNumber, animated: true) { () -> Void in
            completion?()
        }
    }
    
    func changePageToPrevious(completion: (() -> Void)? = nil) {
        changePageWith(page: previousPageNumber, animated: true) { () -> Void in
            completion?()
        }
    }

    /**
     Find a page by FRTocReference.
    */
    func findPageByResource(reference: FRTocReference) -> Int {
        var count = 0
        for item in book.spine.spineReferences {
            if let resource = reference.resource where item.resource == resource {
                return count
            }
            count += 1
        }
        return count
    }
    
    /**
     Find a page by href.
    */
    func findPageByHref(href: String) -> Int {
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
                if let reference = book.spine.spineReferences[safe: currentPageNumber-1], resource = item.resource
                    where resource == reference.resource {
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
                if let reference = book.spine.spineReferences[safe: currentPageNumber-1], resource = item.resource
                    where resource == reference.resource {
                    if let title = item.title {
                        return title
                    }
                    return nil
                }
            }
        }
        return nil
    }
    
    // MARK: - Audio Playing

    func audioMark(href href: String, fragmentID: String) {
        changePageWith(href: href, andAudioMarkID: fragmentID)
    }

    // MARK: - Sharing
    
    /**
     Sharing chapter method.
    */
    func shareChapter(sender: UIBarButtonItem) {
        guard let currentPage = currentPage else { return }
        
        if let chapterText = currentPage.webView.js("getBodyText()") {
            
            let htmlText = chapterText.stringByReplacingOccurrencesOfString("[\\n\\r]+", withString: "<br />", options: .RegularExpressionSearch)

            var subject = readerConfig.localizedShareChapterSubject
            var html = ""
            var text = ""
            var bookTitle = ""
            var chapterName = ""
            var authorName = ""
            
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
            if (bookShareLink != nil) { html += "<a href=\"\(bookShareLink!)\">\(bookShareLink!)</a>" }
            html += "</center></body></html>"
            text = "\(chapterName)\n\n“\(chapterText)” \n\n\(bookTitle) \nby \(authorName)"
            if (bookShareLink != nil) { text += " \n\(bookShareLink!)" }
            
            
            let act = FolioReaderSharingProvider(subject: subject, text: text, html: html)
            let shareItems = [act, ""]
            let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
            activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypePostToVimeo, UIActivityTypePostToFacebook]
            
            // Pop style on iPad
            if let actv = activityViewController.popoverPresentationController {
                actv.barButtonItem = sender
            }
            
            presentViewController(activityViewController, animated: true, completion: nil)
        }
    }
    
    /**
     Sharing highlight method.
    */
    func shareHighlight(string: String, rect: CGRect) {
        
        var subject = readerConfig.localizedShareHighlightSubject
        var html = ""
        var text = ""
        var bookTitle = ""
        var chapterName = ""
        var authorName = ""
        
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
        if (bookShareLink != nil) { html += "<a href=\"\(bookShareLink!)\">\(bookShareLink!)</a>" }
        html += "</center></body></html>"
        text = "\(chapterName)\n\n“\(string)” \n\n\(bookTitle) \nby \(authorName)"
        if (bookShareLink != nil) { text += " \n\(bookShareLink!)" }
        
        
        let act = FolioReaderSharingProvider(subject: subject, text: text, html: html)
        let shareItems = [act, ""]
        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityTypePrint, UIActivityTypePostToVimeo, UIActivityTypePostToFacebook]
        
        // Pop style on iPad
        if let actv = activityViewController.popoverPresentationController {
            actv.sourceView = currentPage
            actv.sourceRect = rect
        }
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if !navigationController!.navigationBarHidden {
            toggleBars()
        }
        
        scrollScrubber?.scrollViewDidScroll(scrollView)
        
        // Update current reading page
        if scrollView is UICollectionView {} else {
            let pageSize = isDirection(pageHeight, pageWidth, pageHeight)
            
            if let page = currentPage
                where page.webView.scrollView.contentOffset.forDirection()+pageSize <= page.webView.scrollView.contentSize.forDirection() {

				let webViewPage = pageForOffset(page.webView.scrollView.contentOffset.forDirection(), pageHeight: pageSize)

				if (readerConfig.scrollDirection == .horizontalWithVerticalContent),
					let cell = ((scrollView.superview as? UIWebView)?.delegate as? FolioReaderPage) {

					let currentIndexPathRow = cell.pageNumber - 1

					// if the cell reload don't save the top position offset
					if let oldOffSet = self.currentWebViewScrollPositions[currentIndexPathRow]
					where (abs(oldOffSet.y - scrollView.contentOffset.y) > 100) {} else {
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
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
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
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        recentlyScrolledTimer = NSTimer(timeInterval:recentlyScrolledDelay, target: self, selector: #selector(FolioReaderCenter.clearRecentlyScrolled), userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(recentlyScrolledTimer, forMode: NSRunLoopCommonModes)
    }

    func clearRecentlyScrolled() {
        if(recentlyScrolledTimer != nil) {
            recentlyScrolledTimer.invalidate()
            recentlyScrolledTimer = nil
        }
        recentlyScrolled = false
    }

    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollScrubber?.scrollViewDidEndScrollingAnimation(scrollView)
    }
    
    
    // MARK: NavigationBar Actions
    
    func closeReader(sender: UIBarButtonItem) {
        dismiss()
        FolioReader.close()
    }
    
    /**
     Present chapter list
     */
    func presentChapterList(sender: UIBarButtonItem) {
        FolioReader.saveReaderState()
        
        let chapter = FolioReaderChapterList()
        chapter.delegate = self
        let highlight = FolioReaderHighlightList()
        
        let pageController = PageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options:nil)
        pageController.viewControllerOne = chapter
        pageController.viewControllerTwo = highlight
        pageController.segmentedControlItems = [readerConfig.localizedContentsTitle, readerConfig.localizedHighlightsTitle]
        
        let nav = UINavigationController(rootViewController: pageController)
        presentViewController(nav, animated: true, completion: nil)
    }
    
    /**
     Present fonts and settings menu
     */
    func presentFontsMenu() {
        FolioReader.saveReaderState()
        hideBars()
        
        let menu = FolioReaderFontsMenu()
        menu.modalPresentationStyle = .Custom

        animator = ZFModalTransitionAnimator(modalViewController: menu)
        animator.dragable = false
        animator.bounces = false
        animator.behindViewAlpha = 0.4
        animator.behindViewScale = 1
        animator.transitionDuration = 0.6
        animator.direction = ZFModalTransitonDirection.Bottom

        menu.transitioningDelegate = animator
        presentViewController(menu, animated: true, completion: nil)
    }

    /**
     Present audio player menu
     */
    func presentPlayerMenu(sender: UIBarButtonItem) {
        FolioReader.saveReaderState()
        hideBars()

        let menu = FolioReaderPlayerMenu()
        menu.modalPresentationStyle = .Custom

        animator = ZFModalTransitionAnimator(modalViewController: menu)
        animator.dragable = true
        animator.bounces = false
        animator.behindViewAlpha = 0.4
        animator.behindViewScale = 1
        animator.transitionDuration = 0.6
        animator.direction = ZFModalTransitonDirection.Bottom

        menu.transitioningDelegate = animator
        presentViewController(menu, animated: true, completion: nil)
    }
}

// MARK: FolioPageDelegate

extension FolioReaderCenter: FolioReaderPageDelegate {
    
    func pageDidLoad(page: FolioReaderPage) {
        
        if let position = FolioReader.defaults.valueForKey(kBookId) as? NSDictionary {
            let pageNumber = position["pageNumber"]! as! Int
			let offset = isDirection(position["pageOffsetY"], position["pageOffsetX"], position["pageOffsetY"]) as? CGFloat
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
        if let fragmentID = tempFragment, let currentPage = currentPage where fragmentID != "" {
            currentPage.handleAnchor(fragmentID, avoidBeginningAnchors: true, animated: true)
            tempFragment = nil
        }

		if (readerConfig.scrollDirection == .horizontalWithVerticalContent),
			let offsetPoint = self.currentWebViewScrollPositions[page.pageNumber - 1] {
				page.webView.scrollView.setContentOffset(offsetPoint, animated: false)
		}
    }
}

// MARK: FolioReaderChapterListDelegate

extension FolioReaderCenter: FolioReaderChapterListDelegate {
    
    func chapterList(chapterList: FolioReaderChapterList, didSelectRowAtIndexPath indexPath: NSIndexPath, withTocReference reference: FRTocReference) {
        let item = findPageByResource(reference)
        
        if item < totalPages {
            let indexPath = NSIndexPath(forRow: item, inSection: 0)
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
            if let fragmentID = reference.fragmentID, let currentPage = currentPage where fragmentID != "" {
                currentPage.handleAnchor(reference.fragmentID!, avoidBeginningAnchors: true, animated: true)
            }
            tempReference = nil
        }
    }
}
