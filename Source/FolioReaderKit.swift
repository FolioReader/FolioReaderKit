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
internal let kCurrentAudioRate = "kCurrentAudioRate"
internal let kCurrentHighlightStyle = "kCurrentHighlightStyle"
internal var kCurrentMediaOverlayStyle = "kMediaOverlayStyle"
internal let kNightMode = "kNightMode"
internal let kHighlightRange = 30
internal var kBookId: String!

/**
 `0` Default  
 `1` Underline  
 `2` Text Color
*/
enum MediaOverlayStyle: Int {
    case Default
    case Underline
    case TextColor
    
    init () {
        self = .Default
    }
    
    func className() -> String {
        return "mediaOverlayStyle\(self.rawValue)"
    }
}

/**
*  Main Library class with some useful constants and methods
*/
public class FolioReader : NSObject {
    static let sharedInstance = FolioReader()
    static let defaults = NSUserDefaults.standardUserDefaults()
    weak var readerCenter: FolioReaderCenter!
    weak var readerSidePanel: FolioReaderSidePanel!
    weak var readerContainer: FolioReaderContainer!
    weak var readerAudioPlayer: FolioReaderAudioPlayer!
    var isReaderOpen = false
    var isReaderReady = false
    
    private override init() {
        let isMigrated = FolioReader.defaults.boolForKey("isMigrated")
        if !isMigrated {
            Highlight.migrateUserDataToRealm()
        }
    }
    
    var nightMode: Bool {
        get { return FolioReader.defaults.boolForKey(kNightMode) }
        set (value) {
            FolioReader.defaults.setBool(value, forKey: kNightMode)
        }
    }
    var currentFontName: Int {
        get { return FolioReader.defaults.valueForKey(kCurrentFontFamily) as! Int }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kCurrentFontFamily)
        }
    }
    
    var currentFontSize: Int {
        get { return FolioReader.defaults.valueForKey(kCurrentFontSize) as! Int }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kCurrentFontSize)
        }
    }
    
    var currentAudioRate: Int {
        get { return FolioReader.defaults.valueForKey(kCurrentAudioRate) as! Int }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kCurrentAudioRate)
        }
    }

    var currentHighlightStyle: Int {
        get { return FolioReader.defaults.valueForKey(kCurrentHighlightStyle) as! Int }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kCurrentHighlightStyle)
        }
    }
    
    var currentMediaOverlayStyle: MediaOverlayStyle {
        get { return MediaOverlayStyle(rawValue: FolioReader.defaults.valueForKey(kCurrentMediaOverlayStyle) as! Int)! }
        set (value) {
            FolioReader.defaults.setValue(value.rawValue, forKey: kCurrentMediaOverlayStyle)
        }
    }
    
    // MARK: - Get Cover Image
    
    /**
     Read Cover Image and Return an IUImage
     */
    
    public class func getCoverImage(epubPath: String) -> UIImage? {
        return FREpubParser().parseCoverImage(epubPath)
    }

    // MARK: - Present Folio Reader
    
    /**
    Present a Folio Reader for a Parent View Controller.
    */
    public class func presentReader(parentViewController parentViewController: UIViewController, withEpubPath epubPath: String, andConfig config: FolioReaderConfig, shouldRemoveEpub: Bool = true, animated: Bool = true) {
        let reader = FolioReaderContainer(config: config, epubPath: epubPath, removeEpub: shouldRemoveEpub)
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
                    "pageOffsetX": currentPage.webView.scrollView.contentOffset.x,
                    "pageOffsetY": currentPage.webView.scrollView.contentOffset.y
                ]
                
                FolioReader.defaults.setObject(position, forKey: kBookId)
            }
        }
    }
}

// MARK: - Global Functions

func isNight<T> (f: T, _ l: T) -> T {
    return FolioReader.sharedInstance.nightMode ? f : l
}

// MARK: - Scroll Direction Functions

func isVerticalDirection<T> (f: T, _ l: T) -> T {
    return readerConfig.scrollDirection == .vertical ? f : l
}

extension UICollectionViewScrollDirection {
    static func direction() -> UICollectionViewScrollDirection {
        return isVerticalDirection(.Vertical, .Horizontal)
    }
}

extension UICollectionViewScrollPosition {
    static func direction() -> UICollectionViewScrollPosition {
        return isVerticalDirection(.Top, .Left)
    }
}

extension CGPoint {
    func forDirection() -> CGFloat {
        return isVerticalDirection(self.y, self.x)
    }
}

extension CGSize {
    func forDirection() -> CGFloat {
        return isVerticalDirection(self.height, self.width)
    }
}

extension ScrollDirection {
    static func negative() -> ScrollDirection {
        return isVerticalDirection(.Down, .Right)
    }
    
    static func positive() -> ScrollDirection {
        return isVerticalDirection(.Up, .Left)
    }
}


