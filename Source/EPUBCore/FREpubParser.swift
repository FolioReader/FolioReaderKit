//
//  FREpubParser.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 04/05/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import SSZipArchive
import AEXML

class FREpubParser: NSObject, SSZipArchiveDelegate {
    let book = FRBook()
    var bookBasePath: String!
    var resourcesBasePath: String!
    private var epubPathToRemove: String?
    
    /**
    Unzip, delete and read an epub file.
    Returns a FRBook.
    */
    func readEpub(epubPath withEpubPath: String) -> FRBook {
        epubPathToRemove = withEpubPath
        
        // Unzip   
        let bookName = (withEpubPath as NSString).lastPathComponent
        bookBasePath = (kApplicationDocumentsDirectory as NSString).stringByAppendingPathComponent(bookName)
        SSZipArchive.unzipFileAtPath(withEpubPath, toDestination: bookBasePath, delegate: self)
        
        // Skip from backup this folder
        addSkipBackupAttributeToItemAtURL(NSURL(fileURLWithPath: bookBasePath, isDirectory: true))
        
        kBookId = bookName
        readContainer()
        readOpf()
        return book
    }
    
    /**
    Read an unziped epub file.
    Returns a FRBook.
    */
    func readEpub(filePath withFilePath: String) -> FRBook {
        bookBasePath = withFilePath
        kBookId = (withFilePath as NSString).lastPathComponent
        readContainer()
        readOpf()
        return book
    }
    
    /**
    Read and parse container.xml file.
    */
    private func readContainer() {
        let containerPath = "META-INF/container.xml"
        let containerData = try? NSData(contentsOfFile: (bookBasePath as NSString).stringByAppendingPathComponent(containerPath), options: .DataReadingMappedAlways)
        
        do {
            let xmlDoc = try AEXMLDocument(xmlData: containerData!)
            let opfResource = FRResource()
            opfResource.href = xmlDoc.root["rootfiles"]["rootfile"].attributes["full-path"]
            opfResource.mediaType = FRMediaType.determineMediaType(xmlDoc.root["rootfiles"]["rootfile"].attributes["full-path"]!)
            book.opfResource = opfResource
            resourcesBasePath = (bookBasePath as NSString).stringByAppendingPathComponent((book.opfResource.href as NSString).stringByDeletingLastPathComponent)
        } catch {
            print("Cannot read container.xml")
        }
    }
    
    /**
    Read and parse .opf file.
    */
    private func readOpf() {
        let opfPath = (bookBasePath as NSString).stringByAppendingPathComponent(book.opfResource.href)
        let opfData = try? NSData(contentsOfFile: opfPath, options: .DataReadingMappedAlways)
        
        do {
            let xmlDoc = try AEXMLDocument(xmlData: opfData!)
            for item in xmlDoc.root["manifest"]["item"].all! {
                let resource = FRResource()
                resource.id = item.attributes["id"]
                resource.href = item.attributes["href"]
                resource.fullHref = (resourcesBasePath as NSString).stringByAppendingPathComponent(item.attributes["href"]!).stringByRemovingPercentEncoding
                resource.mediaType = FRMediaType.mediaTypesByName[item.attributes["media-type"]!]
                book.resources.add(resource)
            }
            
            // Get the first resource with the NCX mediatype
            book.ncxResource = book.resources.findFirstResource(byMediaType: FRMediaType.NCX)
            
            if book.ncxResource == nil {
                print("ERROR: Could not find table of contents resource. The book don't have a NCX resource.")
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
        } catch {
            print("Cannot read .opf file.")
        }
    }
    
    /**
    Read and parse the Table of Contents.
    */
    private func findTableOfContents() -> [FRTocReference] {
        let ncxPath = (resourcesBasePath as NSString).stringByAppendingPathComponent(book.ncxResource.href)
        let ncxData = try? NSData(contentsOfFile: ncxPath, options: .DataReadingMappedAlways)
        var tableOfContent = [FRTocReference]()
        
        do {
            let xmlDoc = try AEXMLDocument(xmlData: ncxData!)
            for item in xmlDoc.root["navMap"]["navPoint"].all! {
                tableOfContent.append(readTOCReference(item))
            }
        } catch {
            print("Cannot find Table of Contents.")
        }
        return tableOfContent
    }
    
    private func readTOCReference(navpointElement: AEXMLElement) -> FRTocReference {
        var label = ""
        
        if let labelText = navpointElement["navLabel"]["text"].value {
            label = labelText
        }
        
        let reference = navpointElement["content"].attributes["src"]
        let hrefSplit = reference!.characters.split {$0 == "#"}.map { String($0) }
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
                metadata.titles.append(tag.value ?? "")
            }
            
            if tag.name == "dc:identifier" {
                metadata.identifiers.append(Identifier(scheme: tag.attributes["opf:scheme"] ?? "", value: tag.value ?? ""))
            }
            
            if tag.name == "dc:language" {
                metadata.language = tag.value ?? ""
            }
            
            if tag.name == "dc:creator" {
                metadata.creators.append(Author(name: tag.value ?? "", role: tag.attributes["opf:role"] ?? "", fileAs: tag.attributes["opf:file-as"] ?? ""))
            }
            
            if tag.name == "dc:contributor" {
                metadata.creators.append(Author(name: tag.value ?? "", role: tag.attributes["opf:role"] ?? "", fileAs: tag.attributes["opf:file-as"] ?? ""))
            }
            
            if tag.name == "dc:publisher" {
                metadata.publishers.append(tag.value ?? "")
            }
            
            if tag.name == "dc:description" {
                metadata.descriptions.append(tag.value ?? "")
            }
            
            if tag.name == "dc:subject" {
                metadata.subjects.append(tag.value ?? "")
            }
            
            if tag.name == "dc:rights" {
                metadata.rights.append(tag.value ?? "")
            }
            
            if tag.name == "dc:date" {
                metadata.dates.append(Date(date: tag.value ?? "", event: tag.attributes["opf:event"] ?? ""))
            }
            
            if tag.name == "meta" {
                if tag.attributes["name"] != nil {
                    metadata.metaAttributes.append(Meta(name: tag.attributes["name"]!, content: (tag.attributes["content"] ?? "")))
                }
                
                if tag.attributes["property"] != nil && tag.attributes["id"] != nil {
                    metadata.metaAttributes.append(Meta(id: tag.attributes["id"]!, property: tag.attributes["property"]!, value: tag.value ?? ""))
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
            let idref = tag.attributes["idref"]!
            var linear = true
            
            if tag.attributes["linear"] != nil {
                linear = tag.attributes["linear"] == "yes" ? true : false
            }
            
            if book.resources.containsById(idref) {
                spine.spineReferences.append(Spine(resource: book.resources.getById(idref)!, linear: linear))
            }
        }
        return spine
    }
    
    /**
    Add skip to backup file.
    */
    private func addSkipBackupAttributeToItemAtURL(URL: NSURL) -> Bool {
        assert(NSFileManager.defaultManager().fileExistsAtPath(URL.path!))
        
        do {
            try URL.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
            return true
        } catch let error as NSError {
            print("Error excluding \(URL.lastPathComponent) from backup \(error)")
            return false
        }
    }
    
    // MARK: - SSZipArchive delegate
    
    func zipArchiveWillUnzipArchiveAtPath(path: String!, zipInfo: unz_global_info) {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(epubPathToRemove!)
        } catch let error as NSError {
            print(error)
        }
    }
}
