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

internal let isPad = UIDevice.current.userInterfaceIdiom == .pad
internal let isPhone = UIDevice.current.userInterfaceIdiom == .phone

// MARK: - Internal constants

internal let kApplicationDocumentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
internal let kCurrentFontFamily = "com.folioreader.kCurrentFontFamily"
internal let kCurrentFontSize = "com.folioreader.kCurrentFontSize"
internal let kCurrentAudioRate = "com.folioreader.kCurrentAudioRate"
internal let kCurrentHighlightStyle = "com.folioreader.kCurrentHighlightStyle"
internal var kCurrentMediaOverlayStyle = "com.folioreader.kMediaOverlayStyle"
internal var kCurrentScrollDirection = "com.folioreader.kCurrentScrollDirection"
internal let kNightMode = "com.folioreader.kNightMode"
internal let kCurrentTOCMenu = "com.folioreader.kCurrentTOCMenu"
internal let kHighlightRange = 30
internal var kBookId: String!

/**
 Defines the media overlay and TTS selection
 
 - Default:   The background is colored
 - Underline: The underlined is colored
 - TextColor: The text is colored
 */
enum MediaOverlayStyle: Int {
    case `default`
    case underline
    case textColor
    
    init() {
        self = .default
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
    @objc optional func folioReader(_ folioReader: FolioReader, didFinishedLoading book: FRBook)
    
    /**
     Called when reader did closed.
     */
    @objc optional func folioReaderDidClosed()
}

/**
 Main Library class with some useful constants and methods
 */
open class FolioReader: NSObject {
    open static let shared = FolioReader()
    open var unzipPath: String?
    static let defaults = UserDefaults.standard
    open weak var delegate: FolioReaderDelegate?
    open weak var readerCenter: FolioReaderCenter?
    open weak var readerContainer: FolioReaderContainer!
    open weak var readerAudioPlayer: FolioReaderAudioPlayer?
    
    fileprivate override init() {}
    
    /// Check if reader is open
    static var isReaderOpen = false
    
    /// Check if reader is open and ready
    static var isReaderReady = false
    
    /// Check if layout needs to change to fit Right To Left
    static var needsRTLChange: Bool {
        return book.spine.isRtl && readerConfig.scrollDirection == .horizontal
    }
    
    /// Check if current theme is Night mode
    open static var nightMode: Bool {
        get { return FolioReader.defaults.bool(forKey: kNightMode) }
        set (value) {
            FolioReader.defaults.set(value, forKey: kNightMode)
			FolioReader.defaults.synchronize()

			if let readerCenter = FolioReader.shared.readerCenter {
				UIView.animate(withDuration: 0.6, animations: {
					_ = readerCenter.currentPage?.webView.js("nightMode(\(nightMode))")
					readerCenter.pageIndicatorView?.reloadColors()
					readerCenter.configureNavBar()
					readerCenter.scrollScrubber?.reloadColors()
					readerCenter.collectionView.backgroundColor = (nightMode ? readerConfig.nightModeBackground : UIColor.white)
					}, completion: { (finished: Bool) in
						NotificationCenter.default.post(name: Notification.Name(rawValue: "needRefreshPageMode"), object: nil)
					})
			}
        }
    }

    /// Check current font name
    open static var currentFont: FolioReaderFont {
		get { return FolioReaderFont(rawValue: FolioReader.defaults.value(forKey: kCurrentFontFamily) as! Int)! }
        set (font) {
            FolioReader.defaults.setValue(font.rawValue, forKey: kCurrentFontFamily)
			_ = FolioReader.shared.readerCenter?.currentPage?.webView.js("setFontName('\(font.cssIdentifier)')")
        }
    }
    
    /// Check current font size
    open static var currentFontSize: FolioReaderFontSize {
		get { return FolioReaderFontSize(rawValue: FolioReader.defaults.value(forKey: kCurrentFontSize) as! Int)! }
        set (value) {
            FolioReader.defaults.setValue(value.rawValue, forKey: kCurrentFontSize)

			if let _currentPage = FolioReader.shared.readerCenter?.currentPage {
				_currentPage.webView.js("setFontSize('\(currentFontSize.cssIdentifier)')")
			}
        }
    }

