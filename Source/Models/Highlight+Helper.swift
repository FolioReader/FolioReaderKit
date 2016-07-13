//
//  Highlight+Helper.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 06/07/16.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import Foundation
import RealmSwift

/**
 HighlightStyle type, default is .Yellow.
 */
public enum HighlightStyle: Int {
    case Yellow
    case Green
    case Blue
    case Pink
    case Underline
    
    public init () { self = .Yellow }
    
    /**
     Return HighlightStyle for CSS class.
     */
    public static func styleForClass(className: String) -> HighlightStyle {
        switch className {
        case "highlight-yellow":
            return .Yellow
        case "highlight-green":
            return .Green
        case "highlight-blue":
            return .Blue
        case "highlight-pink":
            return .Pink
        case "highlight-underline":
            return .Underline
        default:
            return .Yellow
        }
    }
    
    /**
     Return CSS class for HighlightStyle.
     */
    public static func classForStyle(style: Int) -> String {
        switch style {
        case HighlightStyle.Yellow.rawValue:
            return "highlight-yellow"
        case HighlightStyle.Green.rawValue:
            return "highlight-green"
        case HighlightStyle.Blue.rawValue:
            return "highlight-blue"
        case HighlightStyle.Pink.rawValue:
            return "highlight-pink"
        case HighlightStyle.Underline.rawValue:
            return "highlight-underline"
        default:
            return "highlight-yellow"
        }
    }
    
    /**
     Return CSS class for HighlightStyle.
     */
    public static func colorForStyle(style: Int, nightMode: Bool = false) -> UIColor {
        switch style {
        case HighlightStyle.Yellow.rawValue:
            return UIColor(red: 255/255, green: 235/255, blue: 107/255, alpha: nightMode ? 0.9 : 1)
        case HighlightStyle.Green.rawValue:
            return UIColor(red: 192/255, green: 237/255, blue: 114/255, alpha: nightMode ? 0.9 : 1)
        case HighlightStyle.Blue.rawValue:
            return UIColor(red: 173/255, green: 216/255, blue: 255/255, alpha: nightMode ? 0.9 : 1)
        case HighlightStyle.Pink.rawValue:
            return UIColor(red: 255/255, green: 176/255, blue: 202/255, alpha: nightMode ? 0.9 : 1)
        case HighlightStyle.Underline.rawValue:
            return UIColor(red: 240/255, green: 40/255, blue: 20/255, alpha: nightMode ? 0.6 : 1)
        default:
            return UIColor(red: 255/255, green: 235/255, blue: 107/255, alpha: nightMode ? 0.9 : 1)
        }
    }
}

public typealias Completion = (error: NSError?) -> ()

extension Highlight {
    public func persist(completion: Completion? = nil) {
        do {
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(self, update: true)
            try realm.commitWrite()
            completion?(error: nil)
        } catch let error as NSError {
            print("Error on persist highlight: \(error)")
            completion?(error: error)
        }
    }
    
    public func remove() {
        do {
            let realm = try! Realm()
            realm.beginWrite()
            realm.delete(self)
            try realm.commitWrite()
        } catch let error as NSError {
            print("Error on remove highlight: \(error)")
        }
    }
    
    public static func removeById(highlightId: String) {
        var highlight: Highlight?
        let predicate = NSPredicate(format:"highlightId = %@", highlightId)
        
        let realm = try! Realm()
        highlight = realm.objects(Highlight).filter(predicate).toArray(Highlight).first
        highlight?.remove()
            
    }
    
    public static func updateById(highlightId: String, type: HighlightStyle) {
        var highlight: Highlight?
        let predicate = NSPredicate(format:"highlightId = %@", highlightId)
        do {
            let realm = try! Realm()
            highlight = realm.objects(Highlight).filter(predicate).toArray(Highlight).first
            realm.beginWrite()
            
            highlight?.type = type.hashValue
            
            try realm.commitWrite()
        } catch let error as NSError {
            print("Error on updateById : \(error)")
        }
        
    }
    
