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
            if resource.mediaType != nil && resource.mediaType == mediaType {
                return resource
            }
        }
        return nil
    }
    
    /**
     Gets the first resource (random order) with the give extension.
     
     Useful for looking up the table of contents as it's supposed to be the only resource with NCX extension.
     */
    func findFirstResource(byExtension ext: String) -> FRResource? {
        for resource in resources.values {
            if resource.mediaType != nil && resource.mediaType.defaultExtension == ext {
                return resource
            }
        }
        return nil
    }
    
    /**
    Whether there exists a resource with the given href.
    */
    func containsByHref(href: String) -> Bool {
        if href.isEmpty {
            return false
        }
        
        return resources.keys.contains(href)
    }
    
    /**
    Whether there exists a resource with the given id.
    */
    func containsById(id: String) -> Bool {
        if id.isEmpty {
            return false
        }
        
        for resource in resources.values {
            if resource.id == id {
                return true
            }
        }
        return false
    }
    
    /**
    Gets the resource with the given href.
    */
    func getByHref(href: String) -> FRResource? {
        if href.isEmpty {
            return nil
        }
        return resources[href]
    }
    
    /**
    Gets the resource with the given href.
    */
    func getById(id: String) -> FRResource? {
        for resource in resources.values {
            if resource.id == id {
                return resource
            }
        }
        return nil
    }
}
