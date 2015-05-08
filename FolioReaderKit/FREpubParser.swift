//
//  FREpubParser.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 04/05/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import SSZipArchive

class FREpubParser: NSObject {
    let book = FRBook()
    var bookBasePath: String!
    var resourcesBasePath: String!
    
    /**
    Unzip and read an epub file.
    Returns a FRBook.
    */
    func readEpub(epubPath withEpubPath: String) -> FRBook {
        
        // Unzip   
        let bookName = withEpubPath.lastPathComponent.stringByDeletingPathExtension
        bookBasePath = kApplicationDocumentsDirectory.stringByAppendingPathComponent(bookName)
        SSZipArchive.unzipFileAtPath(withEpubPath, toDestination: bookBasePath)
        
        readContainer()
        readOpf()
        return book
    }
    
    /**
    Read an unziped epub file.
    Returns a FRBook.
    */
    func readEpub(filePath withFilePath: String) -> FRBook {
        
        return book
    }
    
    /**
    Read and parse container.xml file.
    */
    private func readContainer() {
        let containerPath = "META-INF/container.xml"
        let containerData = NSData(contentsOfFile: bookBasePath.stringByAppendingPathComponent(containerPath), options: .DataReadingMappedAlways, error: nil)
        var error: NSError?
        
        if let xmlDoc = AEXMLDocument(xmlData: containerData!, error: &error) {
            let opfResource = FRResource()
            opfResource.href = xmlDoc.root["rootfiles"]["rootfile"].attributes["full-path"] as! String
            opfResource.mediaType = FRMediaType.determineMediaType(xmlDoc.root["rootfiles"]["rootfile"].attributes["full-path"] as! String)
            book.opfResource = opfResource
            resourcesBasePath = bookBasePath.stringByAppendingPathComponent(book.opfResource.href.stringByDeletingLastPathComponent)
        }
    }
    
    /**
    Read and parse .opf file.
    */
    private func readOpf() {
        let opfPath = bookBasePath.stringByAppendingPathComponent(book.opfResource.href)
        let opfData = NSData(contentsOfFile: opfPath, options: .DataReadingMappedAlways, error: nil)
        var error: NSError?
        
        if let xmlDoc = AEXMLDocument(xmlData: opfData!, error: &error) {
            for item in xmlDoc.root["manifest"]["item"].all! {
                let resource = FRResource()
                resource.id = item.attributes["id"] as! String
                resource.href = item.attributes["href"] as! String
                resource.fullHref = resourcesBasePath.stringByAppendingPathComponent(item.attributes["href"] as! String).stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                resource.mediaType = FRMediaType.mediaTypesByName[item.attributes["media-type"] as! String]
                book.resources.add(resource)
            }
            
            // Get the first resource with the NCX mediatype
            book.ncxResource = book.resources.findFirstResource(byMediaType: FRMediaType.NCX)
            
            if book.ncxResource == nil {
                println("ERROR: Could not find table of contents resource. The book don't have a NCX resource.")
            }
            
            // The book TOC
            book.tableOfContents = findTableOfContents()
            
            // Read metadata
            book.metadata = readMetadata(xmlDoc.root["metadata"].children)
            
            // Read the cover image
            let coverImageID = book.metadata.findMetaByName("cover")
            if (coverImageID != nil && book.resources.containsById(coverImageID!)) {
                book.coverImage = book.resources.getById(coverImageID!)
            }
            
            // Read Spine
            book.spine = readSpine(xmlDoc.root["spine"].children)
        }
    }
    
    /**
    Read and parse the Table of Contents.
    */
    private func findTableOfContents() -> [FRTocReference] {
        let ncxPath = resourcesBasePath.stringByAppendingPathComponent(book.ncxResource.href)
        let ncxData = NSData(contentsOfFile: ncxPath, options: .DataReadingMappedAlways, error: nil)
        var error: NSError?
        
        var tableOfContent = [FRTocReference]()
        
        if let xmlDoc = AEXMLDocument(xmlData: ncxData!, error: &error) {
            for item in xmlDoc.root["navMap"]["navPoint"].all! {
                tableOfContent.append(readTOCReference(item))
            }
        }
        
        return tableOfContent
    }
    
