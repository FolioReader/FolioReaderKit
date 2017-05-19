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

    public init () {
        // Default style is `.yellow`
        self = .yellow
    }

    /**
     Return HighlightStyle for CSS class.
     */
    public static func styleForClass(_ className: String) -> HighlightStyle {
        switch className {
        case "highlight-yellow":    return .yellow
        case "highlight-green":     return .green
        case "highlight-blue":      return .blue
        case "highlight-pink":      return .pink
        case "highlight-underline": return .underline
        default:                    return .yellow
        }
    }

    /**
     Return CSS class for HighlightStyle.
     */
    public static func classForStyle(_ style: Int) -> String {

        let enumStyle = (HighlightStyle(rawValue: style) ?? HighlightStyle())
        switch enumStyle {
        case .yellow:       return "highlight-yellow"
        case .green:        return "highlight-green"
        case .blue:         return "highlight-blue"
        case .pink:         return "highlight-pink"
        case .underline:    return "highlight-underline"
        }
    }

    /// Color components for the style
    ///
    /// - Returns: Tuple of all color compnonents.
    private func colorComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        switch self {
        case .yellow:       return (red: 255, green: 235, blue: 107, alpha: 0.9)
        case .green:        return (red: 192, green: 237, blue: 114, alpha: 0.9)
        case .blue:         return (red: 173, green: 216, blue: 255, alpha: 0.9)
        case .pink:         return (red: 255, green: 176, blue: 202, alpha: 0.9)
        case .underline:    return (red: 240, green: 40, blue: 20, alpha: 0.6)
        }
    }

    /**
     Return CSS class for HighlightStyle.
     */
    public static func colorForStyle(_ style: Int, nightMode: Bool = false) -> UIColor {
        let enumStyle = (HighlightStyle(rawValue: style) ?? HighlightStyle())
        let colors = enumStyle.colorComponents()
        return UIColor(red: colors.red/255, green: colors.green/255, blue: colors.blue/255, alpha: (nightMode ? colors.alpha : 1))
    }
}

/// Completion block
public typealias Completion = (_ error: NSError?) -> ()

extension Highlight {

    /// Save a Highlight with completion block
    ///
    /// - Parameters:
    ///   - readerConfig: Current folio reader configuration.
    ///   - completion: Completion block.
    public func persist(withConfiguration readerConfig: FolioReaderConfig, completion: Completion? = nil) {
        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            realm.beginWrite()
            realm.add(self, update: true)
            try realm.commitWrite()
            completion?(nil)
        } catch let error as NSError {
            print("Error on persist highlight: \(error)")
            completion?(error)
        }
    }

    /// Remove a Highlight
    ///
    /// - Parameter readerConfig: Current folio reader configuration.
    public func remove(withConfiguration readerConfig: FolioReaderConfig) {
        do {
            guard let realm = try? Realm(configuration: readerConfig.realmConfiguration) else {
                return
            }
            try realm.write {
                realm.delete(self)
                try realm.commitWrite()
            }
        } catch let error as NSError {
            print("Error on remove highlight: \(error)")
        }
    }

    /// Remove a Highlight by ID
    ///
    /// - Parameters:
    ///   - readerConfig: Current folio reader configuration.
    ///   - highlightId: The ID to be removed
    public static func removeById(withConfiguration readerConfig: FolioReaderConfig, highlightId: String) {
        var highlight: Highlight?
        let predicate = NSPredicate(format:"highlightId = %@", highlightId)

        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            highlight = realm.objects(Highlight.self).filter(predicate).toArray(Highlight.self).first
            highlight?.remove(withConfiguration: readerConfig)
        } catch let error as NSError {
            print("Error on remove highlight by id: \(error)")
        }
    }

    /// Update a Highlight by ID
    ///
    /// - Parameters:
    ///   - readerConfig: Current folio reader configuration.
    ///   - highlightId: The ID to be removed
    ///   - type: The `HighlightStyle`
    public static func updateById(withConfiguration readerConfig: FolioReaderConfig, highlightId: String, type: HighlightStyle) {
        var highlight: Highlight?
        let predicate = NSPredicate(format:"highlightId = %@", highlightId)
        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            highlight = realm.objects(Highlight.self).filter(predicate).toArray(Highlight.self).first
            realm.beginWrite()

            highlight?.type = type.hashValue

            try realm.commitWrite()
            
        } catch let error as NSError {
            print("Error on updateById: \(error)")
        }

    }

    /// Return a list of Highlights with a given ID
    ///
    /// - Parameters:
    ///   - readerConfig: Current folio reader configuration.
    ///   - bookId: Book ID
    ///   - page: Page number
    /// - Returns: Return a list of Highlights
    public static func allByBookId(withConfiguration readerConfig: FolioReaderConfig, bookId: String, andPage page: NSNumber? = nil) -> [Highlight] {
        var highlights: [Highlight]?
        var predicate = NSPredicate(format: "bookId = %@", bookId)
        if let page = page {
            predicate = NSPredicate(format: "bookId = %@ && page = %@", bookId, page)
        }

        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            highlights = realm.objects(Highlight.self).filter(predicate).toArray(Highlight.self)
            return (highlights ?? [])
        } catch let error as NSError {
            print("Error on fetch all by book Id: \(error)")
            return []
        }
    }

    /// Return all Highlights
    ///
    /// - Parameter readerConfig: - readerConfig: Current folio reader configuration.
    /// - Returns: Return all Highlights
    public static func all(withConfiguration readerConfig: FolioReaderConfig) -> [Highlight] {
        var highlights: [Highlight]?
        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            highlights = realm.objects(Highlight.self).toArray(Highlight.self)
            return (highlights ?? [])
        } catch let error as NSError {
            print("Error on fetch all: \(error)")
            return []
        }
    }
}

