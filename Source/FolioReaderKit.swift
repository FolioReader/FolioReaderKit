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

// MARK: - Internal constants

internal let kApplicationDocumentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] 
internal let kCurrentFontFamily = "com.folioreader.kCurrentFontFamily"
internal let kCurrentFontSize = "com.folioreader.kCurrentFontSize"
internal let kCurrentAudioRate = "com.folioreader.kCurrentAudioRate"
internal let kCurrentHighlightStyle = "com.folioreader.kCurrentHighlightStyle"
internal var kCurrentMediaOverlayStyle = "com.folioreader.kMediaOverlayStyle"
internal var kCurrentScrollDirection = "com.folioreader.kCurrentScrollDirection"
internal let kNightMode = "com.folioreader.kNightMode"
internal let kCurrentTOCMenu = "com.folioreader.kCurrentTOCMenu"
internal let kMigratedToRealm = "com.folioreader.kMigratedToRealm"
internal let kHighlightRange = 30
internal var kBookId: String!

/**
 Defines the media overlay and TTS selection
 
 - Default:   The background is colored
 - Underline: The underlined is colored
 - TextColor: The text is colored
 */
enum MediaOverlayStyle: Int {
    case Default
    case Underline
    case TextColor
    
    init() {
        self = .Default
    }
    
    func className() -> String {
        return "mediaOverlayStyle\(self.rawValue)"
    }
}

/// FolioReader actions delegate
@objc public protocol FolioReaderDelegate: class {
    
    /**
     Did finished loading book.
     
     - parameter folioReader: The FolioReader instance
     - parameter book:        The Book instance
     */
    optional func folioReader(folioReader: FolioReader, didFinishedLoading book: FRBook)
    
    /**
     Called when reader did closed.
     */
    optional func folioReaderDidClosed()
}

/**
 Main Library class with some useful constants and methods
 */
public class FolioReader: NSObject {
    public static let sharedInstance = FolioReader()
    static let defaults = NSUserDefaults.standardUserDefaults()
    public weak var delegate: FolioReaderDelegate?
    public weak var readerCenter: FolioReaderCenter?
    public weak var readerContainer: FolioReaderContainer!
    public weak var readerAudioPlayer: FolioReaderAudioPlayer?
    
    private override init() {
        let isMigrated = FolioReader.defaults.boolForKey(kMigratedToRealm)
        if !isMigrated {
            Highlight.migrateUserDataToRealm()
        }
    }
    
    /// Check if reader is open
    static var isReaderOpen = false
    
    /// Check if reader is open and ready
    static var isReaderReady = false
    
    /// Check if layout needs to change to fit Right To Left
    static var needsRTLChange: Bool {
        return book.spine.isRtl && readerConfig.scrollDirection == .horizontal
    }
    
    /// Check if current theme is Night mode
    public static var nightMode: Bool {
        get { return FolioReader.defaults.boolForKey(kNightMode) }
        set (value) {
            FolioReader.defaults.setBool(value, forKey: kNightMode)
			FolioReader.defaults.synchronize()

			if let readerCenter = FolioReader.sharedInstance.readerCenter {
				UIView.animateWithDuration(0.6, animations: {
					readerCenter.currentPage?.webView.js("nightMode(\(nightMode))")
					readerCenter.pageIndicatorView?.reloadColors()
					readerCenter.configureNavBar()
					readerCenter.scrollScrubber?.reloadColors()
					readerCenter.collectionView.backgroundColor = (nightMode ? readerConfig.nightModeBackground : UIColor.whiteColor())
					}, completion: { (finished: Bool) in
						NSNotificationCenter.defaultCenter().postNotificationName("needRefreshPageMode", object: nil)
					})
			}
        }
    }

    /// Check current font name
    public static var currentFont: FolioReaderFont {
		get { return FolioReaderFont(rawValue: FolioReader.defaults.valueForKey(kCurrentFontFamily) as! Int)! }
        set (font) {
            FolioReader.defaults.setValue(font.rawValue, forKey: kCurrentFontFamily)

			FolioReader.sharedInstance.readerCenter?.currentPage?.webView.js("setFontName('\(font.cssIdentifier)')")
        }
    }
    
