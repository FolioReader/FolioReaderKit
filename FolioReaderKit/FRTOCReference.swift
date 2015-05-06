//
//  FRTOCReference.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 06/05/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FRTOCReference: NSObject {
    var resource: FRResource!
    var title: String!
    var fragmentID: String?
    var children: [FRTOCReference]!
    
    convenience init(title:String, resource: FRResource, fragmentID: String = "") {
        self.init(title: title, resource: resource, fragmentID: fragmentID, children: [FRTOCReference]())
    }
    
    init(title:String, resource: FRResource, fragmentID: String, children: [FRTOCReference]) {
        self.resource = resource
        self.title = title
        self.fragmentID = fragmentID
        self.children = children
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        let obj = object as! FRTOCReference
        return obj.title == self.title && obj.fragmentID == self.fragmentID
    }
}
