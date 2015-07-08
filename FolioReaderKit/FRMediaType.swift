//
//  FRMediaType.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 29/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

/**
MediaType is used to tell the type of content a resource is.

Examples of mediatypes are image/gif, text/css and application/xhtml+xml
*/
struct MediaType {
    var name: String
    var defaultExtension: String!
    var extensions: [String]!
    
    init(name: String, defaultExtension: String) {
        self.name = name
        self.defaultExtension = defaultExtension
        self.extensions = [defaultExtension]
    }
    
    init(name: String, defaultExtension: String, extensions: [String]) {
        self.name = name
        self.defaultExtension = defaultExtension
        self.extensions = extensions
    }
}

// MARK: Equatable

extension MediaType: Equatable {}

/**
Compare if two mediatypes are equal or different.
*/
func ==(lhs: MediaType, rhs: MediaType) -> Bool {
    return lhs.name == rhs.name && lhs.defaultExtension == rhs.defaultExtension
}


/**
Manages mediatypes that are used by epubs.
*/
class FRMediaType: NSObject {
    static var XHTML = MediaType(name: "application/xhtml+xml", defaultExtension: ".xhtml", extensions: [".htm", ".html", ".xhtml", ".xml"])
    static var EPUB = MediaType(name: "application/epub+zip", defaultExtension: ".epub")
    static var NCX = MediaType(name: "application/x-dtbncx+xml", defaultExtension: ".ncx")
    static var OPF = MediaType(name: "application/oebps-package+xml", defaultExtension: ".opf")

    static var JAVASCRIPT = MediaType(name: "text/javascript", defaultExtension: ".js")
    static var CSS = MediaType(name: "text/css", defaultExtension: ".css")

    // images
    static var JPG = MediaType(name: "image/jpeg", defaultExtension: ".jpg", extensions: [".jpg", ".jpeg"])
    static var PNG = MediaType(name: "image/png", defaultExtension: ".png")
    static var GIF = MediaType(name: "image/gif", defaultExtension: ".gif")
    static var SVG = MediaType(name: "image/svg+xml", defaultExtension: ".svg")

    // fonts
    static var TTF = MediaType(name: "application/x-truetype-font", defaultExtension: ".ttf")
    static var OPENTYPE = MediaType(name: "application/vnd.ms-opentype", defaultExtension: ".otf")
    static var WOFF = MediaType(name: "application/font-woff", defaultExtension: ".woff")

    // audio
    static var MP3 = MediaType(name: "audio/mpeg", defaultExtension: ".mp3")
    static var MP4 = MediaType(name: "audio/mp4", defaultExtension: ".mp4")
    static var OGG = MediaType(name: "audio/ogg", defaultExtension: ".ogg")

    static var SMIL = MediaType(name: "application/smil+xml", defaultExtension: ".smil")
    static var XPGT = MediaType(name: "application/adobe-page-template+xml", defaultExtension: ".xpgt")
    static var PLS = MediaType(name: "application/pls+xml", defaultExtension: ".pls")

    static var mediatypes = [XHTML, EPUB, NCX, OPF, JPG, PNG, GIF, CSS, SVG, TTF, XPGT, OPENTYPE, WOFF, SMIL, PLS, JAVASCRIPT, MP3, MP4, OGG]
    
    /**
    Gets the MediaType based on the file mimetype.
    */
    static var mediaTypesByName: [String: MediaType] = {
        var mediaTypesByNameTemp = [String: MediaType]()
        for mediatype in mediatypes {
            mediaTypesByNameTemp[mediatype.name] = mediatype
        }
        return mediaTypesByNameTemp
    }()
    
    /**
    Compare if the resource is a image.
    */
    static func isBitmapImage(mediaType: MediaType) -> Bool {
        return mediaType == JPG || mediaType == PNG || mediaType == GIF
    }
    
    
    /**
    Gets the MediaType based on the file extension.
    */
    static func determineMediaType(filename: String) -> MediaType? {
        for mediatype in mediatypes {
            let ext = "."+filename.pathExtension
            if mediatype.extensions.contains(ext) {
                return mediatype
            }
        }
        
        return nil
    }
}
