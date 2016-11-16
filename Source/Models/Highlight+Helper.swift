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
    case yellow
    case green
    case blue
    case pink
    case underline
    
    public init () { self = .yellow }
    
    /**
     Return HighlightStyle for CSS class.
     */
    public static func styleForClass(_ className: String) -> HighlightStyle {
        switch className {
        case "highlight-yellow":
            return .yellow
        case "highlight-green":
            return .green
        case "highlight-blue":
            return .blue
        case "highlight-pink":
            return .pink
        case "highlight-underline":
            return .underline
        default:
            return .yellow
        }
    }
    
    /**
     Return CSS class for HighlightStyle.
     */
    public static func classForStyle(_ style: Int) -> String {
        switch style {
        case HighlightStyle.yellow.rawValue:
            return "highlight-yellow"
        case HighlightStyle.green.rawValue:
            return "highlight-green"
        case HighlightStyle.blue.rawValue:
            return "highlight-blue"
        case HighlightStyle.pink.rawValue:
            return "highlight-pink"
        case HighlightStyle.underline.rawValue:
            return "highlight-underline"
        default:
            return "highlight-yellow"
        }
    }
    
    /**
     Return CSS class for HighlightStyle.
     */
    public static func colorForStyle(_ style: Int, nightMode: Bool = false) -> UIColor {
        switch style {
        case HighlightStyle.yellow.rawValue:
            return UIColor(red: 255/255, green: 235/255, blue: 107/255, alpha: nightMode ? 0.9 : 1)
        case HighlightStyle.green.rawValue:
            return UIColor(red: 192/255, green: 237/255, blue: 114/255, alpha: nightMode ? 0.9 : 1)
        case HighlightStyle.blue.rawValue:
            return UIColor(red: 173/255, green: 216/255, blue: 255/255, alpha: nightMode ? 0.9 : 1)
        case HighlightStyle.pink.rawValue:
            return UIColor(red: 255/255, green: 176/255, blue: 202/255, alpha: nightMode ? 0.9 : 1)
        case HighlightStyle.underline.rawValue:
            return UIColor(red: 240/255, green: 40/255, blue: 20/255, alpha: nightMode ? 0.6 : 1)
        default:
            return UIColor(red: 255/255, green: 235/255, blue: 107/255, alpha: nightMode ? 0.9 : 1)
        }
    }
}

/// Completion block
public typealias Completion = (_ error: NSError?) -> ()

extension Highlight {
    
    /**
     Save a Highlight with completion block
     
     - parameter completion: Completion block
     */
    public func persist(_ completion: Completion? = nil) {
        do {
            let realm = try! Realm()
            realm.beginWrite()
            realm.add(self, update: true)
            try realm.commitWrite()
            completion?(nil)
        } catch let error as NSError {
            print("Error on persist highlight: \(error)")
            completion?(error)
        }
    }
    
    /**
     Remove a Highlight
     */
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
    
    /**
     Remove a Highlight by ID
     
     - parameter highlightId: The ID to be removed
     */
    public static func removeById(_ highlightId: String) {
        var highlight: Highlight?
        let predicate = NSPredicate(format:"highlightId = %@", highlightId)
        
        let realm = try! Realm()
        highlight = realm.objects(Highlight.self).filter(predicate).toArray(Highlight.self).first
        highlight?.remove()
    }
    
    /**
     Update a Highlight by ID
     
     - parameter highlightId: The ID to be removed
     - parameter type:        The `HighlightStyle`
     */
    public static func updateById(_ highlightId: String, type: HighlightStyle) {
        var highlight: Highlight?
        let predicate = NSPredicate(format:"highlightId = %@", highlightId)
        do {
            let realm = try! Realm()
            highlight = realm.objects(Highlight.self).filter(predicate).toArray(Highlight.self).first
            realm.beginWrite()
            
            highlight?.type = type.hashValue
            
            try realm.commitWrite()
        } catch let error as NSError {
            print("Error on updateById : \(error)")
        }
        
    }
    
