//
//  FolioReaderCenter.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"
var isScrolling = false
var scrollDirection = ScrollDirection()
var pageWidth: CGFloat!
var pageHeight: CGFloat!
var previousPageNumber: Int!
var currentPageNumber: Int!
var nextPageNumber: Int!

enum ScrollDirection: Int {
    case None
    case Right
    case Left
    case Up
    case Down
    
    init() {
        self = .None
    }
}

class FolioReaderCenter: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FolioPageDelegate, FolioReaderContainerDelegate {
    
    var collectionView: UICollectionView!
    var pages: [String]!
    var totalPages: Int!
    var currentPage: FolioReaderPage!
    var folioReaderContainer: FolioReaderContainer!
    
    private var screenBounds: CGRect!
    private var pointNow = CGPointZero
    
    // MARK: - View life cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenBounds = UIScreen.mainScreen().bounds
        setPageSize(UIApplication.sharedApplication().statusBarOrientation)
        
        // Layout
        var layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsZero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical
        
        // CollectionView
        collectionView = UICollectionView(frame: screenBounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.pagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
        self.view.addSubview(collectionView)
        
        // Register cell classes
        self.collectionView!.registerClass(FolioReaderPage.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Delegate container
        folioReaderContainer.delegate = self
        
        totalPages = book.spine.spineReferences.count
    }
    
    func reloadData() {
        totalPages = book.spine.spineReferences.count
        collectionView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setCurrentPage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        cell.webView.scrollView.delegate = self
        cell.delegate = self
        
        // Configure the cell
        let resource = book.spine.spineReferences[indexPath.row].resource
        var html = String(contentsOfFile: resource.fullHref, encoding: NSUTF8StringEncoding, error: nil)
        
        // Inject CSS
        let cssFilePath = NSBundle(forClass: self.dynamicType).pathForResource("style", ofType: "css")
        let cssTag = "<link rel=\"stylesheet\" type=\"text/css\" href=\"\(cssFilePath!)\">"
        
        let toInject = "\n\(cssTag) \n</head>"
        html = html?.stringByReplacingOccurrencesOfString("</head>", withString: toInject)
        
        cell.loadHTMLString(html, baseURL: NSURL(fileURLWithPath: resource.fullHref.stringByDeletingLastPathComponent))
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(pageWidth, pageHeight)
    }
    
    // MARK: - Status Bar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Device rotation
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        setPageSize(toInterfaceOrientation)
        setCurrentPage()
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.collectionView.contentSize = CGSizeMake(pageWidth, pageHeight * CGFloat(self.totalPages))
            self.collectionView.setContentOffset(self.frameForPage(currentPageNumber).origin, animated: false)
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if currentPageNumber+1 >= totalPages {
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.collectionView.setContentOffset(self.frameForPage(currentPageNumber).origin, animated: false)
            })
        }
    }
    
    // MARK: - Page
    
    func setPageSize(orientation: UIInterfaceOrientation) {
        pageWidth = orientation.isPortrait ? screenBounds.size.width : screenBounds.size.height
        pageHeight = orientation.isPortrait ? screenBounds.size.height : screenBounds.size.width
    }
    
    func setCurrentPage() {
        let currentIndexPath = getCurrentIndexPath()
        if currentIndexPath != NSIndexPath(forRow: 0, inSection: 0) {
            currentPage = collectionView.cellForItemAtIndexPath(currentIndexPath) as! FolioReaderPage
        }
        
        previousPageNumber = currentIndexPath.row == 0 ? currentIndexPath.row : currentIndexPath.row
        currentPageNumber = currentIndexPath.row+1
        nextPageNumber = currentPageNumber+1 <= totalPages ? currentPageNumber+1 : currentPageNumber
    }
    
    func getCurrentIndexPath() -> NSIndexPath {
        let indexPaths = self.collectionView.indexPathsForVisibleItems()
        var indexPath = NSIndexPath()
        
        if indexPaths.count > 1 {
            let first = indexPaths.first as! NSIndexPath
            let last = indexPaths.last as! NSIndexPath
            
            switch scrollDirection {
            case .Up:
                if first.compare(last) == NSComparisonResult.OrderedAscending {
                    indexPath = last
                } else {
                    indexPath = first
                }
            default:
                if first.compare(last) == NSComparisonResult.OrderedAscending {
                    indexPath = first
                } else {
                    indexPath = last
                }
            }
        } else {
            indexPath = indexPaths.first != nil ? indexPaths.first as! NSIndexPath : NSIndexPath(forRow: 0, inSection: 0)
        }
        
        return indexPath
    }
    
    func frameForPage(page: Int) -> CGRect {
        return CGRectMake(0, pageHeight * CGFloat(page-1), pageWidth, pageHeight)
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        isScrolling = true
        
//        if scrollView is UICollectionView {
            pointNow = scrollView.contentOffset
//        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        if scrollView is UICollectionView {
            scrollDirection = scrollView.contentOffset.y < pointNow.y ? .Down : .Up
//        }
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
//        println("decelerate")
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        isScrolling = false
        
        if scrollView is UICollectionView {
            setCurrentPage()
            println("Page: \(currentPageNumber)")
        }
    }
    
    // MARK: - Folio Page Delegate
    
    func pageDidLoad(page: FolioReaderPage) {
//        println("Page did load")
    }
    
    // MARK: - Container delegate
    
    func container(didExpandLeftPanel sidePanel: FolioReaderSidePanel) {
        collectionView.scrollEnabled = false
        currentPage.webView.scrollView.scrollEnabled = false
    }
    
    func container(didCollapseLeftPanel sidePanel: FolioReaderSidePanel) {
        collectionView.scrollEnabled = true
        currentPage.webView.scrollView.scrollEnabled = true
    }
    
    func container(sidePanel: FolioReaderSidePanel, didSelectRowAtIndexPath indexPath: NSIndexPath, withTocReference reference: FRTocReference) {
        let item = findPageByResource(reference)
        let indexPath = NSIndexPath(forRow: item, inSection: 0)
        
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Top, animated: false)
        
        let page = collectionView.cellForItemAtIndexPath(getCurrentIndexPath()) as! FolioReaderPage
        if reference.fragmentID != "" {
            page.webView.stringByEvaluatingJavaScriptFromString("window.location.hash='#\(reference.fragmentID)'")
        }
    }
    
    func findPageByResource(reference: FRTocReference) -> Int {
        var count = 0
        for item in book.spine.spineReferences {
            if item.resource.href == reference.resource.href {
                return count
            }
            count++
        }
        return count
    }
    
}
