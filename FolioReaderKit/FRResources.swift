//
//  FRResources.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 29/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FRResources: NSObject {
    var resources: [String: FRResource]!
    
    /**
    Adds a resource to the resources.
    */
    func add(resource: FRResource) {
        self.resources[resource.href] = resource
    }
}