    public static func allByBookId(bookId: String, andPage page: NSNumber? = nil) -> [Highlight] {
        var highlights: [Highlight]?
        let predicate = (page != nil) ? NSPredicate(format: "bookId = %@ && page = %@", bookId, page!) : NSPredicate(format: "bookId = %@", bookId)
        let realm = try! Realm()
        highlights = realm.objects(Highlight).filter(predicate).toArray(Highlight) ?? [Highlight]()
        return highlights!
    }
    
    public static func all() -> [Highlight] {
        var highlights: [Highlight]?
        let realm = try! Realm()
        highlights = realm.objects(Highlight).toArray(Highlight) ?? [Highlight]()
        return highlights!
    }
    
    // MARK: HTML Methods
    
    /**
     Match a highlight on string.
     */
    public static func matchHighlight(text: String!, andId id: String, startOffset: String, endOffset: String) -> Highlight? {
        let pattern = "<highlight id=\"\(id)\" onclick=\".*?\" class=\"(.*?)\">((.|\\s)*?)</highlight>"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matchesInString(text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        let str = (text as NSString)
        
        let mapped = matches.map { (match) -> Highlight in
            var contentPre = str.substringWithRange(NSRange(location: match.range.location-kHighlightRange, length: kHighlightRange))
            var contentPost = str.substringWithRange(NSRange(location: match.range.location + match.range.length, length: kHighlightRange))
            
            // Normalize string before save
            
            if contentPre.rangeOfString(">") != nil {
                let regex = try! NSRegularExpression(pattern: "((?=[^>]*$)(.|\\s)*$)", options: [])
                let searchString = regex.firstMatchInString(contentPre, options: .ReportProgress, range: NSRange(location: 0, length: contentPre.characters.count))
                
                if searchString!.range.location != NSNotFound {
                    contentPre = (contentPre as NSString).substringWithRange(searchString!.range)
                }
            }
            
            if contentPost.rangeOfString("<") != nil {
                let regex = try! NSRegularExpression(pattern: "^((.|\\s)*?)(?=<)", options: [])
                let searchString = regex.firstMatchInString(contentPost, options: .ReportProgress, range: NSRange(location: 0, length: contentPost.characters.count))
                
                if searchString!.range.location != NSNotFound {
                    contentPost = (contentPost as NSString).substringWithRange(searchString!.range)
                }
            }
            
            let highlight = Highlight()
            highlight.highlightId = id
            highlight.type = HighlightStyle.styleForClass(str.substringWithRange(match.rangeAtIndex(1))).rawValue
            highlight.date = NSDate()
            highlight.content = Highlight.removeSentenceSpam(str.substringWithRange(match.rangeAtIndex(2)))
            highlight.contentPre = Highlight.removeSentenceSpam(contentPre)
            highlight.contentPost = Highlight.removeSentenceSpam(contentPost)
            highlight.page = currentPageNumber
            highlight.bookId = (kBookId as NSString).stringByDeletingPathExtension
            highlight.startOffset = Int(startOffset) ?? -1
            highlight.endOffset = Int(endOffset) ?? -1

            return highlight
        }
        return mapped.first
    }
    
    public static func removeFromHTMLById(highlightId: String) -> String? {
        let currentPage = FolioReader.sharedInstance.readerCenter.currentPage
        
        if let removedId = currentPage.webView.js("removeHighlightById('\(highlightId)')") {
            return removedId
        } else {
            print("Error removing Higlight from page")
            return nil
        }
    }
    
    /**
     Remove span tag before store the highlight, this span is added on JavaScript.
     <span class=\"sentence\"></span>
     
     - parameter text: Text to analise
     - returns: Striped text
     */
    public static func removeSentenceSpam(text: String) -> String {
        
        // Remove from text
        func removeFrom(text: String, withPattern pattern: String) -> String {
            var locator = text
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matchesInString(locator, options: [], range: NSRange(location: 0, length: locator.utf16.count))
            let str = (locator as NSString)
            
            var newLocator = ""
            for match in matches {
                newLocator += str.substringWithRange(match.rangeAtIndex(1))
            }
            
            if matches.count > 0 && !newLocator.isEmpty {
                locator = newLocator
            }
            
            return locator
        }
        
        let pattern = "<span class=\"sentence\">((.|\\s)*?)</span>"
        let cleanText = removeFrom(text, withPattern: pattern)
        return cleanText
    }
}