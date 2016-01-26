//
//  FolioReaderSharingProvider.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 02/09/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderSharingProvider: UIActivityItemProvider {

    var subject: String
    var text: String
    var html: String?

    init(subject: String, text: String, html: String?) {
        self.subject = subject
        self.text = text
        self.html = html

        super.init(placeholderItem: "")
    }

    override func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        return subject
    }

    override func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        if let html = html where activityType == UIActivityTypeMail {
            return html
        }

        return text
    }
}
