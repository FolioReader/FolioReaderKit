//
//  Highlight.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 11/08/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import Foundation
import RealmSwift

public class Highlight: Object {
    public dynamic var bookId: String!
    public dynamic var content: String!
    public dynamic var contentPost: String!
    public dynamic var contentPre: String!
    public dynamic var date: NSDate!
    public dynamic var highlightId: String!
    public dynamic var page: Int = 0
    public dynamic var type: Int = 0
    public dynamic var startOffset: Int = -1
    public dynamic var endOffset: Int = -1
    
    override public class func primaryKey()-> String {
        return "highlightId"
    }
}

extension Results {
    func toArray<T>(ofType: T.Type) -> [T] {
        return flatMap { $0 as? T }
    }
}