// MARK: - Static functions

extension Highlight {

    @available(*, deprecated, message: "Shared instance removed. Use a local instance instead.")
    private static var readerConfig : FolioReaderConfig {
        return FolioReader.shared.readerContainer!.readerConfig
    }

    /// Save a Highlight with completion block
    ///
    /// - Parameter completion: Completion block
    @available(*, deprecated, message: "Use 'persist(withConfiguration:completion:)' instead.")
    public func persist(_ completion: Completion? = nil) {
        self.persist(withConfiguration: Highlight.readerConfig, completion: completion)
    }

    /// Return all Highlights
    ///
    /// - Returns: Return all Highlights
    @available(*, deprecated, message: "Use 'all(withConfiguration:)' instead.")
    public static func all() -> [Highlight] {
        return Highlight.all(withConfiguration: Highlight.readerConfig)
    }

    /// Return a list of Highlights with a given ID
    ///
    /// - Parameters:
    ///   - bookId: Book ID
    ///   - page: Page number
    /// - Returns: Return a list of Highlights
    @available(*, deprecated, message: "Use 'allByBookId(withConfiguration:bookId:andPage:)' instead.")
    public static func allByBookId(_ bookId: String, andPage page: NSNumber? = nil) -> [Highlight] {
        return Highlight.allByBookId(withConfiguration: Highlight.readerConfig, bookId: bookId, andPage: page)
    }

    /// Update a Highlight by ID
    ///
    /// - Parameters:
    ///   - highlightId: The ID to be removed
    ///   - type: The `HighlightStyle`
    @available(*, deprecated, message: "Use 'updateById(withConfiguration:highlightId:type:)' instead.")
    public static func updateById(_ highlightId: String, type: HighlightStyle) {
        Highlight.updateById(withConfiguration: Highlight.readerConfig, highlightId: highlightId, type: type)
    }

    /// Remove a Highlight by ID
    ///
    /// - Parameter highlightId: The ID to be removed
    @available(*, deprecated, message: "Use 'removeById(withConfiguration:highlightId:)' instead.")
    public static func removeById(_ highlightId: String) {
        Highlight.removeById(withConfiguration: Highlight.readerConfig, highlightId: highlightId)
    }

    /// Remove a Highlight
    @available(*, deprecated, message: "Use 'remove(withConfiguration:)' instead.")
    public func remove() {
        self.remove(withConfiguration: Highlight.readerConfig)
    }

