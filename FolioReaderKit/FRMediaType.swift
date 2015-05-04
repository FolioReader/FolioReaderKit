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
    var name: String!
    var defaultExtension: String!
    var extensions: [String]?
    
    init(name: String, defaultExtension: String) {
        self.name = name
        self.defaultExtension = defaultExtension
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
    var XHTML = MediaType(name: "application/xhtml+xml", defaultExtension: ".xhtml", extensions: [".htm", ".html", ".xhtml"])
    var EPUB = MediaType(name: "application/epub+zip", defaultExtension: ".epub")
    var NCX = MediaType(name: "application/x-dtbncx+xml", defaultExtension: ".ncx")

    var JAVASCRIPT = MediaType(name: "text/javascript", defaultExtension: ".js")
    var CSS = MediaType(name: "text/css", defaultExtension: ".css")

    // images
    var JPG = MediaType(name: "image/jpeg", defaultExtension: ".jpg", extensions: [".jpg", ".jpeg"])
    var PNG = MediaType(name: "image/png", defaultExtension: ".png")
    var GIF = MediaType(name: "image/gif", defaultExtension: ".gif")
    var SVG = MediaType(name: "image/svg+xml", defaultExtension: ".svg")

    // fonts
    var TTF = MediaType(name: "application/x-truetype-font", defaultExtension: ".ttf")
    var OPENTYPE = MediaType(name: "application/vnd.ms-opentype", defaultExtension: ".otf")
    var WOFF = MediaType(name: "application/font-woff", defaultExtension: ".woff")

    // audio
    var MP3 = MediaType(name: "audio/mpeg", defaultExtension: ".mp3")
    var MP4 = MediaType(name: "audio/mp4", defaultExtension: ".mp4")
    var OGG = MediaType(name: "audio/ogg", defaultExtension: ".ogg")

    var SMIL = MediaType(name: "application/smil+xml", defaultExtension: ".smil")
    var XPGT = MediaType(name: "application/adobe-page-template+xml", defaultExtension: ".xpgt")
    var PLS = MediaType(name: "application/pls+xml", defaultExtension: ".pls")

//    var mediatypes: [MediaType] = [XHTML, EPUB, JPG, PNG, GIF, CSS, SVG, TTF, NCX, XPGT, OPENTYPE, WOFF, SMIL, PLS, JAVASCRIPT, MP3, MP4, OGG]
    
    func isBitmapImage(mediaType: MediaType) -> Bool {
        return mediaType == JPG || mediaType == PNG || mediaType == GIF
    }
}
