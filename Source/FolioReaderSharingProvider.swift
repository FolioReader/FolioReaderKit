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

    override func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivityType?) -> String {
        return subject
    }

    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        if let html = html , activityType == UIActivityType.mail {
            return html
        }
        
        if let image = image , activityType == UIActivityType.postToFacebook {
            return image
        }

        return text
    }
    
//    func activityViewController(activityViewController: UIActivityViewController, thumbnailImageForActivityType activityType: String?, suggestedSize size: CGSize) -> UIImage? {
//
//    }
}
