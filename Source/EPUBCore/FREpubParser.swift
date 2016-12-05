//
//  FREpubParser.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 04/05/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
#if COCOAPODS
import SSZipArchive
#else
import ZipArchive
#endif
import AEXML

class FREpubParser: NSObject, SSZipArchiveDelegate {
    let book = FRBook()
    var bookBasePath: String!
    var resourcesBasePath: String!
    var shouldRemoveEpub = true
    fileprivate var epubPathToRemove: String?
    
    /**
     Parse the Cover Image from an epub file.
     Returns an UIImage.
     */
    func parseCoverImage(_ epubPath: String) -> UIImage? {
        guard let book = readEpub(epubPath: epubPath, removeEpub: false), let coverImage = book.coverImage else {
            return nil
        }
        return UIImage(contentsOfFile: coverImage.fullHref)
    }

    func parseTitle(_ epubPath: String) -> String? {

        guard let book = readEpub(epubPath: epubPath, removeEpub: false), let title = book.title() else {
            return nil
        }
        return title
    }

    func parseAuthorName(_ epubPath: String) -> String? {
        guard let book = readEpub(epubPath: epubPath, removeEpub: false), let authorName = book.authorName() else {
        return nil
        }
        return authorName
    }



    
    /**
     Unzip, delete and read an epub file.
     Returns a FRBook.
    */
    func readEpub(epubPath withEpubPath: String, removeEpub: Bool = true, unzipPath: String? = nil) -> FRBook? {
        epubPathToRemove = withEpubPath
        shouldRemoveEpub = removeEpub

        var isDir: ObjCBool = false
        let fileManager = FileManager.default
        let bookName = (withEpubPath as NSString).lastPathComponent

        if let bookUnzipPath = FolioReader.shared.unzipPath, fileManager.fileExists(atPath: bookUnzipPath) {
            bookBasePath = bookUnzipPath
        } else {
            bookBasePath = kApplicationDocumentsDirectory
        }

        bookBasePath = (bookBasePath as NSString).appendingPathComponent(bookName)

        guard fileManager.fileExists(atPath: withEpubPath) else {
            print("Epub file does not exist.")
            return nil
        }
        
        // Unzip if necessary
        var needsUnzip = false
        if fileManager.fileExists(atPath: bookBasePath, isDirectory:&isDir) {
            if !isDir.boolValue { needsUnzip = true }
        } else {
            needsUnzip = true
        }
        
        if needsUnzip {
            SSZipArchive.unzipFile(atPath: withEpubPath, toDestination: bookBasePath, delegate: self)
        }
        
        // Skip from backup this folder
        addSkipBackupAttributeToItemAtURL(URL(fileURLWithPath: bookBasePath, isDirectory: true))
        
        kBookId = bookName
        readContainer()
        readOpf()
        return book
    }
    
    /**
     Read and parse container.xml file.
    */
    fileprivate func readContainer() {
        let containerPath = "META-INF/container.xml"
        
        do {
            let containerData = try Data(contentsOf: URL(fileURLWithPath: (bookBasePath as NSString).appendingPathComponent(containerPath)), options: .alwaysMapped)
            let xmlDoc = try AEXMLDocument(xml: containerData)
            let opfResource = FRResource()
            opfResource.href = xmlDoc.root["rootfiles"]["rootfile"].attributes["full-path"]
            opfResource.mediaType = FRMediaType.determineMediaType(xmlDoc.root["rootfiles"]["rootfile"].attributes["full-path"]!)
            book.opfResource = opfResource
            resourcesBasePath = (bookBasePath as NSString).appendingPathComponent((book.opfResource.href as NSString).deletingLastPathComponent)
        } catch {
            print("Cannot read container.xml")
        }
    }
    
