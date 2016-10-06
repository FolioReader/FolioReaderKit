//
//  FontBlaster.swift
//  FontBlaster
//
//  Created by Arthur Sabintsev on 5/5/15.
//  Copyright (c) 2015 Arthur Ariel Sabintsev. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreText


// MARK: - Enums

/**
 Limits the type of fonts that can be loaded into an application
 
 There are two options:
 - TrueTypeFont
 - OpenTypeFont
 */
private enum SupportedFontExtensions: String {
    case TrueTypeFont = ".ttf"
    case OpenTypeFont = ".otf"
}


// MARK: - FontBlaster

/**
 The FontBlaster Class.
 
 Only one class method can be accessed
 - blast(_:)
 Only one class variable can be accessed and modified
 - debugEnabled
 */
final public class FontBlaster {
    
    private typealias FontPath = String
    private typealias FontName = String
    private typealias FontExtension = String
    private typealias Font = (path: FontPath, name: FontName, ext: FontExtension)
    
    /**
     Used to toggle debug println() statements
     */
    public static var debugEnabled = false
    
    /**
     A list of the loaded fonts
     */
    public static var loadedFonts: [String] = []
    
    /**
     Load all fonts found in a specific bundle. If no value is entered, it defaults to NSBundle.mainBundle().
     */
    public class func blast(bundle: NSBundle = NSBundle.mainBundle()) {
        blast(bundle, completion: nil)
    }
    
    /**
     Load all fonts found in a specific bundle. If no value is entered, it defaults to NSBundle.mainBundle().
     
     - returns: An array of strings constaining the names of the fonts that were loaded.
     */
    public class func blast(bundle: NSBundle = NSBundle.mainBundle(), completion handler: ([String]->Void)?) {
        let path = bundle.bundlePath
        loadFontsForBundleWithPath(path)
        loadFontsFromBundlesFoundInBundle(path)
        handler?(loadedFonts)
    }
}


// MARK: - Helpers (Font Loading)

private extension FontBlaster {
    /**
     Loads all fonts found in a bundle.
     
     - parameter path: The absolute path to the bundle.
     */
    class func loadFontsForBundleWithPath(path: String) {
        do {
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
            let fonts = fontsFromPath(path: path, contents: contents)
            if !fonts.isEmpty {
                for font in fonts {
                    loadFont(font)
                }
            } else {
                printStatus(status: "No fonts were found in the bundle path: \(path).")
            }
        } catch let error as NSError {
            printStatus(status: "There was an error loading fonts from the bundle. \nPath: \(path).\nError: \(error)")
        }
    }
    
    /**
     Loads all fonts found in a bundle that is loaded within another bundle.
     
     - parameter path: The absolute path to the bundle.
     */
    class func loadFontsFromBundlesFoundInBundle(path: String) {
        
        do {
            
            let contents = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
            
            for item in contents {
                
                if let url = NSURL(string: path) where item.containsString(".bundle"),
                    let urlPath = url.URLByAppendingPathComponent(item),
                    urlPathString = urlPath.absoluteString {
                    
                    loadFontsForBundleWithPath(urlPathString)
                    
                }
                
            }
            
        } catch let error as NSError {
            printStatus(status: "There was an error accessing bundle with path. \nPath: \(path).\nError: \(error)")
        }
        
    }
    
    /**
     Loads a specific font.
     
     - parameter font: The font to load.
     */
    class func loadFont(font: Font) {
        let fontPath: FontPath = font.path
        let fontName: FontName = font.name
        let fontExtension: FontExtension = font.ext
        
        guard let fontFileURL = NSBundle(path: fontPath)?.URLForResource(fontName, withExtension: fontExtension) else {
            printStatus(status: "Could not unwrap the file URL for the resource with name: \(fontName) and extension \(fontExtension)")
            return
        }
        
        var fontError: Unmanaged<CFError>?
        
        if let fontData = NSData(contentsOfURL: fontFileURL),
            dataProvider = CGDataProviderCreateWithCFData(fontData) {
            
            let fontRef = CGFontCreateWithDataProvider(dataProvider)
            
            if CTFontManagerRegisterGraphicsFont(fontRef, &fontError) {
                
                if let postScriptName = CGFontCopyPostScriptName(fontRef) {
                    printStatus(status: "Successfully loaded font: '\(postScriptName)'.")
                    loadedFonts.append(String(postScriptName))
                }
                
            } else if let fontError = fontError?.takeRetainedValue() {
                let errorDescription = CFErrorCopyDescription(fontError)
                printStatus(status: "Failed to load font '\(fontName)': \(errorDescription)")
            }
            
        } else {
            
            guard let fontError = fontError?.takeRetainedValue() else {
                printStatus(status: "Failed to load font '\(fontName)'.")
                return
            }
            
            let errorDescription = CFErrorCopyDescription(fontError)
            printStatus(status: "Failed to load font '\(fontName)': \(errorDescription)")
        }
        
    }
}


// MARK: - Helpers (Miscellaneous)

private extension FontBlaster {
    /**
     Parses a font into its name and extension components.
     
     - parameter path: The absolute path to the font file.
     - parameter contents: The contents of an NSBundle as an array of String objects.
     - returns: A tuple with the font's name and extension.
     */
    class func fontsFromPath(path path: String, contents: [NSString]) -> [Font] {
        var fonts = [Font]()
        for fontName in contents {
            var parsedFont: (FontName, FontExtension)?
            
            if fontName.containsString(SupportedFontExtensions.TrueTypeFont.rawValue) || fontName.containsString(SupportedFontExtensions.OpenTypeFont.rawValue) {
                parsedFont = fontFromName(fontName as String)
            }
            
            if let parsedFont = parsedFont {
                let font: Font = (path, parsedFont.0, parsedFont.1)
                fonts.append(font)
            }
        }
        
        return fonts
    }
    
    /**
     Parses a font into its name and extension components.
     
     - parameter The: name of the font.
     - returns: A tuple with the font's name and extension.
     */
    class func fontFromName(name: String) -> (FontName, FontExtension) {
        let components = name.characters.split{$0 == "."}.map { String($0) }
        return (components[0], components[1])
    }
    
    /**
     Prints debug messages to the console if debugEnabled is set to true.
     
     - parameter The: status to print to the console.
     */
    class func printStatus(status status: String) {
        if debugEnabled == true {
            print("[FontBlaster]: \(status)")
        }
    }
}
