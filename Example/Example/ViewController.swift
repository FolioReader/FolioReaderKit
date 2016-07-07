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

    @IBOutlet var bookOne: UIButton!
    @IBOutlet var bookTwo: UIButton!
    let epubSampleFiles = [
        "The Silver Chair", // standard eBook
        "The Adventures Of Sherlock Holmes - Adventure I", // audio-eBook
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCover(bookOne, index: 0)
        setCover(bookTwo, index: 1)
    }

    @IBAction func didOpen(sender: AnyObject) {
        openEpub(sender.tag);
    }
    
    func openEpub(sampleNum:Int) {
        let config = FolioReaderConfig()
        config.shouldHideNavigationOnTap = sampleNum == 1 ? true : false
        config.scrollDirection = sampleNum == 1 ? .horizontal : .vertical
        
        // See more at FolioReaderConfig.swift
//        config.enableTTS = false
//        config.allowSharing = false
//        config.tintColor = UIColor.blueColor()
//        config.toolBarTintColor = UIColor.redColor()
//        config.toolBarBackgroundColor = UIColor.purpleColor()
//        config.menuTextColor = UIColor.brownColor()
//        config.menuBackgroundColor = UIColor.lightGrayColor()
        
        
        let epubName = epubSampleFiles[sampleNum-1];
        let bookPath = NSBundle.mainBundle().pathForResource(epubName, ofType: "epub")
        FolioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config, shouldRemoveEpub: false)
    }

    func setCover(button: UIButton, index: Int) {
        let epubName = epubSampleFiles[index];
        let bookPath = NSBundle.mainBundle().pathForResource(epubName, ofType: "epub")
        
        if let image = FolioReader.getCoverImage(bookPath!) {
            button.setBackgroundImage(image, forState: .Normal)
        }
    }
}
