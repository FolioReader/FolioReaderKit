//
//  FRResource.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 29/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FRResource: NSObject {
    var id: String!
    var title: String!
    var href: String!
    var fullHref: String!
    var mediaType: MediaType!
    var mediaOverlay: String!
    var inputEncoding: String!

    func basePath() -> String! {
        if href == nil || href.isEmpty { return nil }
        var paths = fullHref.componentsSeparatedByString("/")
        paths.removeLast()
        return paths.joinWithSeparator("/")
    }
}
