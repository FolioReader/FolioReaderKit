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
    var image: UIImage?

    init(subject: String, text: String, html: String? = nil, image: UIImage? = nil) {
        self.subject = subject
        self.text = text
        self.html = html
        self.image = image

        super.init(placeholderItem: "")
    }

    override func activityViewController(activityViewController: UIActivityViewController, subjectForActivityType activityType: String?) -> String {
        return subject
    }

    override func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        if let html = html where activityType == UIActivityTypeMail {
            return html
        }
        
        if let image = image where activityType == UIActivityTypePostToFacebook {
            return image
        }

        return text
    }
    
//    func activityViewController(activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: String?, suggestedSize size: CGSize) -> UIImage? {
//
//    }
}
