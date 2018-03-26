//
//  Bookmark.swift
//  FolioReaderKit
//
//  Created by Omar Albeik on 26.03.2018.
//

import Foundation
import RealmSwift

/// A Bookmark object
open class Bookmark: Object {
    @objc open dynamic var bookId: String!
    @objc open dynamic var date: Date!
    @objc open dynamic var bookmarkId: String!
    @objc open dynamic var page: Int = 0

    override open class func primaryKey()-> String {
        return "bookmarkId"
    }
}
