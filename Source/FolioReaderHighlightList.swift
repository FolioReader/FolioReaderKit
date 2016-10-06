//
//  FolioReaderHighlightList.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 01/09/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderHighlightList: UITableViewController {

    var highlights: [Highlight]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)       
        tableView.separatorInset = UIEdgeInsets.zero
        tableView.backgroundColor = isNight(readerConfig.nightModeMenuBackground, readerConfig.menuBackgroundColor)
        tableView.separatorColor = isNight(readerConfig.nightModeSeparatorColor, readerConfig.menuSeparatorColor)
        
        highlights = Highlight.allByBookId((kBookId as NSString).deletingPathExtension)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highlights.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) 
        cell.backgroundColor = UIColor.clear

        let highlight = highlights[(indexPath as NSIndexPath).row]
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = readerConfig.localizedHighlightsDateFormat
        let dateString = dateFormatter.string(from: highlight.date)
        
        // Date
        var dateLabel: UILabel!
        if cell.contentView.viewWithTag(456) == nil {
            dateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-40, height: 16))
            dateLabel.tag = 456
            dateLabel.autoresizingMask = UIViewAutoresizing.flexibleWidth
            dateLabel.font = UIFont(name: "Avenir-Medium", size: 12)
            cell.contentView.addSubview(dateLabel)
        } else {
            dateLabel = cell.contentView.viewWithTag(456) as! UILabel
        }
        
        dateLabel.text = dateString.uppercased()
        dateLabel.textColor = isNight(UIColor(white: 5, alpha: 0.3), UIColor.lightGray)
        dateLabel.frame = CGRect(x: 20, y: 20, width: view.frame.width-40, height: dateLabel.frame.height)
        
        // Text
        let cleanString = highlight.content.stripHtml().truncate(250, trailing: "...").stripLineBreaks()
        let text = NSMutableAttributedString(string: cleanString)
        let range = NSRange(location: 0, length: text.length)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        let textColor = isNight(readerConfig.menuTextColor, UIColor.black)
        
        text.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: range)
        text.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Light", size: 16)!, range: range)
        text.addAttribute(NSForegroundColorAttributeName, value: textColor, range: range)
        
        if highlight.type == HighlightStyle.underline.rawValue {
            text.addAttribute(NSBackgroundColorAttributeName, value: UIColor.clear, range: range)
            text.addAttribute(NSUnderlineColorAttributeName, value: HighlightStyle.colorForStyle(highlight.type, nightMode: FolioReader.nightMode), range: range)
            text.addAttribute(NSUnderlineStyleAttributeName, value: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int), range: range)
        } else {
            text.addAttribute(NSBackgroundColorAttributeName, value: HighlightStyle.colorForStyle(highlight.type, nightMode: FolioReader.nightMode), range: range)
        }
        
        // Text
        var highlightLabel: UILabel!
        if cell.contentView.viewWithTag(123) == nil {
            highlightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-40, height: 0))
            highlightLabel.tag = 123
            highlightLabel.autoresizingMask = UIViewAutoresizing.flexibleWidth
            highlightLabel.numberOfLines = 0
            highlightLabel.textColor = UIColor.black
            cell.contentView.addSubview(highlightLabel)
        } else {
            highlightLabel = cell.contentView.viewWithTag(123) as! UILabel
        }
 
        highlightLabel.attributedText = text
        highlightLabel.sizeToFit()
        highlightLabel.frame = CGRect(x: 20, y: 46, width: view.frame.width-40, height: highlightLabel.frame.height)
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let highlight = highlights[(indexPath as NSIndexPath).row]
        
        let cleanString = highlight.content.stripHtml().truncate(250, trailing: "...").stripLineBreaks()
        let text = NSMutableAttributedString(string: cleanString)
        let range = NSRange(location: 0, length: text.length)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        text.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: range)
        text.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Light", size: 16)!, range: range)
        
        let s = text.boundingRect(with: CGSize(width: view.frame.width-40, height: CGFloat.greatestFiniteMagnitude),
            options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading],
            context: nil)
        
        return s.size.height + 66
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let highlight = highlights[(indexPath as NSIndexPath).row]

        FolioReader.shared.readerCenter?.changePageWith(page: highlight.page, andFragment: highlight.highlightId)
        dismiss()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let highlight = highlights[(indexPath as NSIndexPath).row]
            
            if highlight.page == currentPageNumber {
                Highlight.removeFromHTMLById(highlight.highlightId) // Remove from HTML
            }
            
            highlight.remove() // Remove from Database
            highlights.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Handle rotation transition
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }
}
