//
//  FolioReaderChapterList.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 15/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

/// Table Of Contents delegate
@objc protocol FolioReaderChapterListDelegate: class {
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
    fileprivate var tocItems = [FRTocReference]()
    fileprivate var book: FRBook
    fileprivate var readerConfig: FolioReaderConfig
    fileprivate var folioReader: FolioReader
    private weak var tryOutDelegate: FolioReaderTryOutDelegate?

    init(folioReader: FolioReader, readerConfig: FolioReaderConfig, book: FRBook, delegate: FolioReaderChapterListDelegate?, tryOutDelegate: FolioReaderTryOutDelegate?) {
        self.readerConfig = readerConfig
        self.folioReader = folioReader
        self.delegate = delegate
        self.tryOutDelegate = tryOutDelegate
        self.book = book

        super.init(style: UITableViewStyle.plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.tableView.register(FolioReaderChapterListCell.self, forCellReuseIdentifier: kReuseCellIdentifier)
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.backgroundColor = self.folioReader.isNight(self.readerConfig.nightModeMenuBackground, self.readerConfig.menuBackgroundColor)
        self.tableView.separatorColor = self.folioReader.isNight(self.readerConfig.nightModeSeparatorColor, self.readerConfig.menuSeparatorColor)

        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 50

        // Create TOC list
        self.tocItems = self.book.flatTableOfContents
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tocItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReuseCellIdentifier, for: indexPath) as! FolioReaderChapterListCell

        cell.setup(withConfiguration: self.readerConfig)
        
        if let accessoryView = tryOutDelegate?.accessoryView(for: tocItems[indexPath.row], atIndex: indexPath.row) {
            cell.add(accessoryView: accessoryView)
        }
        
        let tocReference = tocItems[(indexPath as NSIndexPath).row]
        let isSection = tocReference.children.count > 0

        cell.indexLabel?.text = tocReference.title.trimmingCharacters(in: .whitespacesAndNewlines)

        // Add audio duration for Media Ovelay
        if let resource = tocReference.resource {
            if let mediaOverlay = resource.mediaOverlay {
                let duration = self.book.duration(for: "#"+mediaOverlay)

                if let durationFormatted = (duration != nil ? duration : "")?.clockTimeToMinutesString() {
                    let text = cell.indexLabel?.text ?? ""
                    cell.indexLabel?.text = text + (duration != nil ? (" - " + durationFormatted) : "")
                }
            }
        }

        // Mark current reading chapter
        if
            let currentPageNumber = self.folioReader.readerCenter?.currentPageNumber,
            let reference = self.book.spine.spineReferences[safe: currentPageNumber - 1],
            (tocReference.resource != nil) {
            let resource = reference.resource
            cell.indexLabel?.textColor = (tocReference.resource == resource ? self.readerConfig.tintColor : self.readerConfig.menuTextColor)
        }

        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        cell.contentView.backgroundColor = isSection ? UIColor(white: 0.7, alpha: 0.1) : UIColor.clear
        cell.backgroundColor = UIColor.clear
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)

        if let delegate = tryOutDelegate, !delegate.isAllowedOpenChapter(atIndex: indexPath.row, givenTotalOfChapters: tocItems.count) {
            tryOutDelegate?.handleAccessToNotAllowedChapter(atIndex: indexPath.row, from: self)
            return
        }
        
        let tocReference = tocItems[(indexPath as NSIndexPath).row]
        delegate?.chapterList(self, didSelectRowAtIndexPath: indexPath, withTocReference: tocReference)
        
        dismiss {
            self.delegate?.chapterList(didDismissedChapterList: self)
        }
    }
}
