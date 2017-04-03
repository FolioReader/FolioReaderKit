//
//  FolioReaderKit.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Internal constants

internal let kApplicationDocumentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] 
internal let kCurrentFontFamily = "com.folioreader.kCurrentFontFamily"
internal let kCurrentFontSize = "com.folioreader.kCurrentFontSize"
internal let kCurrentAudioRate = "com.folioreader.kCurrentAudioRate"
internal let kCurrentHighlightStyle = "com.folioreader.kCurrentHighlightStyle"
internal let kCurrentMediaOverlayStyle = "com.folioreader.kMediaOverlayStyle"
internal let kCurrentScrollDirection = "com.folioreader.kCurrentScrollDirection"
internal let kNightMode = "com.folioreader.kNightMode"
internal let kCurrentTOCMenu = "com.folioreader.kCurrentTOCMenu"
internal let kHighlightRange = 30
internal let kReuseCellIdentifier = "com.folioreader.Cell.ReuseIdentifier"

/// Defines the media overlay and TTS selection
///
/// - `default`: The background is colored
/// - underline: The underlined is colored
/// - textColor: The text is colored
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

    /// Did finished loading book.
    ///
    /// - Parameters:
    ///   - folioReader: The FolioReader instance
    ///   - book: The Book instance
    @objc optional func folioReader(_ folioReader: FolioReader, didFinishedLoading book: FRBook)

    /// Called when reader did closed.
    ///
    /// - Parameter folioReader: The FolioReader instance
    @objc optional func folioReaderDidClosed(_ folioReader: FolioReader)

	// TODO_SMF_CHECK: make sure the following deprecated functions still work... or not.:
	// TODO_SMF_QUESTION: ask the main developer(s) for that.
	// TODO_SMF_DOC: new function signature change
	@objc optional func folioReaderDidClosed()
}

/// Main Library class with some useful constants and methods
open class FolioReader: NSObject {

	/// Internal init function to disable the creation of `FolioReader` objects outside the current scope.
	internal override init() { }

    /// Custom unzip path
    open var unzipPath				: String?
    
    /// FolioReaderDelegate
    open weak var delegate			: FolioReaderDelegate?

	// TODO_SMF_QUESTION: make those fileprivate (or internal) to avoid public access from other class?
    open weak var readerContainer	: FolioReaderContainer?
    open weak var readerAudioPlayer	: FolioReaderAudioPlayer?
	open weak var readerCenter		: FolioReaderCenter? {
		return self.readerContainer?.centerViewController
	}

    /// Check if reader is open
    var isReaderOpen = false
    
    /// Check if reader is open and ready
    var isReaderReady = false

    /// Check if layout needs to change to fit Right To Left
    var needsRTLChange: Bool {
        return (self.readerContainer?.book.spine.isRtl == true && self.readerContainer?.readerConfig.scrollDirection == .horizontal)
    }

	func isNight<T>(_ f: T, _ l: T) -> T {
		return (self.nightMode == true ? f : l)
	}

	/// UserDefault for the current ePub file.
	fileprivate var defaults: FolioReaderUserDefaults {

		guard
			let path = self.readerContainer?.epubPath,
			(path.isEmpty == false),
			let identifier = (path as? NSString)?.lastPathComponent,
			(identifier.isEmpty == false) else {
				fatalError("invalid user default unique identifier")
				return FolioReaderUserDefaults(withIdentifier: "")
		}

		return FolioReaderUserDefaults(withIdentifier: identifier)
	}
}

// MARK: - Present Folio Reader

extension FolioReader {

	/// Present a Folio Reader Container modally on a Parent View Controller.
	///
	/// - Parameters:
	///   - parentViewController: View Controller that will present the reader container.
	///   - epubPath: String representing the path on the disk of the ePub file. Must not be nil nor empty string.
	///   - config: FolioReader configuration.
	///   - shouldRemoveEpub: Boolean to remove the epub or not. Default true.
	///   - animated: Pass true to animate the presentation; otherwise, pass false.
	/// - Returns: The new and presented FolioReaderContainer instance.
	open class func presentReader(parentViewController: UIViewController, withEpubPath epubPath: String, andConfig config: FolioReaderConfig, shouldRemoveEpub: Bool = true, animated:
		Bool = true) -> FolioReaderContainer {
		// TODO_SMF_DOC
		let folioReader = FolioReader()
		let readerContainer = FolioReaderContainer(withConfig: config, folioReader: folioReader, epubPath: epubPath, removeEpub: shouldRemoveEpub)
		folioReader.readerContainer = readerContainer
		parentViewController.present(readerContainer, animated: animated, completion: nil)
		// TODO_SMF_DOC
		FolioReader.shared = folioReader
		return readerContainer
	}
}

