//
//  FRResources.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 29/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FRResources: NSObject {
    var resources = [String: FRResource]()
    
    /**
    Adds a resource to the resources.
    */
    func add(resource: FRResource) {
        self.resources[resource.href] = resource
    }
    
    
    /**
    Gets the first resource (random order) with the give mediatype.
    
    Useful for looking up the table of contents as it's supposed to be the only resource with NCX mediatype.
    */
    func findFirstResource(byMediaType mediaType: MediaType) -> FRResource? {
        for resource in resources.values {
            if resource.mediaType == mediaType {
                return resource
            }
        }
        return nil
    }
}
