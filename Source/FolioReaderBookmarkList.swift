//
//  FolioReaderBookmarkList.swift
//  FolioReaderKit
//
//  Created by Omar Albeik on 26.03.2018.
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

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kReuseCellIdentifier)
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.backgroundColor = self.folioReader.isNight(self.readerConfig.nightModeMenuBackground, self.readerConfig.menuBackgroundColor)
        self.tableView.separatorColor = self.folioReader.isNight(self.readerConfig.nightModeSeparatorColor, self.readerConfig.menuSeparatorColor)

        guard let bookId = (self.folioReader.readerContainer?.book.name as NSString?)?.deletingPathExtension else {
            self.bookmarks = []
            return
        }

        self.bookmarks = Bookmark.allByBookId(withConfiguration: self.readerConfig, bookId: bookId)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReuseCellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.clear

        let bookmark = bookmarks[(indexPath as NSIndexPath).row]

        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.readerConfig.localizedHighlightsDateFormat
        let dateString = dateFormatter.string(from: bookmark.date)

        cell.textLabel?.text = "Page \(bookmark.page)"
        cell.detailTextLabel?.text = dateString

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let bookmark = bookmarks[safe: (indexPath as NSIndexPath).row] else {
            return
        }

        self.folioReader.readerCenter?.changePageWith(page: bookmark.page, andFragment: bookmark.bookmarkId)
        self.dismiss()
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bookmark = bookmarks[(indexPath as NSIndexPath).row]
            bookmark.remove(withConfiguration: self.readerConfig) // Remove from Database
            bookmarks.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Handle rotation transition

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }
}
