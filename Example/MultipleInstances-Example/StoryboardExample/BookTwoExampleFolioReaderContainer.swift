//
//  BookTwoExampleFolioReaderContainer.swift
//  StoryboardExample
//
//  Created by Panajotis Maroungas on 18/08/16.
//  Copyright © 2016 FolioReader. All rights reserved.
//

import UIKit
import FolioReaderKit

class BookTwoExampleFolioReaderContainer: BaseExampleFolioReaderContainer {

    override var exampleReaderConfig: FolioReaderConfig {
        let config = FolioReaderConfig(withIdentifier: "STORYBOARD_READER_TWO")
        config.scrollDirection = .vertical
        config.shouldHideNavigationOnTap = false

        return config
    }

    override var bookTitle: String {
        return "The Silver Chair"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