// MARK: -  Getters and setters for stored values

extension FolioReader {

	public func register(defaults: [String: Any]) {
		self.defaults.register(defaults: defaults)
	}

    /// Check if current theme is Night mode
    open var nightMode: Bool {
        get { return self.defaults.bool(forKey: kNightMode) }
        set (value) {
            self.defaults.set(value, forKey: kNightMode)

			if let readerCenter = self.readerCenter {
				UIView.animate(withDuration: 0.6, animations: {
					_ = readerCenter.currentPage?.webView.js("nightMode(\(self.nightMode))")
					readerCenter.pageIndicatorView?.reloadColors()
					readerCenter.configureNavBar()
					readerCenter.scrollScrubber?.reloadColors()
					readerCenter.collectionView.backgroundColor = (self.nightMode == true ? self.readerContainer?.readerConfig.nightModeBackground : UIColor.white)
					}, completion: { (finished: Bool) in
						NotificationCenter.default.post(name: Notification.Name(rawValue: "needRefreshPageMode"), object: nil)
				})
			}
        }
    }

    /// Check current font name. Default .andada
    open var currentFont: FolioReaderFont {
		get {
			guard
				let rawValue = self.defaults.value(forKey: kCurrentFontFamily) as? Int,
				let font = FolioReaderFont(rawValue: rawValue) else {
					return .andada
			}

			return font
		}
        set (font) {
            self.defaults.set(font.rawValue, forKey: kCurrentFontFamily)
			_ = self.readerCenter?.currentPage?.webView.js("setFontName('\(font.cssIdentifier)')")
        }
    }
    
    /// Check current font size. Default .m
    open var currentFontSize: FolioReaderFontSize {
		get {
			guard
				let rawValue = self.defaults.value(forKey: kCurrentFontSize) as? Int,
				let size = FolioReaderFontSize(rawValue: rawValue) else {
					return .m
			}

			return size
		}
        set (value) {
            self.defaults.set(value.rawValue, forKey: kCurrentFontSize)

			guard let currentPage = self.readerCenter?.currentPage else {
				return
			}

			currentPage.webView.js("setFontSize('\(currentFontSize.cssIdentifier)')")
        }
    }

    /// Check current audio rate, the speed of speech voice. Default 0
    var currentAudioRate: Int {
        get { return self.defaults.integer(forKey: kCurrentAudioRate) }
        set (value) {
            self.defaults.set(value, forKey: kCurrentAudioRate)
        }
    }

    /// Check the current highlight style.Default 0
    var currentHighlightStyle: Int {
        get { return self.defaults.integer(forKey: kCurrentHighlightStyle) }
        set (value) {
            self.defaults.set(value, forKey: kCurrentHighlightStyle)
        }
    }
    
    /// Check the current Media Overlay or TTS style
    var currentMediaOverlayStyle: MediaOverlayStyle {
        get {
			guard
				let rawValue = self.defaults.value(forKey: kCurrentMediaOverlayStyle) as? Int,
				let style = MediaOverlayStyle(rawValue: rawValue) else {
					return MediaOverlayStyle.default
			}

			return style
		}
        set (value) {
            self.defaults.set(value.rawValue, forKey: kCurrentMediaOverlayStyle)
        }
    }
    
    /// Check the current scroll direction. Default .defaultVertical
    open var currentScrollDirection: Int {
        get {
			// TODO_SMF_CHECK: when do this happen?
			guard let value = self.defaults.integer(forKey: kCurrentScrollDirection) as? Int else {
				return FolioReaderScrollDirection.defaultVertical.rawValue
			}

			return value
		}
        set (value) {
            self.defaults.set(value, forKey: kCurrentScrollDirection)

			let direction = (FolioReaderScrollDirection(rawValue: currentScrollDirection) ?? .defaultVertical)
			self.readerCenter?.setScrollDirection(direction)
        }
    }

