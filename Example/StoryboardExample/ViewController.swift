//
//  ViewController.swift
//  StoryboardExample
//
//  Created by Panajotis Maroungas on 18/08/16.
//  Copyright © 2016 FolioReader. All rights reserved.
//

import UIKit
import FolioReaderKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

class StoryboardFolioReaderKit: FolioReaderContainer {

	required init?(coder aDecoder: NSCoder) {
		let config = FolioReaderConfig()

		config.scrollDirection = .horizontal
		let bookPath = NSBundle.mainBundle().pathForResource("The Silver Chair", ofType: "epub")
		FolioReaderContainer.setUpConfig(config, epubPath: bookPath!)

		super.init(coder: aDecoder)
	}
}