//
//  FRSpine.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 06/05/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

struct Spine {
    var linear: Bool!
    var resource: FRResources!
    
    init(resource: FRResources, linear: Bool = true) {
        self.resource = resource
        self.linear = linear
    }
}

class FRSpine: NSObject {
    var tocReference: FRResources!
    var spineReferences: [Spine]!
}
