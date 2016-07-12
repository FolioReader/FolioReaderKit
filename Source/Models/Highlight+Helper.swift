//
//  Highlight+Helper.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 06/07/16.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import Foundation
import RealmSwift

public typealias Completion = (error: NSError?) -> ()

extension Highlight {
    public static func persistHighlight(object: FRHighlight, completion: Completion? = nil) {
        do {
            let realm = try! Realm()
            
            let newHighlight = Highlight()
            newHighlight.bookId = object.bookId
            newHighlight.content = object.content
            newHighlight.contentPre = object.contentPre
            newHighlight.contentPost = object.contentPost
            newHighlight.date = NSDate()
            newHighlight.highlightId = object.id
            newHighlight.page = object.page
            newHighlight.type = object.type.hashValue
            newHighlight.startOffset = object.startOffset
            newHighlight.endOffset = object.endOffset
            
            realm.beginWrite()
            realm.add(newHighlight, update: true)
            try! realm.commitWrite()
            completion?(error: nil)
        } catch let error as NSError {
            print("Error on persist highlight: \(error)")
            completion?(error: error)
        }
    }
    
    public static func removeById(highlightId: String) {
        var highlight: Highlight?
        let predicate = NSPredicate(format:"highlightId = %@", highlightId)
        
        do {
            let realm = try! Realm()
            highlight = realm.objects(Highlight).filter(predicate).toArray(Highlight).first
            realm.beginWrite()
            realm.delete(highlight!)
            try! realm.commitWrite()
        } catch let error as NSError {
            print("Error on remove highlight: \(error)")
        }
    }
    
    public static func updateById(highlightId: String, type: HighlightStyle) {
        var highlight: Highlight?
        let predicate = NSPredicate(format:"highlightId = %@", highlightId)
        do {
            let realm = try! Realm()
            highlight = realm.objects(Highlight).filter(predicate).toArray(Highlight).first
            realm.beginWrite()
            
            highlight?.type = type.hashValue
            
            try! realm.commitWrite()
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
}