//
//  BookOneExampleFolioReaderContainer.swift
//  StoryboardExample
//
//  Created by Panajotis Maroungas on 18/08/16.
//  Copyright © 2016 FolioReader. All rights reserved.
//

import UIKit
import FolioReaderKit

class BookOneExampleFolioReaderContainer: BaseExampleFolioReaderContainer {

    override var readerIdentifier: String {
        return "reader_one"
    }

    override var bookTitle: String {
        return "The Silver Chair"
//    return "The Adventures Of Sherlock Holmes - Adventure I"
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        (UIApplication.shared.delegate as? AppDelegate)?.epubReaderOne = self
    }
}
