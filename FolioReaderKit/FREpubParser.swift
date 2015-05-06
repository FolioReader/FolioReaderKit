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
        let separator = "/"
        bookBasePath = kApplicationDocumentsDirectory + separator + bookName + separator
//        SSZipArchive.unzipFileAtPath(withEpubPath, toDestination: bookBasePath)
        
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
        let containerData = NSData(contentsOfFile: bookBasePath+containerPath, options: .DataReadingMappedAlways, error: nil)
        var error: NSError?
        
        if let xmlDoc = AEXMLDocument(xmlData: containerData!, error: &error) {
//            println(xmlDoc.xmlString)
            let opfResource = FRResource()
            opfResource.href = xmlDoc.root["rootfiles"]["rootfile"].attributes["full-path"] as! String
            opfResource.mediaType = FRMediaType.determineMediaType(xmlDoc.root["rootfiles"]["rootfile"].attributes["full-path"] as! String)
            book.opfResource = opfResource
            resourcesBasePath = bookBasePath + book.opfResource.href.stringByDeletingLastPathComponent + "/"
        }
    }
    
    /**
    Read and parse .opf file.
    */
    private func readOpf() {
        let opfPath = bookBasePath + book.opfResource.href
        let opfData = NSData(contentsOfFile: opfPath, options: .DataReadingMappedAlways, error: nil)
        var error: NSError?
        
        if let xmlDoc = AEXMLDocument(xmlData: opfData!, error: &error) {
            println(xmlDoc.xmlString)
            // Parse manifest resources
            for item in xmlDoc.root["manifest"]["item"].all! {
                let resource = FRResource()
                resource.id = item.attributes["id"] as! String
                resource.href = item.attributes["href"] as! String
                resource.mediaType = FRMediaType.mediaTypesByName[item.attributes["media-type"] as! String]
                book.resources.add(resource)
            }
            
            // Get the first resource with the NCX mediatype
            book.ncxResource = book.resources.findFirstResource(byMediaType: FRMediaType.NCX)
            
            if book.ncxResource == nil {
                println("ERROR: Could not find table of contents resource. The book don't have a NCX resource.")
            }
            
            findTableOfContents()
        }
    }
    
    private func findTableOfContents() {        
        let ncxPath = resourcesBasePath + book.ncxResource.href
        let ncxData = NSData(contentsOfFile: ncxPath, options: .DataReadingMappedAlways, error: nil)
        var error: NSError?
        
        if let xmlDoc = AEXMLDocument(xmlData: ncxData!, error: &error) {
            println(xmlDoc.xmlString)
            
            for item in xmlDoc.root["navMap"]["item"].all! {}
        }
    }
    
    private func readTOCReference() {
        
    }
}
