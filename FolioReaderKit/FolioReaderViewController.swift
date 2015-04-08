//
//  FolioReaderViewController.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderViewController: UIViewController {

    var scrollView: UIScrollView!
    var pages: [String]!
    var totalPages: Int!
    var currentPageNumber: Int!
    var pageWidth: CGFloat!
    var pageHeight: CGFloat!
    var screenBounds: CGRect!
    
    var currentPage: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let pages = ["Page 1", "Page 2", "Page 3", "Page 4", "Page 5"]
        
        screenBounds = UIScreen.mainScreen().bounds
        setPageSize(self.interfaceOrientation)
        totalPages = pages.count
        
        scrollView = UIScrollView(frame: self.view.bounds)
        scrollView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
//        scrollView.backgroundColor = UIColor.blueColor()
        scrollView.pagingEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        
        self.view.addSubview(scrollView)
        
        for (index, page) in enumerate(pages) {
            var viewRect = self.view.frame
            viewRect.origin.y = self.view.frame.size.height * CGFloat(index)
            
            let bookPage = UIView(frame: viewRect)
            bookPage.autoresizingMask = .FlexibleWidth | .FlexibleHeight
            bookPage.backgroundColor = getRandomColor()
            scrollView.addSubview(bookPage)
        }
        
        scrollView.contentSize = CGSizeMake(pageWidth, pageHeight * CGFloat(totalPages))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func getRandomColor() -> UIColor {
        var randomRed:CGFloat = CGFloat(drand48())
        var randomGreen:CGFloat = CGFloat(drand48())
        var randomBlue:CGFloat = CGFloat(drand48())        
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        currentPageNumber = Int(scrollView.contentOffset.y / pageHeight)+1;
        
        for (index, page) in enumerate(self.scrollView.subviews) {
            var page = (page as UIView)
            
            if currentPageNumber != index+1 {
                page.hidden = true
            }
        }
    
//        scrollView.contentSize = CGSizeMake(pageWidth, pageHeight * CGFloat(totalPages))
        
//        for (index, page) in enumerate(scrollView.subviews) {
//            var viewRect = (page as UIView).frame
//            viewRect.origin.y = pageHeight * CGFloat(index)
//            (page as UIView).frame = viewRect
//        }
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        setPageSize(self.interfaceOrientation)
        scrollView.contentSize = CGSizeMake(pageWidth, pageHeight * CGFloat(totalPages))
        
//        UIView.animateWithDuration(0.1, animations: { () -> Void in
            for (index, page) in enumerate(self.scrollView.subviews) {
                var page = (page as UIView)
                
                if currentPageNumber == index+1 {
                    currentPage = page
                    println(currentPage.backgroundColor)
                }
                page.frame = self.frameForPage(index+1)
                
                page.hidden = false
            }
//        })

//        scrollView.bringSubviewToFront(currentPage)
        scrollView.scrollRectToVisible(frameForPage(currentPageNumber), animated: false)
    }
    
    func setPageSize(orientation: UIInterfaceOrientation) {
        let isLandscape = (orientation == .LandscapeLeft || orientation == .LandscapeRight)
        pageWidth = isLandscape ? screenBounds.size.height : screenBounds.size.width;
        pageHeight = isLandscape ? screenBounds.size.width : screenBounds.size.height;
    }
    
    func frameForPage(page: Int) -> CGRect {
        return CGRectMake(0, pageHeight * CGFloat(page - 1), pageWidth, pageHeight);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