    /**
     Return a list of Highlights with a given ID
     
     - parameter bookId: Book ID
     - parameter page:   Page number
     
     - returns: Return a list of Highlights
     */
    public static func allByBookId(_ bookId: String, andPage page: NSNumber? = nil) -> [Highlight] {
        var highlights: [Highlight]?
        let predicate = (page != nil) ? NSPredicate(format: "bookId = %@ && page = %@", bookId, page!) : NSPredicate(format: "bookId = %@", bookId)
        let realm = try! Realm()
        highlights = realm.objects(Highlight.self).filter(predicate).toArray(Highlight.self)
        return highlights!
    }
    
    /**
     Return all Highlights
     
     - returns: Return all Highlights
     */
    public static func all() -> [Highlight] {
        var highlights: [Highlight]?
        let realm = try! Realm()
        highlights = realm.objects(Highlight.self).toArray(Highlight.self)
        return highlights!
    }
    
    // MARK: HTML Methods
    
    /**
     Match a highlight on string.
     */
    public static func matchHighlight(_ text: String!, andId id: String, startOffset: String, endOffset: String) -> Highlight? {
        let pattern = "<highlight id=\"\(id)\" onclick=\".*?\" class=\"(.*?)\">((.|\\s)*?)</highlight>"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        let str = (text as NSString)
        
        let mapped = matches.map { (match) -> Highlight in
            var contentPre = str.substring(with: NSRange(location: match.range.location-kHighlightRange, length: kHighlightRange))
            var contentPost = str.substring(with: NSRange(location: match.range.location + match.range.length, length: kHighlightRange))
            
            // Normalize string before save
            
            if contentPre.range(of: ">") != nil {
                let regex = try! NSRegularExpression(pattern: "((?=[^>]*$)(.|\\s)*$)", options: [])
                let searchString = regex.firstMatch(in: contentPre, options: .reportProgress, range: NSRange(location: 0, length: contentPre.characters.count))
                
                if searchString!.range.location != NSNotFound {
                    contentPre = (contentPre as NSString).substring(with: searchString!.range)
                }
            }
            
            if contentPost.range(of: "<") != nil {
                let regex = try! NSRegularExpression(pattern: "^((.|\\s)*?)(?=<)", options: [])
                let searchString = regex.firstMatch(in: contentPost, options: .reportProgress, range: NSRange(location: 0, length: contentPost.characters.count))
                
                if searchString!.range.location != NSNotFound {
                    contentPost = (contentPost as NSString).substring(with: searchString!.range)
                }
            }
            
            let highlight = Highlight()
            highlight.highlightId = id
            highlight.type = HighlightStyle.styleForClass(str.substring(with: match.rangeAt(1))).rawValue
            highlight.date = Foundation.Date()
            highlight.content = Highlight.removeSentenceSpam(str.substring(with: match.rangeAt(2)))
            highlight.contentPre = Highlight.removeSentenceSpam(contentPre)
            highlight.contentPost = Highlight.removeSentenceSpam(contentPost)
            highlight.page = currentPageNumber
            highlight.bookId = (kBookId as NSString).deletingPathExtension
            highlight.startOffset = Int(startOffset) ?? -1
            highlight.endOffset = Int(endOffset) ?? -1

            return highlight
        }
        return mapped.first
    }
    
    /**
     Remove a Highlight from HTML by ID
     
     - parameter highlightId: The ID to be removed
     - returns: The removed id
     */
    @discardableResult public static func removeFromHTMLById(_ highlightId: String) -> String? {
        guard let currentPage = FolioReader.shared.readerCenter?.currentPage else { return nil }
        
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
    public static func removeSentenceSpam(_ text: String) -> String {
        
        // Remove from text
        func removeFrom(_ text: String, withPattern pattern: String) -> String {
            var locator = text
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let matches = regex.matches(in: locator, options: [], range: NSRange(location: 0, length: locator.utf16.count))
            let str = (locator as NSString)
            
            var newLocator = ""
            for match in matches {
                newLocator += str.substring(with: match.rangeAt(1))
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
