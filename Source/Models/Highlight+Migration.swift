//
//  Highlight+Migration.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 06/07/16.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData

extension Highlight {
    public static func migrateUserDataToRealm() {
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
                let newHighlight = Highlight()
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
            FolioReader.defaults.setBool(true, forKey: "isMigrated")
        } catch let error as NSError {
            print("Error on migrateuserDataToRealm : \(error)")
        }
    }
}