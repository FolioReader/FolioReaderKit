//
//  FolioReaderViewController.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

let reuseIdentifier = "Cell"

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

protocol FolioReaderViewControllerDelegate {
    func readerDidAppear()
}

class FolioReaderViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var pages: [String]!
    var totalPages: Int!
    var currentPageNumber: Int!
    var pageWidth: CGFloat!
    var pageHeight: CGFloat!
    var currentPage: FolioReaderPage!
    var delegate: FolioReaderViewControllerDelegate!
    
    private var screenBounds: CGRect!
    private var pointNow: CGPoint!
    private var scrollDirection = ScrollDirection()
    
    // MARK: - View life cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pages = ["Page", "Page", "Page", "Page", "Page", "Page"]
        
        screenBounds = UIScreen.mainScreen().bounds
        setPageSize(UIApplication.sharedApplication().statusBarOrientation)
        totalPages = pages.count
        
        // Layout
        var layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsZero
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = UICollectionViewScrollDirection.Vertical;
        
        // CollectionView
        collectionView = UICollectionView(frame: screenBounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.pagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(collectionView)
        
        // Register cell classes
        self.collectionView!.registerClass(FolioReaderPage.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        setCurrentPageNumber()
        
//        delegate.readerDidAppear()
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
        
        // Configure the cell
        let demoStr = "<?xml version=\"1.0\" encoding=\"utf-8\"?> <html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\"> <head> <meta name=\"viewport\" content=\"width=device-width, initial-scale=1, user-scalable=no\"> <meta name=\"generator\" content= \"HTML Tidy for FreeBSD (vers 7 December 2008), see www.w3.org\" /> <title>Romeo and Juliet</title> <style>* { padding: 0; margin: 0; outline: none; list-style: none; border: 0 none; } /* Typography & Colors */ body { font: 19px/1.6em helvetica, sans-serif; padding: 40px 30px; color: #383737; } .content-title { font: 35px/1.3em helvetica, sans-serif; margin-bottom: 35px; color: black; } .author { font: 20px/1.5em helvetica, sans-serif; margin-bottom: 25px; color: lightgray; } b, strong { font-family: helvetica, sans-serif; } i, em { font-family: helvetica, sans-serif; } a { color: #004270; } .wp-caption p.wp-caption-text { color: #888; margin: 0 5px; font-size: 14px; } .gallery-caption { font-size: 14px; line-height: 1.3; } /* Layout */ .alignleft { float: left; } img.alignleft { padding: 5px; margin-right: 20px; display: inline; background: #f1f1f1; } p { padding-top: 0.8em; padding-bottom: 0.6em; } .gallery-icon { margin: 10px 0; } .wp-caption.alignleft { margin: 1em 20px 0 0; } .wp-caption { background: #f1f1f1; line-height: 18px; margin-bottom: 20px; max-width: 100% !important; padding-top: 5px; text-align: center; }</style> <meta http-equiv=\"Content-Type\" content= \"application/xhtml+xml; charset=utf-8\" /> </head> <body> <div class=\"body\"> <div id=\"chapter_3521\" class=\"chapter\"> <h2><span class=\"chapterHeader\"><span class= \"translation\">Chapter</span> <span class= \"count\">\(indexPath.row+1)</span></span></h2> <p>&#160;</p> <div class=\"text\"> <p>In the evening Andrew and Pierre got into the open carriage and drove to Bald Hills. Prince Andrew, glancing at Pierre, broke the silence now and then with remarks which showed that he was in a good temper.</p> <p>Pointing to the fields, he spoke of the improvements he was making in his husbandry.</p> <p>Pierre remained gloomily silent, answering in monosyllables and apparently immersed in his own thoughts.</p> <p>He was thinking that Prince Andrew was unhappy, had gone astray, did not see the true light, and that he, Pierre, ought to aid, enlighten, and raise him. But as soon as he thought of what he should say, he felt that Prince Andrew with one word, one argument, would upset all his teaching, and he shrank from beginning, afraid of exposing to possible ridicule what to him was precious and sacred.</p> <p>\"No, but why do you think so?\" Pierre suddenly began, lowering his head and looking like a bull about to charge, \"why do you think so? You should not think so.\"</p> </div> </div> </div> </body> </html>"
        
        cell.loadHTMLString(demoStr)
        
//        if scrollDirection == .Down {
//            let bottomOffset = CGPointMake(0, cell.webView.scrollView.contentSize.height - cell.webView.scrollView.bounds.height)
//            cell.webView.scrollView.setContentOffset(bottomOffset, animated: false)
//        }
//        println(scrollDirection)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(pageWidth, pageHeight)
    }
    
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    // MARK: - StatusBar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Device rotation
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        setPageSize(toInterfaceOrientation)
        setCurrentPageNumber()
        
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.collectionView.contentSize = CGSizeMake(self.pageWidth, self.pageHeight * CGFloat(self.totalPages))
            self.collectionView.setContentOffset(self.frameForPage(self.currentPageNumber).origin, animated: false)
            self.collectionView.collectionViewLayout.invalidateLayout()
        })
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if currentPageNumber+1 >= totalPages {
            UIView.animateWithDuration(duration, animations: { () -> Void in
                self.collectionView.setContentOffset(self.frameForPage(self.currentPageNumber).origin, animated: false)
            })
        }
    }
    
    // MARK: - Page
    
    func setPageSize(orientation: UIInterfaceOrientation) {
        pageWidth = orientation.isPortrait ? screenBounds.size.width : screenBounds.size.height;
        pageHeight = orientation.isPortrait ? screenBounds.size.height : screenBounds.size.width;
    }
    
    func setCurrentPageNumber() {
        let indexPath = self.collectionView.indexPathsForVisibleItems().first as! NSIndexPath
        currentPageNumber = indexPath.row+1;
    }
    
    func frameForPage(page: Int) -> CGRect {
        return CGRectMake(0, pageHeight * CGFloat(page-1), pageWidth, pageHeight);
    }
    
    // MARK: - ScrollView Delegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//        if scrollView is UICollectionView {
            pointNow = scrollView.contentOffset
//        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < pointNow.y {
            scrollDirection = .Down
        } else if scrollView.contentOffset.y > pointNow.y {
            scrollDirection = .Up
        }
        
        if scrollView is UICollectionView {
//            println("class: \(scrollView.classForCoder) content: \(scrollView.contentSize.height) contentOffset: \(scrollView.contentOffset.y)")
        } else {
            let contentHeight = scrollView.contentSize.height - scrollView.bounds.height
            if scrollView.contentOffset.y >= contentHeight {
                return
            }
            
//            println("class: \(scrollView.classForCoder) content: \(scrollView.contentSize.height - pageHeight) contentOffset: \(scrollView.contentOffset.y)")
        }
    }
}