	open var currentMenuIndex: Int {
		get { return self.defaults.integer(forKey: kCurrentTOCMenu) }
		set (value) {
			self.defaults.set(value, forKey: kCurrentTOCMenu)
		}
	}

	open var savedPositionForCurrentBook: [String: Any]? {
		get {
			guard let bookId = self.readerContainer?.book.name else {
				return nil
			}

			return self.defaults.value(forKey: bookId) as? [String : Any]
		}
		set {
			guard let bookId = self.readerContainer?.book.name else {
				return
			}

			self.defaults.set(newValue, forKey: bookId)
		}
	}
}

// MARK: - Image Cover

extension FolioReader {

	// TODO_SMF_QUESTION: this used the shared instance before and ignore the parameter.
	// Should we properly implement the parameter or change the API to use the current FolioReader?

	/**
	Read Cover Image and Return an `UIImage`
	*/
	// TODO_SMF_DOC: new function signature change
	open class func getCoverImage(_ epubPath: String, unzipPath: String? = nil) -> UIImage? {
		return FREpubParser().parseCoverImage(epubPath, unzipPath: unzipPath)
	}

	open class func getTitle(_ epubPath: String) -> String? {
		return FREpubParser().parseTitle(epubPath)
	}

	open class func getAuthorName(_ epubPath: String) -> String? {
		return FREpubParser().parseAuthorName(epubPath)
	}
}

// MARK: - Exit, save and close FolioReader

extension FolioReader {

    /// Save Reader state, book, page and scroll offset.
    open func saveReaderState() {
        guard (self.isReaderOpen == true) else {
			return
		}
        
        guard
			let bookId = self.readerContainer?.book.name,
			let currentPage = self.readerCenter?.currentPage else {
				return
		}

		let position = [
			"pageNumber": (self.readerCenter?.currentPageNumber ?? 0),
			"pageOffsetX": currentPage.webView.scrollView.contentOffset.x,
			"pageOffsetY": currentPage.webView.scrollView.contentOffset.y
			] as [String : Any]

		self.savedPositionForCurrentBook = position
	}

    /// Closes and save the reader current instance.
    open func close() {
        self.saveReaderState()
        self.isReaderOpen = false
        self.isReaderReady = false
        self.readerAudioPlayer?.stop(immediate: true)
        self.defaults.set(0, forKey: kCurrentTOCMenu)
        self.delegate?.folioReaderDidClosed?(self)
		self.delegate?.folioReaderDidClosed?()
    }
}

// MARK: - Public static functions. All Deprecated function

extension FolioReader {

	// TODO_SMF_DEPRECATE
	private static var _sharedInstance = FolioReader()
	open static var shared : FolioReader {
		get { return _sharedInstance }
		set { _sharedInstance = newValue }
	}

	/// Check the current Media Overlay or TTS style
	static var currentMediaOverlayStyle: MediaOverlayStyle {
		// TODO_SMF_DEPRECATE
		return FolioReader.shared.currentMediaOverlayStyle
	}

	/// Check if current theme is Night mode
	open class var nightMode: Bool {
		// TODO_SMF_DEPRECATE
		get { return FolioReader.shared.nightMode }
		set { FolioReader.shared.nightMode = newValue }
	}

	/// Check current font name
	open class var currentFont: FolioReaderFont {
		// TODO_SMF_DEPRECATE
		get { return FolioReader.shared.currentFont }
		set { FolioReader.shared.currentFont = newValue }
	}

	/// Check current font size
	open class var currentFontSize: FolioReaderFontSize {
		// TODO_SMF_DEPRECATE
		get { return FolioReader.shared.currentFontSize }
		set { FolioReader.shared.currentFontSize = newValue }
	}

	/// Check the current scroll direction
	open class var currentScrollDirection: Int {
		// TODO_SMF_DEPRECATE
		get { return FolioReader.shared.currentScrollDirection }
		set { FolioReader.shared.currentScrollDirection = newValue }
	}

	/// Check current audio rate, the speed of speech voice
	open class var currentAudioRate: Int {
		// TODO_SMF_DEPRECATE
		get { return FolioReader.shared.currentAudioRate }
		set { FolioReader.shared.currentAudioRate = newValue }
	}

