//
//  ExampleFolioReaderContainer
//  StoryboardExample
//
//  Created by Panajotis Maroungas on 18/08/16.
//  Copyright © 2016 FolioReader. All rights reserved.
//

import UIKit
import FolioReaderKit

class ExampleFolioReaderContainer: FolioReaderContainer {

	required init?(coder aDecoder: NSCoder) {

		let config = FolioReaderConfig()
		config.scrollDirection = .horizontalWithVerticalContent
		if let _bookPath = NSBundle.mainBundle().pathForResource("The Silver Chair", ofType: "epub") {
			FolioReaderContainer.setUpConfig(config, epubPath: _bookPath)
		}

		super.init(coder: aDecoder)
	}
}