    /// Check current font size
    public static var currentFontSize: FolioReaderFontSize {
		get { return FolioReaderFontSize(rawValue: FolioReader.defaults.valueForKey(kCurrentFontSize) as! Int)! }
        set (value) {
            FolioReader.defaults.setValue(value.rawValue, forKey: kCurrentFontSize)

			if let _currentPage = FolioReader.sharedInstance.readerCenter?.currentPage {
				_currentPage.webView.js("setFontSize('\(currentFontSize.cssIdentifier)')")
			}
        }
    }

    /// Check current audio rate, the speed of speech voice
    static var currentAudioRate: Int {
        get { return FolioReader.defaults.valueForKey(kCurrentAudioRate) as! Int }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kCurrentAudioRate)
        }
    }

    /// Check the current highlight style
    static var currentHighlightStyle: Int {
        get { return FolioReader.defaults.valueForKey(kCurrentHighlightStyle) as! Int }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kCurrentHighlightStyle)
        }
    }
    
    /// Check the current Media Overlay or TTS style
    static var currentMediaOverlayStyle: MediaOverlayStyle {
        get { return MediaOverlayStyle(rawValue: FolioReader.defaults.valueForKey(kCurrentMediaOverlayStyle) as! Int)! }
        set (value) {
            FolioReader.defaults.setValue(value.rawValue, forKey: kCurrentMediaOverlayStyle)
        }
    }
    
    /// Check the current scroll direction
    public static var currentScrollDirection: Int {
        get { return FolioReader.defaults.valueForKey(kCurrentScrollDirection) as! Int }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kCurrentScrollDirection)

			if let _readerCenter = FolioReader.sharedInstance.readerCenter  {
				let direction = FolioReaderScrollDirection(rawValue: currentScrollDirection) ?? .vertical
				_readerCenter.setScrollDirection(direction)
			}
        }
    }

    // MARK: - Get Cover Image
    
    /**
     Read Cover Image and Return an `UIImage`
     */
    public class func getCoverImage(epubPath: String) -> UIImage? {
        return FREpubParser().parseCoverImage(epubPath)
    }

    // MARK: - Present Folio Reader
    
    /**
     Present a Folio Reader for a Parent View Controller.
     */
    public class func presentReader(parentViewController parentViewController: UIViewController, withEpubPath epubPath: String, andConfig config: FolioReaderConfig, shouldRemoveEpub: Bool = true, animated: Bool = true) {
        let reader = FolioReaderContainer(withConfig: config, epubPath: epubPath, removeEpub: shouldRemoveEpub)
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
    public class func saveReaderState() {
        guard FolioReader.isReaderOpen else { return }
        
        if let currentPage = FolioReader.sharedInstance.readerCenter?.currentPage {
            let position = [
                "pageNumber": currentPageNumber,
                "pageOffsetX": currentPage.webView.scrollView.contentOffset.x,
                "pageOffsetY": currentPage.webView.scrollView.contentOffset.y
            ]
            
            FolioReader.defaults.setObject(position, forKey: kBookId)
        }
    }
    
    /**
     Closes and save the reader current instance
     */
    public class func close() {
        FolioReader.saveReaderState()
        FolioReader.isReaderOpen = false
        FolioReader.isReaderReady = false
        FolioReader.sharedInstance.readerAudioPlayer?.stop(immediate: true)
        FolioReader.defaults.setInteger(0, forKey: kCurrentTOCMenu)
        FolioReader.sharedInstance.delegate?.folioReaderDidClosed?()
    }
}

// MARK: - Global Functions

func isNight<T> (f: T, _ l: T) -> T {
    return FolioReader.nightMode ? f : l
}

// MARK: - Scroll Direction Functions

/**
 Simplify attibution of values based on direction, basically is to avoid too much usage of `switch`,
 `if` and `else` statements to check. So basically this is like a shorthand version of the `switch` verification.
 
 For example:
 ```
 let pageOffsetPoint = isDirection(CGPoint(x: 0, y: pageOffset), CGPoint(x: pageOffset, y: 0), CGPoint(x: 0, y: pageOffset))
 ```
 
 As usually the `vertical` direction and `horizontalContentVertical` has similar statements you can basically hide the last
 value and it will assume the value from `vertical` as fallback.
 ```
 let pageOffsetPoint = isDirection(CGPoint(x: 0, y: pageOffset), CGPoint(x: pageOffset, y: 0))
 ```
 
 - parameter vertical:                  Value for `vertical` direction
 - parameter horizontal:                Value for `horizontal` direction
 - parameter horizontalContentVertical: Value for `horizontalWithVerticalContent` direction, if nil will fallback to `vertical` value
 
 - returns: The right value based on direction.
 */
