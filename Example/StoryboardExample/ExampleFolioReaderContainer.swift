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
        super.init(coder: aDecoder)
        
        let config = FolioReaderConfig()
        config.scrollDirection = .horizontalWithVerticalContent
        
        guard let bookPath = NSBundle.mainBundle().pathForResource("The Silver Chair", ofType: "epub") else { return }
        setupConfig(config, epubPath: bookPath)
	}
}