//
//  FolioReaderChapterList.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 15/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

@objc
protocol FolioReaderChapterListDelegate: class {
    /**
     Notifies when the user selected some item on menu.
    */
    func chapterList(chapterList: FolioReaderChapterList, didSelectRowAtIndexPath indexPath: NSIndexPath, withTocReference reference: FRTocReference)
    
    /**
     Notifies when chapter list did totally dismissed.
     */
    func chapterList(didDismissedChapterList chapterList: FolioReaderChapterList)
}

class FolioReaderChapterList: UITableViewController {
    weak var delegate: FolioReaderChapterListDelegate?
    var tocItems = [FRTocReference]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        tableView.registerClass(FolioReaderChapterListCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.backgroundColor = isNight(readerConfig.nightModeMenuBackground, readerConfig.menuBackgroundColor)
        tableView.separatorColor = isNight(readerConfig.nightModeSeparatorColor, readerConfig.menuSeparatorColor)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        // Create TOC list
        tocItems = book.flatTableOfContents
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tocItems.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FolioReaderChapterListCell
        
        let tocReference = tocItems[indexPath.row]
        let isSection = tocReference.children.count > 0
        
        cell.indexLabel.text = tocReference.title.stringByTrimmingCharactersInSet(.whitespaceCharacterSet())

        // Add audio duration for Media Ovelay
        if let resource = tocReference.resource {
            if(resource.mediaOverlay != nil){
                let duration = book.durationFor("#"+resource.mediaOverlay);
                let durationFormatted = (duration != nil ? duration : "")?.clockTimeToMinutesString()

                cell.indexLabel.text = cell.indexLabel.text! + (duration != nil ? " - "+durationFormatted! : "");
            }
        }

        // Mark current reading chapter
        if let currentPageNumber = currentPageNumber, reference = book.spine.spineReferences[safe: currentPageNumber-1] where tocReference.resource != nil {
            let resource = reference.resource
            cell.indexLabel.textColor = tocReference.resource == resource ? readerConfig.tintColor : readerConfig.menuTextColor
        }
        
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.contentView.backgroundColor = isSection ? UIColor(white: 0.7, alpha: 0.1) : UIColor.clearColor()
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tocReference = tocItems[indexPath.row]
        delegate?.chapterList(self, didSelectRowAtIndexPath: indexPath, withTocReference: tocReference)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        dismiss { 
            self.delegate?.chapterList(didDismissedChapterList: self)
        }
    }
}
