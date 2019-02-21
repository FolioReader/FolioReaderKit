//
//  Extensions.swift
//  Pods
//
//  Created by Kevin Delord on 01/04/17.
//
//

import Foundation
import UIKit

extension UICollectionView.ScrollDirection {
    static func direction(withConfiguration readerConfig: FolioReaderConfig) -> UICollectionView.ScrollDirection {
        return readerConfig.isDirection(.vertical, .horizontal, .horizontal)
    }
}

extension UICollectionView.ScrollPosition {
    static func direction(withConfiguration readerConfig: FolioReaderConfig) -> UICollectionView.ScrollPosition {
        return readerConfig.isDirection(.top, .left, .left)
    }
}

extension CGPoint {
    func forDirection(withConfiguration readerConfig: FolioReaderConfig, scrollType: ScrollType = .page) -> CGFloat {
        return readerConfig.isDirection(self.y, self.x, ((scrollType == .page) ? self.y : self.x))
    }
}

extension CGSize {
    func forDirection(withConfiguration readerConfig: FolioReaderConfig) -> CGFloat {
        return readerConfig.isDirection(height, width, height)
    }
    
    func forReverseDirection(withConfiguration readerConfig: FolioReaderConfig) -> CGFloat {
        return readerConfig.isDirection(width, height, width)
    }
}

extension CGRect {
    func forDirection(withConfiguration readerConfig: FolioReaderConfig) -> CGFloat {
        return readerConfig.isDirection(height, width, height)
    }
}

extension ScrollDirection {
    static func negative(withConfiguration readerConfig: FolioReaderConfig, scrollType: ScrollType = .page) -> ScrollDirection {
        return readerConfig.isDirection(.down, .right, .right)
    }
    
    static func positive(withConfiguration readerConfig: FolioReaderConfig, scrollType: ScrollType = .page) -> ScrollDirection {
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
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
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
            let index = rgba.index(rgba.startIndex, offsetBy: 1)
            let hex = String(rgba[index...])
            let scanner = Scanner(string: hex)
            var hexValue: CUnsignedLongLong = 0
            if scanner.scanHexInt64(&hexValue) {
                switch (hex.count) {
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
        if count > length {
            let indexOfText = index(startIndex, offsetBy: length)
            return String(self[..<indexOfText])
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
    
    // MARK: - NSString helpers
    
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    
    var deletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }
    
    var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    var abbreviatingWithTildeInPath: String {
        return (self as NSString).abbreviatingWithTildeInPath
    }
    
    func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
    
    func appendingPathExtension(_ str: String) -> String {
        return (self as NSString).appendingPathExtension(str) ?? self+"."+str
    }
}

internal extension UIImage {
    
    convenience init?(readerImageNamed: String) {
        self.init(named: readerImageNamed, in: Bundle.frameworkBundle(), compatibleWith: nil)
    }
    
    /// Forces the image to be colored with Reader Config tintColor
    ///
    /// - Parameter readerConfig: Current folio reader configuration.
    /// - Returns: Returns a colored image
    func ignoreSystemTint(withConfiguration readerConfig: FolioReaderConfig) -> UIImage? {
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
    
    func setCloseButton(withConfiguration readerConfig: FolioReaderConfig) {
        let closeImage = UIImage(readerImageNamed: "icon-navbar-close")?.ignoreSystemTint(withConfiguration: readerConfig)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(dismiss as () -> Void))
    }
    
    @objc func dismiss() {
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
        navBar?.isHidden = true
        navBar?.isTranslucent = true
    }
    
    func setTranslucentNavigation(_ translucent: Bool = true, color: UIColor, tintColor: UIColor = UIColor.white, titleColor: UIColor = UIColor.black, andFont font: UIFont = UIFont.systemFont(ofSize: 17)) {
        let navBar = self.navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage.imageWithColor(color), for: UIBarMetrics.default)
        navBar?.isHidden = false
        navBar?.isTranslucent = translucent
        navBar?.tintColor = tintColor
        navBar?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: titleColor, NSAttributedString.Key.font: font]
    }
}
/**
 Fix for Swift 4 / iOS 12
 https://stackoverflow.com/questions/34452920/removing-the-hairline-under-navigation-bar
 */
private var navigationBarHairLine: UIImageView?

func findHairlineImageViewUnderView(view: UIView?) -> UIImageView? {
    guard let view = view else { return nil }
    if view.isKind(of: UIImageView.classForCoder()) && view.bounds.height <= 1 {
        return view as? UIImageView
    }
    for subView in view.subviews {
        if let imageView = findHairlineImageViewUnderView(view: subView) {
            return imageView
        }
    }
    return nil
}

/// :nodoc:
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

/// :nodoc:
extension UIAlertController {
    open override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    open override var shouldAutorotate : Bool {
        return false
    }
}

/// :nodoc:
extension Array {
    
    /**
     Return index if is safe, if not return nil
     http://stackoverflow.com/a/30593673/517707
     */
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
