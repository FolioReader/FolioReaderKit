//
//  Highlight.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 11/08/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData

public typealias Completion = (error: NSError?) -> ()

class Highlight: Object {
    
    dynamic var bookId:String!
    dynamic var content:String!
    dynamic var contentPost:String!
    dynamic var contentPre:String!
    dynamic var date:NSDate!
    dynamic var highlightId:String!
    dynamic var page:Int = 0
    dynamic var type:Int = 0
    dynamic var startOffset:Int = -1
    dynamic var endOffset:Int = -1
    
    override class func primaryKey()-> String{
        return "highlightId"
    }
    
    public static func persistHighlight(object: FRHighlight, completion: Completion?) {
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
        } catch let error as NSError {
            print("Error on persist highlight: \(error)")
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
    
    public static func migrateUserDataToRealm(){
        var highlights: [NSManagedObject]?
        let coreDataManager = CoreDataManager()
        
        do {
            let fetchRequest = NSFetchRequest(entityName: "Highlight")
            let sorter: NSSortDescriptor = NSSortDescriptor(key: "date" , ascending: false)
            fetchRequest.sortDescriptors = [sorter]
            
            highlights = try coreDataManager.managedObjectContext.executeFetchRequest(fetchRequest) as? [NSManagedObject]
            let realm = try! Realm()
            
            realm.beginWrite()
            realm.deleteAll()
            for oldHighlight in highlights! {
                var newHighlight = Highlight()
                newHighlight.bookId = oldHighlight.valueForKey("bookId") as! String
                newHighlight.content = oldHighlight.valueForKey("content") as! String
                newHighlight.contentPost = oldHighlight.valueForKey("contentPost") as! String
                newHighlight.contentPre = oldHighlight.valueForKey("contentPre") as! String
                newHighlight.date = oldHighlight.valueForKey("date") as! NSDate
                newHighlight.highlightId = oldHighlight.valueForKey("highlightId") as! String
                newHighlight.page = oldHighlight.valueForKey("page") as! Int
                newHighlight.type = oldHighlight.valueForKey("type") as! Int
                
                realm.add(newHighlight, update: true)
            }
            try! realm.commitWrite()
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isMigrated")
        } catch let error as NSError {
            print("Error on migrateuserDataToRealm : \(error)")
        }
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        return flatMap { $0 as? T }
    }
}