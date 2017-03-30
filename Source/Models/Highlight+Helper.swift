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

	// TODO_SMF: replace with a string enum instead.

    /**
     Return HighlightStyle for CSS class.
     */
    public static func styleForClass(_ className: String) -> HighlightStyle {
        switch className {
        case "highlight-yellow": 	return .yellow
        case "highlight-green":		return .green
        case "highlight-blue":		return .blue
        case "highlight-pink":		return .pink
        case "highlight-underline":	return .underline
        default:					return .yellow
        }
    }
    
    /**
     Return CSS class for HighlightStyle.
     */
    public static func classForStyle(_ style: Int) -> String {
        switch style {
        case HighlightStyle.yellow.rawValue:		return "highlight-yellow"
        case HighlightStyle.green.rawValue:			return "highlight-green"
        case HighlightStyle.blue.rawValue:			return "highlight-blue"
        case HighlightStyle.pink.rawValue:			return "highlight-pink"
        case HighlightStyle.underline.rawValue:		return "highlight-underline"
        default:									return "highlight-yellow"
        }
    }

	// TODO_SMF: remove default cases, add optional result.

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

	fileprivate static var readerConfig : FolioReaderConfig {
		// TODO_SMF: remove this getter
		return FolioReader.shared.readerContainer!.readerConfig
	}

	/**
	Save a Highlight with completion block

	- parameter completion: Completion block
	*/
	public func persist(_ completion: Completion? = nil) {
		do {
			let realm = try Realm(configuration: Highlight.readerConfig.realmConfiguration)
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
			let realm = try Realm(configuration: Highlight.readerConfig.realmConfiguration)
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

		do {
			let realm = try Realm(configuration: self.readerConfig.realmConfiguration)
			highlight = realm.objects(Highlight.self).filter(predicate).toArray(Highlight.self).first
			highlight?.remove()
		} catch let error as NSError {
			print("Error on remove highlight by id: \(error)")
		}
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
			let realm = try Realm(configuration: self.readerConfig.realmConfiguration)
			highlight = realm.objects(Highlight.self).filter(predicate).toArray(Highlight.self).first
			realm.beginWrite()

			highlight?.type = type.hashValue

			try realm.commitWrite()
		} catch let error as NSError {
			print("Error on updateById: \(error)")
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
		var predicate = NSPredicate(format: "bookId = %@", bookId)
		if let page = page {
			predicate = NSPredicate(format: "bookId = %@ && page = %@", bookId, page)
		}

		do {
			let realm = try Realm(configuration: self.readerConfig.realmConfiguration)
			highlights = realm.objects(Highlight.self).filter(predicate).toArray(Highlight.self)
			return (highlights ?? [])
		} catch let error as NSError {
			print("Error on fetch all by book Id: \(error)")
			return []
		}
	}

	/**
	Return all Highlights

	- returns: Return all Highlights
	*/
	public static func all() -> [Highlight] {
		var highlights: [Highlight]?
		do {
			let realm = try Realm(configuration: self.readerConfig.realmConfiguration)
			highlights = realm.objects(Highlight.self).toArray(Highlight.self)
			return (highlights ?? [])
		} catch let error as NSError {
			print("Error on fetch all: \(error)")
			return []
		}
	}

	// MARK: HTML Methods

	/**
	Match a highlight on string.
	*/
	public static func matchHighlight(_ text: String, andId id: String, startOffset: String, endOffset: String) -> Highlight? {
		let pattern = "<highlight id=\"\(id)\" onclick=\".*?\" class=\"(.*?)\">((.|\\s)*?)</highlight>"
		let regex = try? NSRegularExpression(pattern: pattern, options: [])
		let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
		let str = (text as NSString)

		let mapped = matches?.map { (match) -> Highlight in
			var contentPre = str.substring(with: NSRange(location: match.range.location-kHighlightRange, length: kHighlightRange))
			var contentPost = str.substring(with: NSRange(location: match.range.location + match.range.length, length: kHighlightRange))

			// Normalize string before save
			contentPre 	= Highlight.subString(ofContent: contentPre, fromRangeOfString: ">", withPattern: "((?=[^>]*$)(.|\\s)*$)")
			contentPost = Highlight.subString(ofContent: contentPost, fromRangeOfString: "<", withPattern: "^((.|\\s)*?)(?=<)")

			let highlight = Highlight()
			highlight.highlightId = id
			highlight.type = HighlightStyle.styleForClass(str.substring(with: match.rangeAt(1))).rawValue
			highlight.date = Foundation.Date()
			highlight.content = Highlight.removeSentenceSpam(str.substring(with: match.rangeAt(2)))
			highlight.contentPre = Highlight.removeSentenceSpam(contentPre)
			highlight.contentPost = Highlight.removeSentenceSpam(contentPost)
			highlight.page = currentPageNumber
			highlight.bookId = (kBookId as NSString).deletingPathExtension
			highlight.startOffset = (Int(startOffset) ?? -1)
			highlight.endOffset = (Int(endOffset) ?? -1)

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
			let regex = try? NSRegularExpression(pattern: pattern, options: [])
			let matches = regex?.matches(in: locator, options: [], range: NSRange(location: 0, length: locator.utf16.count))
			let str = (locator as NSString)

			var newLocator = ""
			// TODO_SMF: check this and add match type
			matches?.forEach( { match in
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
