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
    
    /**
     Migrate user data to Realm, before we used Core Data.
     */
    public static func migrateUserDataToRealm() {
//        var highlights: [NSManagedObject]?
//        let coreDataManager = CoreDataManager()
//        
//        do {
//            let fetchRequest = NSFetchRequest(entityName: "Highlight")
//            let sorter: NSSortDescriptor = NSSortDescriptor(key: "date" , ascending: false)
//            fetchRequest.sortDescriptors = [sorter]
//            
//            highlights = try coreDataManager.managedObjectContext.fetch(fetchRequest) as? [NSManagedObject]
//            let realm = try! Realm()
//            
//            realm.beginWrite()
//            realm.deleteAll()
//            for oldHighlight in highlights! {
//                let newHighlight = Highlight()
//                newHighlight.bookId = oldHighlight.value(forKey: "bookId") as? String
//                newHighlight.content = oldHighlight.value(forKey: "content") as? String
//                newHighlight.contentPost = oldHighlight.value(forKey: "contentPost") as? String
//                newHighlight.contentPre = oldHighlight.value(forKey: "contentPre") as? String
//                newHighlight.date = oldHighlight.value(forKey: "date") as? Foundation.Date
//                newHighlight.highlightId = oldHighlight.value(forKey: "highlightId") as? String
//                newHighlight.page = oldHighlight.value(forKey: "page") as! Int
//                newHighlight.type = oldHighlight.value(forKey: "type") as! Int
//                
//                realm.add(newHighlight, update: true)
//            }
//            try! realm.commitWrite()
//            FolioReader.defaults.set(true, forKey: kMigratedToRealm)
//        } catch let error as NSError {
//            print("Error on migrateuserDataToRealm : \(error)")
//        }
    }
}
