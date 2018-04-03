//
//  FolioReaderBookmarkList.swift
//  FolioReaderKit
//
//  Created by Omar Albeik on 26.03.2018.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderBookmarkList: UITableViewController {

    fileprivate var bookmarks = [Bookmark]()
    fileprivate var readerConfig: FolioReaderConfig
    fileprivate var folioReader: FolioReader

    init(folioReader: FolioReader, readerConfig: FolioReaderConfig) {
        self.readerConfig = readerConfig
        self.folioReader = folioReader

        super.init(style: UITableViewStyle.plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kReuseCellIdentifier)
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.backgroundColor = folioReader.isNight(readerConfig.nightModeMenuBackground, readerConfig.menuBackgroundColor)
        tableView.separatorColor = folioReader.isNight(readerConfig.nightModeSeparatorColor, readerConfig.menuSeparatorColor)

        guard let bookId = (folioReader.readerContainer?.book.name as NSString?)?.deletingPathExtension else {
            bookmarks = []
            return
        }

        bookmarks = Bookmark.allByBookId(withConfiguration: readerConfig, bookId: bookId)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReuseCellIdentifier, for: indexPath)
        cell.backgroundColor = .clear

        let bookmark = bookmarks[indexPath.row]

        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = readerConfig.localizedHighlightsDateFormat
        let dateString = dateFormatter.string(from: bookmark.date)

        cell.textLabel?.text = "Page \(bookmark.page)"
        cell.detailTextLabel?.text = dateString

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let bookmark = bookmarks[safe: indexPath.row] else {
            return
        }

        folioReader.readerCenter?.changePageWith(page: bookmark.page, andFragment: bookmark.bookmarkId)
        dismiss()
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bookmark = bookmarks[indexPath.row]
            bookmark.remove(withConfiguration: readerConfig) // Remove from Database
            bookmarks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Handle rotation transition

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }
}
