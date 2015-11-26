//
//  FolioReaderSharing.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 02/09/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderSharing: UIActivityItemProvider {
    
    var subject: String!
    var text: String!
    var html: String?
    
    init(subject: String, text: String, html: String?) {
        self.subject = subject
        self.text = text
        if let ht = html {
            self.html = ht
        }
        super.init(placeholderItem: "")
    }
    
    override func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        return subject
    }
    
    override func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        
        if activityType == UIActivityTypeMail {
            if let html = html {
                return html
            } else {
                return text
            }
        }
        
        return text
    }
}
