//
//  Highlight+Properties.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 06/07/16.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import Foundation
import CoreData

public extension Highlight {

    @NSManaged public var bookId: String
    @NSManaged public var content: String
    @NSManaged public var contentPost: String
    @NSManaged public var contentPre: String
    @NSManaged public var date: NSDate
    @NSManaged public var highlightId: String
    @NSManaged public var page: NSNumber
    @NSManaged public var type: NSNumber

}