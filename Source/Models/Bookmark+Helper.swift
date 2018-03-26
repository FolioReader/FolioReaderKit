//
//  Bookmark+Helper.swift
//  FolioReaderKit
//
//  Created by Omar Albeik on 26.03.2018.
//

import Foundation
import RealmSwift

extension Bookmark {

    public struct MatchingBookmark {
        var id: String
        var bookId: String
        var currentPage: Int
    }

    /**
     Match a bookmark on string.
     */
    public static func matchBookmark(_ matchingBookmark: MatchingBookmark, withConfiguration readerConfig: FolioReaderConfig) -> Bookmark? {

        guard let bookmark = Bookmark.allByBookId(withConfiguration: readerConfig, bookId: matchingBookmark.bookId, andPage: matchingBookmark.currentPage as NSNumber).filter({ $0.bookmarkId == matchingBookmark.id }).first else {

            let bookmark = Bookmark()
            bookmark.bookmarkId = matchingBookmark.id
            bookmark.page = matchingBookmark.currentPage
            bookmark.bookId = matchingBookmark.bookId
            bookmark.date = Date()

            return bookmark
        }

        return bookmark
    }

    /// Save a Bookmark with completion block
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
            print("Error on persist bookmark: \(error)")
            completion?(error)
        }
    }

    /// Remove a Bookmark
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
            print("Error on remove bookmark: \(error)")
        }
    }

    /// Remove a Bookmark by ID
    ///
    /// - Parameters:
    ///   - readerConfig: Current folio reader configuration.
    ///   - bookmarkId: The ID to be removed
    public static func removeById(withConfiguration readerConfig: FolioReaderConfig, bookmarkId: String) {
        var bookmark: Bookmark?
        let predicate = NSPredicate(format:"bookmarkId = %@", bookmarkId)

        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            bookmark = realm.objects(Bookmark.self).filter(predicate).toArray(Bookmark.self).first
            bookmark?.remove(withConfiguration: readerConfig)
        } catch let error as NSError {
            print("Error on remove bookmark by id: \(error)")
        }
    }

    /// Return a list of Bookmarks with a given ID
    ///
    /// - Parameters:
    ///   - readerConfig: Current folio reader configuration.
    ///   - bookId: Book ID
    ///   - page: Page number
    /// - Returns: Return a list of Bookmarks
    public static func allByBookId(withConfiguration readerConfig: FolioReaderConfig, bookId: String, andPage page: NSNumber? = nil) -> [Bookmark] {
        var bookmarks: [Bookmark]?
        var predicate = NSPredicate(format: "bookId = %@", bookId)
        if let page = page {
            predicate = NSPredicate(format: "bookId = %@ && page = %@", bookId, page)
        }

        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            bookmarks = realm.objects(Bookmark.self).filter(predicate).toArray(Bookmark.self)
            return (bookmarks ?? [])
        } catch let error as NSError {
            print("Error on fetch all by book Id: \(error)")
            return []
        }
    }

    /// Return all Bookmarks
    ///
    /// - Parameter readerConfig: - readerConfig: Current folio reader configuration.
    /// - Returns: Return all Bookmarks
    public static func all(withConfiguration readerConfig: FolioReaderConfig) -> [Bookmark] {
        var bookmarks: [Bookmark]?
        do {
            let realm = try Realm(configuration: readerConfig.realmConfiguration)
            bookmarks = realm.objects(Bookmark.self).toArray(Bookmark.self)
            return (bookmarks ?? [])
        } catch let error as NSError {
            print("Error on fetch all: \(error)")
            return []
        }
    }
}