    /// Check current audio rate, the speed of speech voice
    static var currentAudioRate: Int {
        get { return FolioReader.defaults.value(forKey: kCurrentAudioRate) as! Int }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kCurrentAudioRate)
        }
    }

    /// Check the current highlight style
    static var currentHighlightStyle: Int {
        get { return FolioReader.defaults.value(forKey: kCurrentHighlightStyle) as! Int }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kCurrentHighlightStyle)
        }
    }
    
    /// Check the current Media Overlay or TTS style
    static var currentMediaOverlayStyle: MediaOverlayStyle {
        get { return MediaOverlayStyle(rawValue: FolioReader.defaults.value(forKey: kCurrentMediaOverlayStyle) as! Int)! }
        set (value) {
            FolioReader.defaults.setValue(value.rawValue, forKey: kCurrentMediaOverlayStyle)
        }
    }
    
    /// Check the current scroll direction
    open static var currentScrollDirection: Int {
        get { return FolioReader.defaults.value(forKey: kCurrentScrollDirection) as! Int }
        set (value) {
            FolioReader.defaults.setValue(value, forKey: kCurrentScrollDirection)

			if let _readerCenter = FolioReader.shared.readerCenter  {
				let direction = FolioReaderScrollDirection(rawValue: currentScrollDirection) ?? .defaultVertical
				_readerCenter.setScrollDirection(direction)
			}
        }
    }

    // MARK: - Get Cover Image
    
    /**
     Read Cover Image and Return an `UIImage`
     */
    open class func getCoverImage(_ epubPath: String) -> UIImage? {
        return FREpubParser().parseCoverImage(epubPath)
    }


    // MARK: - Get Title
    open class func getTitle(_ epubPath: String) -> String? {
        return FREpubParser().parseTitle(epubPath)
    }

    open class func getAuthorName(_ epubPath: String) -> String? {
        return FREpubParser().parseAuthorName(epubPath)
    }

    // MARK: - Present Folio Reader
    
    /**
     Present a Folio Reader for a Parent View Controller.
     */
    open class func presentReader(parentViewController: UIViewController, withEpubPath epubPath: String, andConfig config: FolioReaderConfig, shouldRemoveEpub: Bool = true, animated: Bool = true) {
        let reader = FolioReaderContainer(withConfig: config, epubPath: epubPath, removeEpub: shouldRemoveEpub)
        FolioReader.shared.readerContainer = reader
        parentViewController.present(reader, animated: animated, completion: nil)
    }
    
    // MARK: - Application State
    
    /**
     Called when the application will resign active
     */
    open class func applicationWillResignActive() {
        saveReaderState()
    }
    
    /**
     Called when the application will terminate
     */
    open class func applicationWillTerminate() {
        saveReaderState()
    }
    
    /**
     Save Reader state, book, page and scroll are saved
     */
    open class func saveReaderState() {
        guard FolioReader.isReaderOpen else { return }
        
        if let currentPage = FolioReader.shared.readerCenter?.currentPage {
            let position = [
                "pageNumber": currentPageNumber,
                "pageOffsetX": currentPage.webView.scrollView.contentOffset.x,
                "pageOffsetY": currentPage.webView.scrollView.contentOffset.y
            ] as [String : Any]
            
            FolioReader.defaults.set(position, forKey: kBookId)
        }
    }
    
    /**
     Closes and save the reader current instance
     */
    open class func close() {
        FolioReader.saveReaderState()
        FolioReader.isReaderOpen = false
        FolioReader.isReaderReady = false
        FolioReader.shared.readerAudioPlayer?.stop(immediate: true)
        FolioReader.defaults.set(0, forKey: kCurrentTOCMenu)
        FolioReader.shared.delegate?.folioReaderDidClosed?()
    }
}

// MARK: - Global Functions

