//
//  Highlight.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 11/08/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import Foundation
import RealmSwift

/// A Highlight object
open class Highlight: Object {
    open dynamic var bookId: String!
    open dynamic var content: String!
    open dynamic var contentPost: String!
    open dynamic var contentPre: String!
    open dynamic var date: Foundation.Date!
    open dynamic var highlightId: String!
    open dynamic var page: Int = 0
    open dynamic var type: Int = 0
    open dynamic var startOffset: Int = -1
    open dynamic var endOffset: Int = -1
    
    override open class func primaryKey()-> String {
        return "highlightId"
    }
}

extension Results {
    func toArray<T>(_ ofType: T.Type) -> [T] {
        return flatMap { $0 as? T }
    }
}
