//
//  FRHighlight.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 26/08/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

enum HighlightStyle: Int {
    case Yellow
    case Green
    case Blue
    case Pink
    case Underline
    
    init () { self = .Yellow }
    
    /**
    Return HighlightStyle for CSS class.
    */
    static func styleForClass(className: String) -> HighlightStyle {
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
    static func classForStyle(style: Int) -> String {
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
    static func colorForStyle(style: Int, nightMode: Bool = false) -> UIColor {
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

class FRHighlight: NSObject {
    var id: String!
    var content: String!
    var contentPre: String!
    var contentPost: String!
    var date: NSDate!
    var page: NSNumber!
    var bookId: String!
    var type: HighlightStyle!
    
    /**
    Match a highlight on string.
    */
    static func matchHighlight(text: String!, andId id: String) -> FRHighlight? {
        let pattern = "<highlight id=\"\(id)\" onclick=\".*?\" class=\"(.*?)\">((.|\\s)*?)</highlight>"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let matches = regex.matchesInString(text, options: [], range: NSRange(location: 0, length: text.utf16.count)) 
        let str = (text as NSString)
        
        let mapped = matches.map { (match) -> FRHighlight in
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
            
            let highlight = FRHighlight()
            highlight.id = id
            highlight.type = HighlightStyle.styleForClass(str.substringWithRange(match.rangeAtIndex(1)))
            highlight.content = str.substringWithRange(match.rangeAtIndex(2))
            highlight.contentPre = contentPre
            highlight.contentPost = contentPost
            highlight.page = currentPageNumber
            highlight.bookId = (kBookId as NSString).stringByDeletingPathExtension
            
            return highlight
        }
        return mapped.first
    }
    
    static func removeById(highlightId: String) -> String? {
        let currentPage = FolioReader.sharedInstance.readerCenter.currentPage
        
        if let removedId = currentPage.webView.js("removeHighlightById('\(highlightId)')") {
            return removedId
        } else {
            print("Error removing Higlight from page")
            return nil
        }
    }
}