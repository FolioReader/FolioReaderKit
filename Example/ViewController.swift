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
        let config = FolioReaderConfig()
//        config.toolBarTintColor = UIColor.redColor()
//        config.toolBarBackgroundColor = UIColor.purpleColor()
//        config.menuTextColor = UIColor.brownColor()
//        config.menuBackgroundColor = UIColor.magentaColor()
        
        let bookPath = NSBundle.mainBundle().pathForResource("book", ofType: "epub")
        
//        FolioReaderKit.presentReader(parentViewController: self, andConfig: config)
        FolioReaderKit.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
    }
}

