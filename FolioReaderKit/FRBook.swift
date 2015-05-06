//
//  FRBook.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 09/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FRBook: NSObject {
    var resources = FRResources()
    var metadata = FRMetadata()
//    var spine = Spine()
    var tableOfContents: [FRTOCReference]!
//    var guide = Guide()
    var opfResource: FRResource!
    var ncxResource: FRResource!
    var coverImage: FRResource?
}