    /**
     Read and parse .opf file.
    */
    fileprivate func readOpf() {
        let opfPath = (bookBasePath as NSString).appendingPathComponent(book.opfResource.href)
        var identifier: String?
        
        do {
            let opfData = try Data(contentsOf: URL(fileURLWithPath: opfPath), options: .alwaysMapped)
            let xmlDoc = try AEXMLDocument(xml: opfData)
            
            // Base OPF info
            if let package = xmlDoc.children.first {
                identifier = package.attributes["unique-identifier"]
                
                if let version = package.attributes["version"] {
                    book.version = Double(version)
                }
            }
            
            // Parse and save each "manifest item"
            for item in xmlDoc.root["manifest"]["item"].all! {
                let resource = FRResource()
                resource.id = item.attributes["id"]
                resource.properties = item.attributes["properties"]
                resource.href = item.attributes["href"]
                resource.fullHref = (resourcesBasePath as NSString).appendingPathComponent(resource.href).removingPercentEncoding
                resource.mediaType = FRMediaType.mediaTypeByName(item.attributes["media-type"]!, fileName: resource.href)
                resource.mediaOverlay = item.attributes["media-overlay"]
                
                // if a .smil file is listed in resources, go parse that file now and save it on book model
                if (resource.mediaType != nil && resource.mediaType == FRMediaType.SMIL) {
                    readSmilFile(resource)
                }
                
                book.resources.add(resource)
            }
            
            book.smils.basePath = resourcesBasePath
            
            // Read metadata
            book.metadata = readMetadata(xmlDoc.root["metadata"].children)
            
            // Read the book unique identifier
            if let uniqueIdentifier = book.metadata.findIdentifierById(identifier) {
                book.uniqueIdentifier = uniqueIdentifier
            }

            // Read the cover image
            let coverImageId = book.metadata.findMetaByName("cover")
            if let coverResource = book.resources.findById(coverImageId) {
                book.coverImage = coverResource
            } else if let coverResource = book.resources.findByProperties("cover-image") {
                book.coverImage = coverResource
            }
        
            // Specific TOC for ePub 2 and 3
            // Get the first resource with the NCX mediatype
            if let tocResource = book.resources.findByMediaType(FRMediaType.NCX) {
                book.tocResource = tocResource
            } else if let tocResource = book.resources.findByExtension(FRMediaType.NCX.defaultExtension) {
                // Non-standard books may use wrong mediatype, fallback with extension
                book.tocResource = tocResource
            } else if let tocResource = book.resources.findByProperties("nav") {
                book.tocResource = tocResource
            }
            
            assert(book.tocResource != nil, "ERROR: Could not find table of contents resource. The book don't have a TOC resource.")
            
            // The book TOC
            book.tableOfContents = findTableOfContents()
            book.flatTableOfContents = createFlatTOC()
            
            // Read Spine
            let spine = xmlDoc.root["spine"]
            book.spine = readSpine(spine.children)
            
            // Page progress direction `ltr` or `rtl`
            if let pageProgressionDirection = spine.attributes["page-progression-direction"] {
                book.spine.pageProgressionDirection = pageProgressionDirection
            }
        } catch {
            print("Cannot read .opf file.")
        }
    }
    
    /**
     Reads and parses a .smil file
    */
    fileprivate func readSmilFile(_ resource: FRResource) {
        do {
            let smilData = try Data(contentsOf: URL(fileURLWithPath: resource.fullHref), options: .alwaysMapped)
            var smilFile = FRSmilFile(resource: resource)
            let xmlDoc = try AEXMLDocument(xml: smilData)
            
            let children = xmlDoc.root["body"].children

            if children.count > 0 {
                smilFile.data.append(contentsOf: readSmilFileElements(children))
            }
            
            book.smils.add(smilFile)
        } catch {
            print("Cannot read .smil file: "+resource.href)
        }
    }
    
    fileprivate func readSmilFileElements(_ children:[AEXMLElement]) -> [FRSmilElement] {
        var data = [FRSmilElement]()

        // convert each smil element to a FRSmil object
        for item in children {

            let smil = FRSmilElement(name: item.name, attributes: item.attributes)

            // if this element has children, convert them to objects too
            if item.children.count > 0 {
                smil.children.append(contentsOf: readSmilFileElements(item.children))
            }

            data.append(smil)
        }

        return data
    }

    /**
     Read and parse the Table of Contents.
    */
    fileprivate func findTableOfContents() -> [FRTocReference] {
        var tableOfContent = [FRTocReference]()
        var tocItems: [AEXMLElement]?
        guard let tocResource = book.tocResource else { return tableOfContent }
        let tocPath = (resourcesBasePath as NSString).appendingPathComponent(tocResource.href)
        
        do {
            if tocResource.mediaType == FRMediaType.NCX {
                let ncxData = try Data(contentsOf: URL(fileURLWithPath: tocPath), options: .alwaysMapped)
                let xmlDoc = try AEXMLDocument(xml: ncxData)
                if let itemsList = xmlDoc.root["navMap"]["navPoint"].all {
                    tocItems = itemsList
                }
            } else {
                let tocData = try Data(contentsOf: URL(fileURLWithPath: tocPath), options: .alwaysMapped)
                let xmlDoc = try AEXMLDocument(xml: tocData)
                
                if let nav = xmlDoc.root["body"]["nav"].first, let itemsList = nav["ol"]["li"].all {
                    tocItems = itemsList
                } else if let nav = findNavTag(xmlDoc.root["body"]), let itemsList = nav["ol"]["li"].all {
                    tocItems = itemsList
                }
            }
        } catch {
            print("Cannot find Table of Contents.")
        }
        
        guard let items = tocItems else { return tableOfContent }
        
        for item in items {
            tableOfContent.append(readTOCReference(item))
        }
        
        return tableOfContent
    }
    
