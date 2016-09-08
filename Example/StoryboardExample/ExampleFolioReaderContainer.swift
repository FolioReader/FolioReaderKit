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
		config.shouldHideNavigationOnTap = false

		// Print the chapter ID if one was clicked
		// A chapter in "The Silver Chair" looks like this "<section class="chapter" title="Chapter I" epub:type="chapter" id="id70364673704880">"
		// To knwo if a user tapped on a chapter we can listen to events on the class "chapter" and receive the id value
		let listener = ClassBasedOnClickListener(schemeName: "chapterTapped", className: "chapter", parameterName: "id", onClickAction: { (parameterContent: String?) in
			print("chapter with id: " + (parameterContent ?? "-") + " clicked")
		})
		config.classBasedOnClickListeners.append(listener)

        guard let bookPath = NSBundle.mainBundle().pathForResource("The Silver Chair", ofType: "epub") else { return }
        setupConfig(config, epubPath: bookPath)
	}
}