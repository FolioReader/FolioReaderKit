//
//  UIViewController+FolioReaderKit.swift
//  SberbankVS
//
//  Created by Ilya Filinovich on 26.10.2017.
//  Copyright © 2017 Mobile Up. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    private func readerConfiguration() -> FolioReaderConfig {
        let config = FolioReaderConfig()
        
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
        config.quoteCustomBackgrounds = []
        if let image = UIImage(named: "demo-bg") {
            let customImageQuote = QuoteImage(withImage: image, alpha: 0.6, backgroundColor: UIColor.black)
            config.quoteCustomBackgrounds.append(customImageQuote)
        }
        
        let textColor = UIColor(red:0.86, green:0.73, blue:0.70, alpha:1.0)
        let customColor = UIColor(red:0.30, green:0.26, blue:0.20, alpha:1.0)
        let customQuote = QuoteImage(withColor: customColor, alpha: 1.0, textColor: textColor)
        config.quoteCustomBackgrounds.append(customQuote)
        
        return config
    }
    
    func showBook() {
        let reader = FolioReader()
        let readerConfiguration = self.readerConfiguration()
        if let bookPath = Bundle.main.path(forResource: "book", ofType: "epub") {
            reader.presentReader(parentViewController: self, withEpubPath: bookPath, andConfig: readerConfiguration, shouldRemoveEpub: false)
        }
    }
}
