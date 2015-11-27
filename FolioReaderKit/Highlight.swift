//
//  Highlight.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 11/08/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import Foundation
import CoreData

@objc(Highlight)
class Highlight: NSManagedObject {

    @NSManaged var bookId: String
    @NSManaged var content: String
    @NSManaged var contentPost: String
    @NSManaged var contentPre: String
    @NSManaged var date: NSDate
    @NSManaged var highlightId: String
    @NSManaged var page: NSNumber
    @NSManaged var type: NSNumber

}

public typealias Completion = (error: NSError?) -> ()
let coreDataManager = CoreDataManager()

extension Highlight {
    
    static func persistHighlight(object: FRHighlight, completion: Completion?) {
        var highlight: Highlight?
        
        do {
            let fetchRequest = NSFetchRequest(entityName: "Highlight")
            fetchRequest.predicate = NSPredicate(format:"highlightId = %@", object.id)
            highlight = try coreDataManager.managedObjectContext.executeFetchRequest(fetchRequest).last as? Highlight
        } catch let error as NSError {
            print(error)
            highlight = nil
        }
  
        if highlight != nil {
            highlight!.content = object.content
            highlight!.contentPre = object.contentPre
            highlight!.contentPost = object.contentPost
            highlight!.date = object.date
            highlight!.type = object.type.hashValue
        } else {
            highlight = NSEntityDescription.insertNewObjectForEntityForName("Highlight", inManagedObjectContext: coreDataManager.managedObjectContext) as? Highlight
            coreDataManager.saveContext()

            highlight!.bookId = object.bookId
            highlight!.content = object.content
            highlight!.contentPre = object.contentPre
            highlight!.contentPost = object.contentPost
            highlight!.date = NSDate()
            highlight!.highlightId = object.id
            highlight!.page = object.page
            highlight!.type = object.type.hashValue
        }

        // Save
        if coreDataManager.managedObjectContext.hasChanges {
            do {
                try coreDataManager.managedObjectContext.save()
                if (completion != nil) {
                    completion!(error: nil)
                }
            } catch let error as NSError {
                if (completion != nil) {
                    completion!(error: error)
                }
            }
        }
    }
    
    static func removeHighlightId(highlightId: String) {
        var highlight: Highlight?
        
        do {
            let fetchRequest = NSFetchRequest(entityName: "Highlight")
            fetchRequest.predicate = NSPredicate(format:"highlightId = %@", highlightId)
            highlight = try coreDataManager.managedObjectContext.executeFetchRequest(fetchRequest).last as? Highlight
        } catch let error as NSError {
            print(error)
            highlight = nil
        }
        
        if highlight != nil {
            coreDataManager.managedObjectContext.deleteObject(highlight!)
            coreDataManager.saveContext()
        }
    }
    
    static func updateHighlightId(highlightId: String, type: HighlightStyle) {
        var highlight: Highlight?
        
        do {
            let fetchRequest = NSFetchRequest(entityName: "Highlight")
            fetchRequest.predicate = NSPredicate(format:"highlightId = %@", highlightId)
            highlight = try coreDataManager.managedObjectContext.executeFetchRequest(fetchRequest).last as? Highlight
        } catch let error as NSError {
            print(error)
            highlight = nil
        }
        
        if highlight != nil {
            highlight?.type = type.hashValue
            coreDataManager.saveContext()
        }
    }
    
    static func allByBookId(bookId: String, andPage page: NSNumber) -> [Highlight] {
        var highlights: [Highlight]?
        
        do {
            let fetchRequest = NSFetchRequest(entityName: "Highlight")
            fetchRequest.predicate = NSPredicate(format: "bookId = %@ && page = %@", bookId, page)
            highlights = try coreDataManager.managedObjectContext.executeFetchRequest(fetchRequest) as? [Highlight]
        } catch let error as NSError {
            print(error)
            highlights = nil
        }
        
        if highlights != nil {
            return highlights!
        } else {
            return [Highlight]()
        }
    }
    
    static func allByBookId(bookId: String) -> [Highlight] {
        var highlights: [Highlight]?
        
        do {
            let fetchRequest = NSFetchRequest(entityName: "Highlight")
            let sorter: NSSortDescriptor = NSSortDescriptor(key: "date" , ascending: true)
            
            fetchRequest.predicate = NSPredicate(format: "bookId = %@", bookId)
            fetchRequest.sortDescriptors = [sorter]
            highlights = try coreDataManager.managedObjectContext.executeFetchRequest(fetchRequest) as? [Highlight]
        } catch let error as NSError {
            print(error)
            highlights = nil
        }
        
        if highlights != nil {
            return highlights!
        } else {
            return [Highlight]()
        }
    }
}