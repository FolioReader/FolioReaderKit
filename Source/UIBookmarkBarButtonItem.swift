//
//  UIBookmarkBarButtonItem.swift
//  AEXML
//
//  Created by Omar Albeik on 26.03.2018.
//

import UIKit

class UIBookmarkBarButtonItem: UIBarButtonItem {

    var isHighlighed = false {
        didSet {
            image = UIImage(readerImageNamed: isHighlighed ? "icon-navbar-bookmark-selected" : "icon-navbar-bookmark")
        }
    }

    var readerConfig: FolioReaderConfig? {
        didSet {
            print("readerConfig")
            guard let config = readerConfig else { return }
            image = image?.ignoreSystemTint(withConfiguration: config)
        }
    }

    convenience init(target: Any?, action: Selector?, isHighlighed: Bool = false, readerConfig: FolioReaderConfig) {

        self.init(image: UIImage(readerImageNamed: "icon-navbar-bookmark"), style: .plain, target: target, action: action)

        self.isHighlighed = isHighlighed
        self.readerConfig = readerConfig
    }

}
