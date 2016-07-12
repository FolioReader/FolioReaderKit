//
//  FRMetadata.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 04/05/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

/**
Represents one of the authors of the book.
*/
struct Author {
    var name: String!
    var role: String!
    var fileAs: String!
    
    init(name: String, role: String, fileAs: String) {
        self.name = name
        self.role = role
        self.fileAs = fileAs
    }
}

/**
A Book's identifier.
*/
struct Identifier {
    var scheme: String!
    var value: String!
    
    init(scheme: String, value: String) {
        self.scheme = scheme
        self.value = value
    }
}

/**
A date and his event.
*/
struct Date {
    var date: String!
    var event: String!
    
    init(date: String, event: String!) {
        self.date = date
        self.event = event
    }
}

/**
A metadata tag data.
*/
struct Meta {
    var name: String?
    var content: String?
    var id: String?
    var property: String?
    var value: String?
    var refines: String?
    
    init(name: String, content: String) {
        self.name = name
        self.content = content
    }
    
    init(id: String, property: String, value: String) {
        self.id = id
        self.property = property
        self.value = value
    }

    init(property: String, value: String, refines: String!) {
        self.property = property
        self.value = value
        self.refines = refines
    }
}

/**
Manages book metadata.
*/
class FRMetadata: NSObject {
    var creators = [Author]()
    var contributors = [Author]()
    var dates = [Date]()
    var language = "en-US"
    var titles = [String]()
    var identifiers = [Identifier]()
    var subjects = [String]()
    var descriptions = [String]()
    var publishers = [String]()
    var format = FRMediaType.EPUB.name
    var rights = [String]()
    var metaAttributes = [Meta]()
    
    func findMetaByName(name: String) -> String? {
        if name.isEmpty {
            return nil
        }
        
        for meta in metaAttributes {
            if meta.name != nil {
                if meta.name == name {
                    return meta.content
                }
            }
        }
        return nil
    }

    func findMetaByProperty(property: String, refinedBy: String?) -> String? {
        if property.isEmpty {
            return nil
        }

        for meta in metaAttributes {
            if meta.property != nil {
                if( meta.property == property && refinedBy == nil && meta.refines == nil){
                    return meta.value
                }
                if( meta.property == property && meta.refines == refinedBy){
                    return meta.value
                }
            }
        }
        return nil
    }

    func findMetaByProperty(property: String) -> String? {
        return findMetaByProperty(property, refinedBy: nil);
    }

}
