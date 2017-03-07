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

    @IBAction func didOpen(_ sender: AnyObject) {
        openEpub(sender.tag);
    }
    
    func openEpub(_ sampleNum: Int) {
        let config = FolioReaderConfig()
        config.shouldHideNavigationOnTap = sampleNum == 1 ? true : false
        config.scrollDirection = sampleNum == 1 ? .horizontal : .vertical
        
        // See more at FolioReaderConfig.swift
//        config.canChangeScrollDirection = false
//        config.enableTTS = false
//        config.allowSharing = false
//        config.tintColor = UIColor.blueColor()
//        config.toolBarTintColor = UIColor.redColor()
//        config.toolBarBackgroundColor = UIColor.purpleColor()
//        config.menuTextColor = UIColor.brownColor()
//        config.menuBackgroundColor = UIColor.lightGrayColor()
//        config.hidePageIndicator = true
//        config.realmConfiguration = Realm.Configuration(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("highlights.realm"))
        
        // Custom sharing quote background
        let customImageQuote = QuoteImage(withImage: UIImage(named: "demo-bg")!, alpha: 0.6, backgroundColor: UIColor.black)
        let customQuote = QuoteImage(withColor: UIColor(red:0.30, green:0.26, blue:0.20, alpha:1.0), alpha: 1.0, textColor: UIColor(red:0.86, green:0.73, blue:0.70, alpha:1.0))
        
        config.quoteCustomBackgrounds = [customImageQuote, customQuote]
        
        // Epub file
        let epubName = epubSampleFiles[sampleNum-1];
        let bookPath = Bundle.main.path(forResource: epubName, ofType: "epub")
        FolioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config, shouldRemoveEpub: false)
    }

    func setCover(_ button: UIButton, index: Int) {
        let epubName = epubSampleFiles[index];
        let bookPath = Bundle.main.path(forResource: epubName, ofType: "epub")
        
        if let image = FolioReader.getCoverImage(bookPath!) {
            button.setBackgroundImage(image, for: .normal)
        }
    }
}
