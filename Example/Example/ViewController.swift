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

    @IBOutlet
    var coverImageView : UIImageView!
    
    // http://www.readbeyond.it/ebooks.html
    let epubSampleFiles = [
        "The Silver Chair", // standard eBook
        "The Adventures Of Sherlock Holmes - Adventure I", // audio-eBook
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        coverImageView.layer.borderWidth = 4
        coverImageView.layer.masksToBounds = true
        coverImageView.layer.borderColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0).CGColor
    }

    @IBAction func didOpen(sender: AnyObject) {
        openEpub(sender.tag);
    }
    
    @IBAction func getEpubCoverImage(sender: AnyObject) {
        showEpubCover(sender.tag);
    }
    
    func openEpub(sampleNum:Int) {
        let config = FolioReaderConfig()
        config.shouldHideNavigationOnTap = sampleNum == 1 ? true : false
        //config.allowSharing = false
        //config.tintColor = UIColor.blueColor()
        //config.toolBarTintColor = UIColor.redColor()
        //config.toolBarBackgroundColor = UIColor.purpleColor()
        //config.menuTextColor = UIColor.brownColor()
        //config.menuBackgroundColor = UIColor.lightGrayColor()
        
        let epubName = epubSampleFiles[sampleNum-1];
        let bookPath = NSBundle.mainBundle().pathForResource(epubName, ofType: "epub")
        FolioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
    }
    
    func showEpubCover(sampleNum:Int) {
        let epubName = epubSampleFiles[sampleNum-1];
        let bookPath = NSBundle.mainBundle().pathForResource(epubName, ofType: "epub")
        coverImageView.image =  FolioReader.getCoverImage(bookPath!)
    }

}
