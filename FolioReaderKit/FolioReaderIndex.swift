//
//  FolioReaderIndex.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 09/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderIndex: NSObject {
    var text: String!
    var src: String!
    var playOrder: Int!
    var chapters: [FolioReaderIndex]!
}