// MARK: - Extensions

internal extension NSBundle {
    class func frameworkBundle() -> NSBundle {
        return NSBundle(forClass: FolioReader.self)
    }
}

internal extension UIColor {
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

    /**
     Hex string of a UIColor instance.

     - parameter rgba: Whether the alpha should be included.
     */
    // from: https://github.com/yeahdongcn/UIColor-Hex-Swift
    func hexString(includeAlpha: Bool) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)

        if (includeAlpha) {
            return String(format: "#%02X%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255), Int(a * 255))
        } else {
            return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
        }
    }

    // MARK: - color shades
    // https://gist.github.com/mbigatti/c6be210a6bbc0ff25972

    func highlightColor() -> UIColor {

        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0

        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: 0.30, brightness: 1, alpha: alpha)
        } else {
            return self;
        }

    }

    /**
     Returns a lighter color by the provided percentage

     :param: lighting percent percentage
     :returns: lighter UIColor
     */
    func lighterColor(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(CGFloat(1 + percent));
    }

    /**
     Returns a darker color by the provided percentage

     :param: darking percent percentage
     :returns: darker UIColor
     */
    func darkerColor(percent : Double) -> UIColor {
        return colorWithBrightnessFactor(CGFloat(1 - percent));
    }

    /**
     Return a modified color using the brightness factor provided

     :param: factor brightness factor
     :returns: modified color
     */
    func colorWithBrightnessFactor(factor: CGFloat) -> UIColor {
        var hue : CGFloat = 0
        var saturation : CGFloat = 0
        var brightness : CGFloat = 0
        var alpha : CGFloat = 0

        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(hue: hue, saturation: saturation, brightness: brightness * factor, alpha: alpha)
        } else {
            return self;
        }
    }
}

internal extension String {
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

    /**
     Converts a clock time such as `0:05:01.2` to seconds (`Double`)

     Looks for media overlay clock formats as specified [here][1]

     - Note: this may not be the  most efficient way of doing this. It can be improved later on.

     - Returns: seconds as `Double`

     [1]: http://www.idpf.org/epub/301/spec/epub-mediaoverlays.html#app-clock-examples
    */
    func clockTimeToSeconds() -> Double {

        let val = self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

        if( val.isEmpty ){ return 0 }

        let formats = [
            "HH:mm:ss.SSS"  : "^\\d{1,2}:\\d{2}:\\d{2}\\.\\d{1,3}$",
            "HH:mm:ss"      : "^\\d{1,2}:\\d{2}:\\d{2}$",
            "mm:ss.SSS"     : "^\\d{1,2}:\\d{2}\\.\\d{1,3}$",
            "mm:ss"         : "^\\d{1,2}:\\d{2}$",
            "ss.SSS"         : "^\\d{1,2}\\.\\d{1,3}$",
        ]

        // search for normal duration formats such as `00:05:01.2`
        for (format, pattern) in formats {

            if val.rangeOfString(pattern, options: .RegularExpressionSearch) != nil {

                let formatter = NSDateFormatter()
                formatter.dateFormat = format
                let time = formatter.dateFromString(val)

                if( time == nil ){ return 0 }

                formatter.dateFormat = "ss.SSS"
                let seconds = (formatter.stringFromDate(time!) as NSString).doubleValue

                formatter.dateFormat = "mm"
                let minutes = (formatter.stringFromDate(time!) as NSString).doubleValue

                formatter.dateFormat = "HH"
                let hours = (formatter.stringFromDate(time!) as NSString).doubleValue

                return seconds + (minutes*60) + (hours*60*60)
            }
        }

        // if none of the more common formats match, check for other possible formats

        // 2345ms
        if val.rangeOfString("^\\d+ms$", options: .RegularExpressionSearch) != nil{
            return (val as NSString).doubleValue / 1000.0
        }

        // 7.25h
        if val.rangeOfString("^\\d+(\\.\\d+)?h$", options: .RegularExpressionSearch) != nil {
            return (val as NSString).doubleValue * 60 * 60
        }

        // 13min
        if val.rangeOfString("^\\d+(\\.\\d+)?min$", options: .RegularExpressionSearch) != nil {
            return (val as NSString).doubleValue * 60
        }

        return 0
    }

    func clockTimeToMinutesString() -> String {

        let val = clockTimeToSeconds()

        let min = floor(val / 60)
        let sec = floor(val % 60)

        return String(format: "%02.f:%02.f", min, sec)
    }

}

internal extension UIImage {
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

internal extension UIViewController {
    
    func setCloseButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(readerImageNamed: "icon-close"), style: UIBarButtonItemStyle.Plain, target: self, action:#selector(UIViewController.dismiss))
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

internal extension UINavigationBar {
    
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

internal extension Array {
    
    /**
     Return index if is safe, if not return nil
     http://stackoverflow.com/a/30593673/517707
     */
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