    /**
     Recursively finds a `<nav>` tag on html
     
     - parameter element: A `AEXMLElement`, usually the `<body>`
     - returns: If found the `<nav>` `AEXMLElement`
     */
    @discardableResult func findNavTag(_ element: AEXMLElement) -> AEXMLElement? {
        for element in element.children {
            if let nav = element["nav"].first {
                return nav
            } else {
                findNavTag(element)
            }
        }
        return nil
    }
    
    fileprivate func readTOCReference(_ navpointElement: AEXMLElement) -> FRTocReference {
        var label = ""
        
        if book.tocResource!.mediaType == FRMediaType.NCX {
            if let labelText = navpointElement["navLabel"]["text"].value {
                label = labelText
            }
            
            let reference = navpointElement["content"].attributes["src"]
            let hrefSplit = reference!.characters.split {$0 == "#"}.map { String($0) }
            let fragmentID = hrefSplit.count > 1 ? hrefSplit[1] : ""
            let href = hrefSplit[0]
            
            let resource = book.resources.findByHref(href)
            let toc = FRTocReference(title: label, resource: resource, fragmentID: fragmentID)
            
            // Recursively find child
            if let navPoints = navpointElement["navPoint"].all {
                for navPoint in navPoints {
                    toc.children.append(readTOCReference(navPoint))
                }
            }
            return toc
        } else {
            if let labelText = navpointElement["a"].value {
                label = labelText
            }
            
            let reference = navpointElement["a"].attributes["href"]
            let hrefSplit = reference!.characters.split {$0 == "#"}.map { String($0) }
            let fragmentID = hrefSplit.count > 1 ? hrefSplit[1] : ""
            let href = hrefSplit[0]
            
            let resource = book.resources.findByHref(href)
            let toc = FRTocReference(title: label, resource: resource, fragmentID: fragmentID)
            
            // Recursively find child
            if let nav = navpointElement["ol"]["li"].all {
                for item in nav {
                    toc.children.append(readTOCReference(item))
                }
            }
            return toc
        }
    }
    
    // MARK: - Recursive add items to a list
    
    func createFlatTOC() -> [FRTocReference] {
        var tocItems = [FRTocReference]()
        
        for item in book.tableOfContents {
            tocItems.append(item)
            tocItems.append(contentsOf: countTocChild(item))
        }
        return tocItems
    }
    
    func countTocChild(_ item: FRTocReference) -> [FRTocReference] {
        var tocItems = [FRTocReference]()
        
        if item.children.count > 0 {
            for item in item.children {
                tocItems.append(item)
            }
        }
        return tocItems
    }
    
    /**
     Read and parse <metadata>.
    */
    fileprivate func readMetadata(_ tags: [AEXMLElement]) -> FRMetadata {
        let metadata = FRMetadata()
        
        for tag in tags {
            if tag.name == "dc:title" {
                metadata.titles.append(tag.value ?? "")
            }
            
            if tag.name == "dc:identifier" {
                let identifier = Identifier(id: tag.attributes["id"], scheme: tag.attributes["opf:scheme"], value: tag.value)
                metadata.identifiers.append(identifier)
            }
            
            if tag.name == "dc:language" {
                let language = tag.value ?? metadata.language
                metadata.language = language != "en" ? language : metadata.language
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
                
                if tag.attributes["property"] != nil {
                    metadata.metaAttributes.append(Meta(property: tag.attributes["property"]!, value: tag.value != nil ? tag.value! : "", refines: tag.attributes["refines"] != nil ? tag.attributes["refines"] : nil))
                }

            }
        }
        
        return metadata
    }
    
    /**
     Read and parse <spine>.
    */
    fileprivate func readSpine(_ tags: [AEXMLElement]) -> FRSpine {
        let spine = FRSpine()
        
        for tag in tags {
            let idref = tag.attributes["idref"]!
            var linear = true
            
            if tag.attributes["linear"] != nil {
                linear = tag.attributes["linear"] == "yes" ? true : false
            }
            
            if book.resources.containsById(idref) {
                spine.spineReferences.append(Spine(resource: book.resources.findById(idref)!, linear: linear))
            }
        }
        return spine
    }
    
    /**
     Add skip to backup file.
    */
    @discardableResult fileprivate func addSkipBackupAttributeToItemAtURL(_ URL: Foundation.URL) -> Bool {
        assert(FileManager.default.fileExists(atPath: URL.path))
        
        do {
            try (URL as NSURL).setResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
            return true
        } catch let error as NSError {
            print("Error excluding \(URL.lastPathComponent) from backup \(error)")
            return false
        }
    }
    
    // MARK: - SSZipArchive delegate
    
    func zipArchiveWillUnzipArchive(atPath path: String, zipInfo: unz_global_info) {
        if shouldRemoveEpub {
            do {
                try FileManager.default.removeItem(atPath: epubPathToRemove!)
            } catch let error as NSError {
                print(error)
            }
        }
    }
}
