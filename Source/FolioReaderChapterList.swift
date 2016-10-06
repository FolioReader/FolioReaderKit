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
    func chapterList(_ chapterList: FolioReaderChapterList, didSelectRowAtIndexPath indexPath: IndexPath, withTocReference reference: FRTocReference)
    
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
        tableView.register(FolioReaderChapterListCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.backgroundColor = isNight(readerConfig.nightModeMenuBackground, readerConfig.menuBackgroundColor)
        tableView.separatorColor = isNight(readerConfig.nightModeSeparatorColor, readerConfig.menuSeparatorColor)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        // Create TOC list
        tocItems = book.flatTableOfContents
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tocItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FolioReaderChapterListCell
        
        let tocReference = tocItems[(indexPath as NSIndexPath).row]
        let isSection = tocReference.children.count > 0
        
        cell.indexLabel.text = tocReference.title.trimmingCharacters(in: .whitespacesAndNewlines)

        // Add audio duration for Media Ovelay
        if let resource = tocReference.resource {
            if let mediaOverlay = resource.mediaOverlay {
                let duration = book.durationFor("#"+mediaOverlay)
                let durationFormatted = (duration != nil ? duration : "")?.clockTimeToMinutesString()

                cell.indexLabel.text = cell.indexLabel.text! + (duration != nil ? " - "+durationFormatted! : "");
            }
        }

        // Mark current reading chapter
        if let currentPageNumber = currentPageNumber, let reference = book.spine.spineReferences[safe: currentPageNumber-1] , tocReference.resource != nil {
            let resource = reference.resource
            cell.indexLabel.textColor = tocReference.resource == resource ? readerConfig.tintColor : readerConfig.menuTextColor
        }
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.contentView.backgroundColor = isSection ? UIColor(white: 0.7, alpha: 0.1) : UIColor.clear
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tocReference = tocItems[(indexPath as NSIndexPath).row]
        delegate?.chapterList(self, didSelectRowAtIndexPath: indexPath, withTocReference: tocReference)
        
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss { 
            self.delegate?.chapterList(didDismissedChapterList: self)
        }
    }
}