func isDirection<T> (vertical: T, _ horizontal: T, _ horizontalContentVertical: T? = nil) -> T {
	switch readerConfig.scrollDirection {
	case .vertical: return vertical
	case .horizontal: return horizontal
	case .horizontalWithVerticalContent: return horizontalContentVertical ?? vertical
	}
}

extension UICollectionViewScrollDirection {
    static func direction() -> UICollectionViewScrollDirection {
        return isDirection(.Vertical, .Horizontal, .Horizontal)
    }
}

extension UICollectionViewScrollPosition {
    static func direction() -> UICollectionViewScrollPosition {
        return isDirection(.Top, .Left, .Left)
    }
}

extension CGPoint {
    func forDirection() -> CGFloat {
        return isDirection(y, x, y)
    }
}

extension CGSize {
    func forDirection() -> CGFloat {
        return isDirection(height, width, height)
    }
    
    func forReverseDirection() -> CGFloat {
        return isDirection(width, height, width)
    }
}

extension CGRect {
    func forDirection() -> CGFloat {
        return isDirection(height, width, height)
    }
}

extension ScrollDirection {
    static func negative() -> ScrollDirection {
        return isDirection(.Down, .Right, .Right)
    }
    
    static func positive() -> ScrollDirection {
        return isDirection(.Up, .Left, .Left)
    }
}

// MARK: Helpers

/**
 Delay function
 From: http://stackoverflow.com/a/24318861/517707
 
 - parameter delay:   Delay in seconds
 - parameter closure: Closure
 */
func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
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
        self.init(named: readerImageNamed, inBundle: NSBundle.frameworkBundle(), compatibleWithTraitCollection: nil)
    }
    
    /**
     Forces the image to be colored with Reader Config tintColor
     
     - returns: Returns a colored image
     */
    func ignoreSystemTint() -> UIImage {
        return self.imageTintColor(readerConfig.tintColor).imageWithRenderingMode(.AlwaysOriginal)
    }
    
    /**
     Colorize the image with a color
     
     - parameter tintColor: The input color
     - returns: Returns a colored image
     */
    func imageTintColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0)
        CGContextSetBlendMode(context, CGBlendMode.Normal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage!)
        tintColor.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /**
     Generate a image with a color
     
     - parameter color: The input color
     - returns: Returns a colored image
     */
    class func imageWithColor(color: UIColor?) -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        if let color = color {
            color.setFill()
        } else {
            UIColor.whiteColor().setFill()
        }
        
        CGContextFillRect(context!, rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    /**
     Generates a image with a `CALayer`
     
     - parameter layer: The input `CALayer`
     - returns: Return a rendered image
     */
    class func imageWithLayer(layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.opaque, 0.0)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    /**
     Generates a image from a `UIView`
     
     - parameter view: The input `UIView`
     - returns: Return a rendered image
     */
    class func imageWithView(view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
        view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: true)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

internal extension UIViewController {
    
    func setCloseButton() {
        let closeImage = UIImage(readerImageNamed: "icon-navbar-close")?.ignoreSystemTint()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage, style: .Plain, target: self, action: #selector(dismiss as Void -> Void))
    }
    
    func dismiss() {
        dismiss(nil)
    }
    
    func dismiss(completion: (() -> Void)?) {
        dispatch_async(dispatch_get_main_queue()) {
            self.dismissViewControllerAnimated(true, completion: {
                completion?()
            })
        }
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

extension UINavigationController {
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        guard let viewController = visibleViewController else { return .Default }
        return viewController.preferredStatusBarStyle()
    }
    
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        guard let viewController = visibleViewController else { return .Portrait }
        return viewController.supportedInterfaceOrientations()
    }
    
    public override func shouldAutorotate() -> Bool {
        guard let viewController = visibleViewController else { return false }
        return viewController.shouldAutorotate()
    }
}

/**
 This fixes iOS 9 crash
 http://stackoverflow.com/a/32010520/517707
 */
extension UIAlertController {
    public override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    public override func shouldAutorotate() -> Bool {
        return false
    }
}

extension Array {
    
    /**
     Return index if is safe, if not return nil
     http://stackoverflow.com/a/30593673/517707
     */
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