func isNight<T> (_ f: T, _ l: T) -> T {
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
func isDirection<T> (_ vertical: T, _ horizontal: T, _ horizontalContentVertical: T? = nil) -> T {
	switch readerConfig.scrollDirection {
	case .vertical, .defaultVertical: return vertical
	case .horizontal: return horizontal
	case .horizontalWithVerticalContent: return horizontalContentVertical ?? vertical
	}
}

extension UICollectionViewScrollDirection {
    static func direction() -> UICollectionViewScrollDirection {
        return isDirection(.vertical, .horizontal, .horizontal)
    }
}

extension UICollectionViewScrollPosition {
    static func direction() -> UICollectionViewScrollPosition {
        return isDirection(.top, .left, .left)
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
        return isDirection(.down, .right, .right)
    }
    
    static func positive() -> ScrollDirection {
        return isDirection(.up, .left, .left)
    }
}

// MARK: Helpers

/**
 Delay function
 From: http://stackoverflow.com/a/24318861/517707
 
 - parameter delay:   Delay in seconds
 - parameter closure: Closure
 */
func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}


// MARK: - Extensions

internal extension Bundle {
    class func frameworkBundle() -> Bundle {
        return Bundle(for: FolioReader.self)
    }
}

internal extension UIColor {
    convenience init(rgba: String) {
        var red:   CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue:  CGFloat = 0.0
        var alpha: CGFloat = 1.0
        
        if rgba.hasPrefix("#") {
            let index   = rgba.characters.index(rgba.startIndex, offsetBy: 1)
            let hex     = rgba.substring(from: index)
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
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
    func hexString(_ includeAlpha: Bool) -> String {
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
    func lighterColor(_ percent : Double) -> UIColor {
        return colorWithBrightnessFactor(CGFloat(1 + percent));
    }

    /**
     Returns a darker color by the provided percentage

     :param: darking percent percentage
     :returns: darker UIColor
     */
    func darkerColor(_ percent : Double) -> UIColor {
        return colorWithBrightnessFactor(CGFloat(1 - percent));
    }

    /**
     Return a modified color using the brightness factor provided

     :param: factor brightness factor
     :returns: modified color
     */
    func colorWithBrightnessFactor(_ factor: CGFloat) -> UIColor {
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
    func truncate(_ length: Int, trailing: String? = nil) -> String {
        if self.characters.count > length {
            return self.substring(to: self.characters.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
        } else {
            return self
        }
    }
    
    func stripHtml() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
    }
    
    func stripLineBreaks() -> String {
        return self.replacingOccurrences(of: "\n", with: "", options: .regularExpression)
    }

    /**
     Converts a clock time such as `0:05:01.2` to seconds (`Double`)

     Looks for media overlay clock formats as specified [here][1]

     - Note: this may not be the  most efficient way of doing this. It can be improved later on.

     - Returns: seconds as `Double`

     [1]: http://www.idpf.org/epub/301/spec/epub-mediaoverlays.html#app-clock-examples
    */
    func clockTimeToSeconds() -> Double {

        let val = self.trimmingCharacters(in: CharacterSet.whitespaces)

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

            if val.range(of: pattern, options: .regularExpression) != nil {

                let formatter = DateFormatter()
                formatter.dateFormat = format
                let time = formatter.date(from: val)

                if( time == nil ){ return 0 }

                formatter.dateFormat = "ss.SSS"
                let seconds = (formatter.string(from: time!) as NSString).doubleValue

                formatter.dateFormat = "mm"
                let minutes = (formatter.string(from: time!) as NSString).doubleValue

                formatter.dateFormat = "HH"
                let hours = (formatter.string(from: time!) as NSString).doubleValue

                return seconds + (minutes*60) + (hours*60*60)
            }
        }

        // if none of the more common formats match, check for other possible formats

        // 2345ms
        if val.range(of: "^\\d+ms$", options: .regularExpression) != nil{
            return (val as NSString).doubleValue / 1000.0
        }

        // 7.25h
        if val.range(of: "^\\d+(\\.\\d+)?h$", options: .regularExpression) != nil {
            return (val as NSString).doubleValue * 60 * 60
        }

        // 13min
        if val.range(of: "^\\d+(\\.\\d+)?min$", options: .regularExpression) != nil {
            return (val as NSString).doubleValue * 60
        }

        return 0
    }

    func clockTimeToMinutesString() -> String {

        let val = clockTimeToSeconds()

        let min = floor(val / 60)
        let sec = floor(val.truncatingRemainder(dividingBy: 60))

        return String(format: "%02.f:%02.f", min, sec)
    }

}

internal extension UIImage {
    convenience init?(readerImageNamed: String) {
        self.init(named: readerImageNamed, in: Bundle.frameworkBundle(), compatibleWith: nil)
    }
    
    /**
     Forces the image to be colored with Reader Config tintColor
     
     - returns: Returns a colored image
     */
    func ignoreSystemTint() -> UIImage {
        return self.imageTintColor(readerConfig.tintColor).withRenderingMode(.alwaysOriginal)
    }
    
    /**
     Colorize the image with a color
     
     - parameter tintColor: The input color
     - returns: Returns a colored image
     */
    func imageTintColor(_ tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContext
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
        context.clip(to: rect, mask: self.cgImage!)
        tintColor.setFill()
        context.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()! as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    /**
     Generate a image with a color
     
     - parameter color: The input color
     - returns: Returns a colored image
     */
    class func imageWithColor(_ color: UIColor?) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        if let color = color {
            color.setFill()
        } else {
            UIColor.white.setFill()
        }
        
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    /**
     Generates a image with a `CALayer`
     
     - parameter layer: The input `CALayer`
     - returns: Return a rendered image
     */
    class func imageWithLayer(_ layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.isOpaque, 0.0)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    /**
     Generates a image from a `UIView`
     
     - parameter view: The input `UIView`
     - returns: Return a rendered image
     */
    class func imageWithView(_ view: UIView) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.isOpaque, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}

internal extension UIViewController {
    
    func setCloseButton() {
        let closeImage = UIImage(readerImageNamed: "icon-navbar-close")?.ignoreSystemTint()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(dismiss as (Void) -> Void))
    }
    
    func dismiss() {
        dismiss(nil)
    }
    
    func dismiss(_ completion: (() -> Void)?) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: {
                completion?()
            })
        }
    }
    
