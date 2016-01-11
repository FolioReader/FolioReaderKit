//
//  ViewController.swift
//  Example
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import FolioReaderKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func didOpen(sender: AnyObject) {
        openEpub(sender.tag);
    }

    func openEpub(sampleNum:Int) {
        let config = FolioReaderConfig()
        config.shouldHideNavigationOnTap = false
//        config.allowSharing = false
//        config.toolBarTintColor = UIColor.redColor()
//        config.toolBarBackgroundColor = UIColor.purpleColor()
//        config.menuTextColor = UIColor.brownColor()
//        config.menuBackgroundColor = UIColor.lightGrayColor()
        
        // http://www.readbeyond.it/ebooks.html
        let epubSampleFiles = [
            "The Silver Chair", // standard eBook
            "The Adventures Of Sherlock Holmes - Adventure I", // audio-eBook
        ]

        let epubName = epubSampleFiles[sampleNum-1];
        let bookPath = NSBundle.mainBundle().pathForResource(epubName, ofType: "epub")

        FolioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
    }

}