	/// Check if reader is open and ready
	open class var isReaderReady : Bool {
		// TODO_SMF_DEPRECATE
		return FolioReader.shared.isReaderReady
	}

	/// Save Reader state, book, page and scroll are saved
	open class func saveReaderState() {
		// TODO_SMF_DEPRECATE
		FolioReader.shared.saveReaderState()
	}

	/// Closes and save the reader current instance
	open class func close() {
		// TODO_SMF_DEPRECATE
		FolioReader.shared.close()
	}

	/// Check the current highlight style
	open class var currentHighlightStyle: Int {
		// TODO_SMF_DEPRECATE
		get { return FolioReader.shared.currentHighlightStyle }
		set { FolioReader.shared.currentHighlightStyle = newValue }
	}

	/// Check if layout needs to change to fit Right To Left
	open class var needsRTLChange: Bool {
		// TODO_SMF_DEPRECATE
		return FolioReader.shared.needsRTLChange
	}
}

// MARK: - Application State

extension FolioReader {

	// TODO_SMF_DEPRECATE and find a replacement for those functions.

	/// Called when the application will resign active
	open class func applicationWillResignActive() {
		// TODO_SMF_DEPRECATE
		// TODO_DOC: no replacement required. Call `aFolioReader.saveReaderState()` instead
		FolioReader.shared.saveReaderState()
	}

	/// Called when the application will terminate
	open class func applicationWillTerminate() {
		// TODO_SMF_DEPRECATE
		// TODO_DOC: no replacement required. Call `aFolioReader.saveReaderState()` instead
		FolioReader.shared.saveReaderState()
	}
}

// MARK: - Global Functions

func isNight<T> (_ f: T, _ l: T) -> T {
	// TODO_SMF_DEPRECATE
	// TODO_SMF_DOC: notify change
    return (FolioReader.shared.nightMode == true ? f : l)
}

// MARK: - Scroll Direction Functions

func isDirection<T> (_ vertical: T, _ horizontal: T, _ horizontalContentVertical: T? = nil) -> T {
	// TODO_SMF_DEPRECATE
	// TODO_SMF_DOC: notify change
	let direction = (FolioReader.shared.readerContainer!.readerConfig.scrollDirection)
	switch direction {
	case .vertical, .defaultVertical: 		return vertical
	case .horizontal: 						return horizontal
	case .horizontalWithVerticalContent: 	return (horizontalContentVertical ?? vertical)
	}
}

extension UICollectionViewScrollDirection {

	static func direction() -> UICollectionViewScrollDirection {
		// TODO_SMF_DEPRECATE
		guard let readerConfig = FolioReader.shared.readerContainer?.readerConfig else {
			return .vertical
		}

		return UICollectionViewScrollDirection.direction(withConfiguration: readerConfig)
	}

    static func direction(withConfiguration readerConfig: FolioReaderConfig) -> UICollectionViewScrollDirection {
		// TODO_SMF_DOC
        return readerConfig.isDirection(.vertical, .horizontal, .horizontal)
    }
}

extension UICollectionViewScrollPosition {

	static func direction() -> UICollectionViewScrollPosition {
		// TODO_SMF_DEPRECATE
		guard let readerConfig = FolioReader.shared.readerContainer?.readerConfig else {
			return .top
		}

		return UICollectionViewScrollPosition.direction(withConfiguration: readerConfig)
	}

	static func direction(withConfiguration readerConfig: FolioReaderConfig) -> UICollectionViewScrollPosition {
		// TODO_SMF_DOC
		return readerConfig.isDirection(.top, .left, .left)
	}
}

extension CGPoint {

    func forDirection() -> CGFloat {
		// TODO_SMF_DEPRECATE
		guard let readerConfig = FolioReader.shared.readerContainer?.readerConfig else {
			return self.y
		}

		return self.forDirection(withConfiguration: readerConfig)
    }

	func forDirection(withConfiguration readerConfig: FolioReaderConfig) -> CGFloat {
		// TODO_SMF_DOC
		return readerConfig.isDirection(self.y, self.x, self.y)
	}
}

extension CGSize {

    func forDirection() -> CGFloat {
		// TODO_SMF_DEPRECATE
		guard let readerConfig = FolioReader.shared.readerContainer?.readerConfig else {
			return self.height
		}
		return self.forDirection(withConfiguration: readerConfig)
    }