    private func readTOCReference(navpointElement: AEXMLElement) -> FRTocReference {
        let label = navpointElement["navLabel"]["text"].value as String!
        let reference = navpointElement["content"].attributes["src"] as! String!
        
        let hrefSplit = split(reference) {$0 == "#"}
        let fragmentID = hrefSplit.count > 1 ? hrefSplit[1] : ""
        let href = hrefSplit[0]
        
        let resource = book.resources.getByHref(href)
        let toc = FRTocReference(title: label, resource: resource!, fragmentID: fragmentID)
        
        if navpointElement["navPoint"].all != nil {
            for navPoint in navpointElement["navPoint"].all! {
                toc.children.append(readTOCReference(navPoint))
            }
        }        
        return toc
    }
    
    /**
    Read and parse <metadata>.
    */
    private func readMetadata(tags: [AEXMLElement]) -> FRMetadata {
        let metadata = FRMetadata()
        
        for tag in tags {
            if tag.name == "dc:title" {
                metadata.titles.append(tag.value!)
            }
            
            if tag.name == "dc:identifier" {
                metadata.identifiers.append(Identifier(scheme: tag.attributes["opf:scheme"] != nil ? tag.attributes["opf:scheme"] as! String : "", value: tag.value!))
            }
            
            if tag.name == "dc:language" {
                metadata.language = tag.value != nil ? tag.value! : ""
            }
            
            if tag.name == "dc:creator" {
                metadata.creators.append(Author(name: tag.value!, role: tag.attributes["opf:role"] != nil ? tag.attributes["opf:role"] as! String : "", fileAs: tag.attributes["opf:file-as"] != nil ? tag.attributes["opf:file-as"] as! String : ""))
            }
            
            if tag.name == "dc:contributor" {
                metadata.creators.append(Author(name: tag.value!, role: tag.attributes["opf:role"] != nil ? tag.attributes["opf:role"] as! String : "", fileAs: tag.attributes["opf:file-as"] != nil ? tag.attributes["opf:file-as"] as! String : ""))
            }
            
            if tag.name == "dc:publisher" {
                metadata.publishers.append(tag.value != nil ? tag.value! : "")
            }
            
            if tag.name == "dc:description" {
                metadata.descriptions.append(tag.value != nil ? tag.value! : "")
            }
            
            if tag.name == "dc:subject" {
                metadata.subjects.append(tag.value != nil ? tag.value! : "")
            }
            
            if tag.name == "dc:rights" {
                metadata.rights.append(tag.value != nil ? tag.value! : "")
            }
            
            if tag.name == "dc:date" {
                metadata.dates.append(Date(date: tag.value!, event: tag.attributes["opf:event"] != nil ? tag.attributes["opf:event"] as! String : ""))
            }
            
            if tag.name == "meta" {
                if tag.attributes["name"] != nil {
                    metadata.metaAttributes.append(Meta(name: tag.attributes["name"] as! String, content: (tag.attributes["content"] != nil ? tag.attributes["content"] as! String : "")))
                }
                
                if tag.attributes["property"] != nil && tag.attributes["id"] != nil {
                    metadata.metaAttributes.append(Meta(id: tag.attributes["id"] as! String, property: tag.attributes["property"] as! String, value: tag.value != nil ? tag.value! : ""))
                }
            }
            
        }
        return metadata
    }
    
    /**
    Read and parse <spine>.
    */
    private func readSpine(tags: [AEXMLElement]) -> FRSpine {
        let spine = FRSpine()
        
        for tag in tags {
            let idref = tag.attributes["idref"] as! String
            var linear = true
            
            if tag.attributes["linear"] != nil {
                linear = tag.attributes["linear"] as! String == "yes" ? true : false
            }
            
            if book.resources.containsById(idref) {
                spine.spineReferences.append(Spine(resource: book.resources.getById(idref)!, linear: linear))
            }
        }
        
        return spine
    }
}