    // MARK: - NavigationBar
    
    func setTransparentNavigation() {
        let navBar = self.navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar?.hideBottomHairline()
        navBar?.isTranslucent = true
    }
    
    func setTranslucentNavigation(_ translucent: Bool = true, color: UIColor, tintColor: UIColor = UIColor.white, titleColor: UIColor = UIColor.black, andFont font: UIFont = UIFont.systemFont(ofSize: 17)) {
        let navBar = self.navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage.imageWithColor(color), for: UIBarMetrics.default)
        navBar?.showBottomHairline()
        navBar?.isTranslucent = translucent
        navBar?.tintColor = tintColor
        navBar?.titleTextAttributes = [NSForegroundColorAttributeName: titleColor, NSFontAttributeName: font]
    }
}

internal extension UINavigationBar {
    
    func hideBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.isHidden = true
    }
    
    func showBottomHairline() {
        let navigationBarImageView = hairlineImageViewInNavigationBar(self)
        navigationBarImageView!.isHidden = false
    }
    
    fileprivate func hairlineImageViewInNavigationBar(_ view: UIView) -> UIImageView? {
        if view.isKind(of: UIImageView.self) && view.bounds.height <= 1.0 {
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
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        guard let viewController = visibleViewController else { return .default }
        return viewController.preferredStatusBarStyle
    }
    
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        guard let viewController = visibleViewController else { return .portrait }
        return viewController.supportedInterfaceOrientations
    }
    
    open override var shouldAutorotate : Bool {
        guard let viewController = visibleViewController else { return false }
        return viewController.shouldAutorotate
    }
}

/**
 This fixes iOS 9 crash
 http://stackoverflow.com/a/32010520/517707
 */
extension UIAlertController {
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    open override var shouldAutorotate : Bool {
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