	func forDirection(withConfiguration readerConfig: FolioReaderConfig) -> CGFloat {
		// TODO_SMF_DOC
		return readerConfig.isDirection(height, width, height)
	}

    func forReverseDirection() -> CGFloat {
		// TODO_SMF_DEPRECATE
		guard let readerConfig = FolioReader.shared.readerContainer?.readerConfig else {
			return self.width
		}

		return self.forReverseDirection(withConfiguration: readerConfig)
    }

	func forReverseDirection(withConfiguration readerConfig: FolioReaderConfig) -> CGFloat {
		// TODO_SMF_DOC
		return readerConfig.isDirection(width, height, width)
	}
}

extension CGRect {

    func forDirection() -> CGFloat {
		// TODO_SMF_DEPRECATE
		guard let readerConfig = FolioReader.shared.readerContainer?.readerConfig else {
			return self.height
		}

		return self.forDirection(withConfiguration: readerConfig)
    }

	func forDirection(withConfiguration readerConfig: FolioReaderConfig) -> CGFloat {
		// TODO_SMF_DOC
		return readerConfig.isDirection(height, width, height)
	}
}

extension ScrollDirection {

    static func negative() -> ScrollDirection {
		// TODO_SMF_DEPRECATE
		guard let readerConfig = FolioReader.shared.readerContainer?.readerConfig else {
			return self.down
		}

        return self.negative(withConfiguration: readerConfig)
    }

	static func negative(withConfiguration readerConfig: FolioReaderConfig) -> ScrollDirection {
		// TODO_SMF_DOC
		return readerConfig.isDirection(.down, .right, .right)
	}

    static func positive() -> ScrollDirection {
		// TODO_SMF_DEPRECATE
		guard let readerConfig = FolioReader.shared.readerContainer?.readerConfig else {
			return self.up
		}

        return self.positive(withConfiguration: readerConfig)
    }

	static func positive(withConfiguration readerConfig: FolioReaderConfig) -> ScrollDirection {
		// TODO_SMF_DOC
		return readerConfig.isDirection(.up, .left, .left)
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

	//
	/// Hex string of a UIColor instance.
	///
	/// from: https://github.com/yeahdongcn/UIColor-Hex-Swift
	///
	/// - Parameter includeAlpha: Whether the alpha should be included.
	/// - Returns: Hexa string
	func hexString(_ includeAlpha: Bool) -> String {
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		self.getRed(&r, green: &g, blue: &b, alpha: &a)

		if (includeAlpha == true) {
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

    /// Forces the image to be colored with Reader Config tintColor
    ///
    /// - Returns: Returns a colored image
	func ignoreSystemTint() -> UIImage? {
		// TODO_SMF_DEPRECATE
		guard let readerConfig = FolioReader.shared.readerContainer?.readerConfig else {
			return nil
		}

		return self.ignoreSystemTint(withConfiguration: readerConfig)
	}

    /// Forces the image to be colored with Reader Config tintColor
    ///
    /// - Parameter readerConfig: Current folio reader configuration.
    /// - Returns: Returns a colored image
    func ignoreSystemTint(withConfiguration readerConfig: FolioReaderConfig) -> UIImage? {
		// TODO_SMF_DOC
        return self.imageTintColor(readerConfig.tintColor)?.withRenderingMode(.alwaysOriginal)
    }

    /**
     Colorize the image with a color
     
     - parameter tintColor: The input color
     - returns: Returns a colored image
     */
    func imageTintColor(_ tintColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height) as CGRect
		if let cgImage = self.cgImage {
        	context?.clip(to: rect, mask:  cgImage)
		}

        tintColor.setFill()
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
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
		// TODO_SMF_DEPRECATE
		guard let config = FolioReader.shared.readerContainer?.readerConfig else {
			return
		}

		self.setCloseButton(withConfiguration: config)
	}

    func setCloseButton(withConfiguration readerConfig: FolioReaderConfig) {
		// TODO_SMF_DOC
        let closeImage = UIImage(readerImageNamed: "icon-navbar-close")?.ignoreSystemTint(withConfiguration: readerConfig)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(dismiss as (Void) -> Void))
    }
    
    func dismiss() {
        self.dismiss(nil)
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
