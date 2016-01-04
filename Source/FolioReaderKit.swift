//
//  FolioReaderKit.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Internal constants for devices

internal let isPad = UIDevice.currentDevice().userInterfaceIdiom == .Pad
internal let isPhone = UIDevice.currentDevice().userInterfaceIdiom == .Phone
internal let isPhone4 = (UIScreen.mainScreen().bounds.size.height == 480)
internal let isPhone5 = (UIScreen.mainScreen().bounds.size.height == 568)
internal let isPhone6P = UIDevice.currentDevice().userInterfaceIdiom == .Phone && UIScreen.mainScreen().bounds.size.height == 736
internal let isSmallPhone = isPhone4 || isPhone5
internal let isLargePhone = isPhone6P

// MARK: - Internal constants

internal let kApplicationDocumentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
internal let kCurrentFontFamily = "kCurrentFontFamily"
internal let kCurrentFontSize = "kCurrentFontSize"
internal let kNightMode = "kNightMode"
internal let kHighlightRange = 30
internal var kBookId: String!

/**
*  Main Library class with some useful constants and methods
*/
public class FolioReader {
    private init() {}
    
    static let sharedInstance = FolioReader()
    static let defaults = NSUserDefaults.standardUserDefaults()
    var readerCenter: FolioReaderCenter!
    var readerSidePanel: FolioReaderSidePanel!
    var readerContainer: FolioReaderContainer!
    var readerAudioPlayer: FolioReaderAudioPlayer!
    var isReaderOpen = false
    var isReaderReady = false
    
    var nightMode: Bool {
        get { return FolioReader.defaults.valueForKey(kNightMode) as! Bool }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kNightMode)
            FolioReader.defaults.synchronize()
        }
    }
    var currentFontName: Int {
        get { return FolioReader.defaults.valueForKey(kCurrentFontFamily) as! Int }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kCurrentFontFamily)
            FolioReader.defaults.synchronize()
        }
    }
    
    var currentFontSize: Int {
        get { return FolioReader.defaults.valueForKey(kCurrentFontSize) as! Int }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kCurrentFontSize)
            FolioReader.defaults.synchronize()
        }
    }
    
    // MARK: - Present Folio Reader
    
    /**
    Present a Folio Reader for a Parent View Controller.
    */
    public class func presentReader(parentViewController parentViewController: UIViewController, withEpubPath epubPath: String, andConfig config: FolioReaderConfig, animated: Bool = true) {
        let reader = FolioReaderContainer(config: config, epubPath: epubPath)
        FolioReader.sharedInstance.readerContainer = reader
        parentViewController.presentViewController(reader, animated: animated, completion: nil)
    }
    
    /**
    Present a Folio Reader for a Parent View Controller.
    */
    public class func presentReader(parentViewController parentViewController: UIViewController, andConfig config: FolioReaderConfig, animated: Bool = true) {
        let reader = FolioReaderContainer(config: config)
        FolioReader.sharedInstance.readerContainer = reader
        parentViewController.presentViewController(reader, animated: animated, completion: nil)
    }
    
    // MARK: - Application State
    
    /**
    Called when the application will resign active
    */
    public class func applicationWillResignActive() {
        saveReaderState()
    }
    
    /**
    Called when the application will terminate
    */
    public class func applicationWillTerminate() {
        saveReaderState()
    }
    
    /**
    Save Reader state, book, page and scroll are saved
    */
    class func saveReaderState() {
        if FolioReader.sharedInstance.isReaderOpen {
            if let currentPage = FolioReader.sharedInstance.readerCenter.currentPage {
                let position = [
                    "pageNumber": currentPageNumber,
                    "pageOffset": currentPage.webView.scrollView.contentOffset.y
                ]
                
                FolioReader.defaults.setObject(position, forKey: kBookId)
                FolioReader.defaults.synchronize()
            }
        }
    }
}

// MARK: - Extensions

extension NSBundle {
    class func frameworkBundle() -> NSBundle {
        return NSBundle(forClass: FolioReader.self)
    }
}

extension UIColor {
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = rgba.startIndex.advancedBy(1)
            let hex     = rgba.substringFromIndex(index)
            let scanner = NSScanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexLongLong(&hexValue) {
                switch (hex.characters.count) {
                case 3:
                    red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                    green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                    blue  = CGFloat(hexValue & 0x00F)              / 15.0
                    break
                case 4:
                    red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                    green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                    blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                    alpha = CGFloat(hexValue & 0x000F)             / 15.0
                    break
                case 6:
                    red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                    green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                    blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
                    break
                case 8:
                    red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                    green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                    blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                    alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
                    break
                default:
                    print("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8", terminator: "")
                    break
                }
            } else {
                print("Scan hex error")
            }
        } else {
            print("Invalid RGB string, missing '#' as prefix", terminator: "")
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

extension String {
    /// Truncates the string to length number of characters and
    /// appends optional trailing string if longer
    func truncate(length: Int, trailing: String? = nil) -> String {
        if self.characters.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length)) + (trailing ?? "")
        } else {
            return self
        }
    }
    
    func stripHtml() -> String {
        return self.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch)
    }
    
    func stripLineBreaks() -> String {
        return self.stringByReplacingOccurrencesOfString("\n", withString: "", options: .RegularExpressionSearch)
    }
}

extension UIImage {
    convenience init?(readerImageNamed: String) {
        let traits = UITraitCollection(displayScale: UIScreen.mainScreen().scale)
        self.init(named: readerImageNamed, inBundle: NSBundle.frameworkBundle(), compatibleWithTraitCollection: traits)
    }
    
    func imageTintColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        tintColor.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    class func imageWithColor(color: UIColor?) -> UIImage! {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        if let color = color {
            color.setFill()
        } else {
            UIColor.whiteColor().setFill()
        }
        
        CGContextFillRect(context, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIViewController: UIGestureRecognizerDelegate {
    
    func setCloseButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(readerImageNamed: "icon-close"), style: UIBarButtonItemStyle.Plain, target: self, action:"dismiss")
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - NavigationBar
    
    func setTransparentNavigation() {
        let navBar = self.navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navBar?.hideBottomHairline()
        navBar?.translucent = true
    }
    
    func setTranslucentNavigation(translucent: Bool = true, color: UIColor, tintColor: UIColor = UIColor.whiteColor(), titleColor: UIColor = UIColor.blackColor(), andFont font: UIFont = UIFont.systemFontOfSize(17)) {
        let navBar = self.navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage.imageWithColor(color), forBarMetrics: UIBarMetrics.Default)
        navBar?.showBottomHairline()
        navBar?.translucent = translucent
        navBar?.tintColor = tintColor
        navBar?.titleTextAttributes = [NSForegroundColorAttributeName: titleColor, NSFontAttributeName: font]
    }
}

extension UINavigationController {
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return FolioReader.sharedInstance.nightMode ? .LightContent : .Default
    }
}

extension UINavigationBar {
    
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = true
    }
    
    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.hidden = false
    }
    
    private func hairlineImageViewInNavigationBar(view: UIView) -> UIImageView? {
        if view.isKindOfClass(UIImageView) && view.bounds.height <= 1.0 {
            return (view as! UIImageView)
        }
        
        let subviews = (view.subviews )
        for subview: UIView in subviews {
            if let imageView: UIImageView = hairlineImageViewInNavigationBar(subview) {
                return imageView
            }
        }
        return nil
    }
    
}