    /// Remove a Highlight from HTML by ID
    ///
    /// - Parameter highlightId: The ID to be removed
    /// - Returns: The removed id
    @available(*, deprecated, message: "Use 'removeFromHTMLById(withinPage:highlightId:)' instead.")
    @discardableResult public static func removeFromHTMLById(_ highlightId: String) -> String? {
        let page = FolioReader.shared.readerCenter?.currentPage
        return self.removeFromHTMLById(withinPage: page, highlightId: highlightId)
    }
}

// MARK: - HTML Methods

extension Highlight {

    public struct MatchingHighlight {
        var text: String
        var id: String
        var startOffset: String
        var endOffset: String
        var bookId: String
        var currentPage: Int
    }

    /**
     Match a highlight on string.
     */
    public static func matchHighlight(_ matchingHighlight: MatchingHighlight) -> Highlight? {
        let pattern = "<highlight id=\"\(matchingHighlight.id)\" onclick=\".*?\" class=\"(.*?)\">((.|\\s)*?)</highlight>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let matches = regex?.matches(in: matchingHighlight.text, options: [], range: NSRange(location: 0, length: matchingHighlight.text.utf16.count))
        let str = (matchingHighlight.text as NSString)

        let mapped = matches?.map { (match) -> Highlight in
            var contentPre = str.substring(with: NSRange(location: match.range.location-kHighlightRange, length: kHighlightRange))
            var contentPost = str.substring(with: NSRange(location: match.range.location + match.range.length, length: kHighlightRange))

            // Normalize string before save
            contentPre = Highlight.subString(ofContent: contentPre, fromRangeOfString: ">", withPattern: "((?=[^>]*$)(.|\\s)*$)")
            contentPost = Highlight.subString(ofContent: contentPost, fromRangeOfString: "<", withPattern: "^((.|\\s)*?)(?=<)")

            let highlight = Highlight()
            highlight.highlightId = matchingHighlight.id
            highlight.type = HighlightStyle.styleForClass(str.substring(with: match.rangeAt(1))).rawValue
            highlight.date = Foundation.Date()
            highlight.content = Highlight.removeSentenceSpam(str.substring(with: match.rangeAt(2)))
            highlight.contentPre = Highlight.removeSentenceSpam(contentPre)
            highlight.contentPost = Highlight.removeSentenceSpam(contentPost)
            highlight.page = matchingHighlight.currentPage
            highlight.bookId = matchingHighlight.bookId
            highlight.startOffset = (Int(matchingHighlight.startOffset) ?? -1)
            highlight.endOffset = (Int(matchingHighlight.endOffset) ?? -1)

            return highlight
        }

        return mapped?.first
    }

    private static func subString(ofContent content: String, fromRangeOfString rangeString: String, withPattern pattern: String) -> String {
        var updatedContent = content
        if updatedContent.range(of: rangeString) != nil {
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let searchString = regex?.firstMatch(in: updatedContent, options: .reportProgress, range: NSRange(location: 0, length: updatedContent.characters.count))

            if let string = searchString, (string.range.location != NSNotFound) {
                updatedContent = (updatedContent as NSString).substring(with: string.range)
            }
        }

        return updatedContent
    }

    /// Remove a Highlight from HTML by ID
    ///
    /// - Parameters:
    ///   - page: The page containing the HTML.
    ///   - highlightId: The ID to be removed
    /// - Returns: The removed id
    @discardableResult public static func removeFromHTMLById(withinPage page: FolioReaderPage?, highlightId: String) -> String? {
        guard let currentPage = page else { return nil }
        
        if let removedId = currentPage.webView.js("removeHighlightById('\(highlightId)')") {
            return removedId
        } else {
            print("Error removing Highlight from page")
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
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let matches = regex?.matches(in: locator, options: [], range: NSRange(location: 0, length: locator.utf16.count))
            let str = (locator as NSString)
            
            var newLocator = ""
            matches?.forEach({ (match: NSTextCheckingResult) in
                newLocator += str.substring(with: match.rangeAt(1))
            })
            
            if (matches?.count > 0 && newLocator.isEmpty == false) {
                locator = newLocator
            }
            
            return locator
        }
        
        let pattern = "<span class=\"sentence\">((.|\\s)*?)</span>"
        let cleanText = removeFrom(text, withPattern: pattern)
        return cleanText
    }
}
