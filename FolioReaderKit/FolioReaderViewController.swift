//
//  FolioReaderViewController.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

protocol FolioReaderViewControllerDelegate {
    func readerDidAppear()
}

class FolioReaderViewController: UIViewController {

    var scrollView: UIScrollView!
    var pages: [String]!
    var totalPages: Int!
    var currentPageNumber: Int!
    var pageWidth: CGFloat!
    var pageHeight: CGFloat!
    var screenBounds: CGRect!
    var currentPage: FolioReaderPage!
    var delegate: FolioReaderViewControllerDelegate!
    
    // MARK: - View life cicle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pages = ["Page 1", "Page 2", "Page 3"]
        
        screenBounds = UIScreen.mainScreen().bounds
        setPageSize(UIApplication.sharedApplication().statusBarOrientation)
        totalPages = pages.count
        
        // ScroolView
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        scrollView.pagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        for (index, page) in enumerate(pages) {
            let bookPage  = FolioReaderPage(frame: frameForPage(index+1))
            bookPage.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            scrollView.addSubview(bookPage)
        }
        
        scrollView.contentSize = CGSizeMake(pageWidth, pageHeight * CGFloat(totalPages))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        delegate.readerDidAppear()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - StatusBar
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Device rotation
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        currentPageNumber = Int(scrollView.contentOffset.y / pageHeight)+1;
        
        for (index, page) in enumerate(self.scrollView.subviews) {
            if page is FolioReaderPage {
                var page = (page as! FolioReaderPage)
                
                if currentPageNumber != index+1 {
                    page.hidden = true
                }
            }
        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        setPageSize(UIApplication.sharedApplication().statusBarOrientation)
        scrollView.contentSize = CGSizeMake(pageWidth, pageHeight * CGFloat(totalPages))
        
        for (index, page) in enumerate(self.scrollView.subviews) {
            if page is FolioReaderPage {
                var page = (page as! FolioReaderPage)
                let pageNumber = index+1
                
                page.frame = frameForPage(pageNumber)
                page.hidden = false
            
                if currentPageNumber == pageNumber {
                    currentPage = page
                }
            }
        }
        scrollView.scrollRectToVisible(frameForPage(currentPageNumber), animated: false)
    }
    
    // MARK: - Page
    
    func setPageSize(orientation: UIInterfaceOrientation) {
        pageWidth = orientation.isLandscape ? screenBounds.size.height : screenBounds.size.width;
        pageHeight = orientation.isLandscape ? screenBounds.size.width : screenBounds.size.height;
    }
    
    func frameForPage(page: Int) -> CGRect {
        return CGRectMake(0, pageHeight * CGFloat(page - 1), pageWidth, pageHeight);
    }
}
