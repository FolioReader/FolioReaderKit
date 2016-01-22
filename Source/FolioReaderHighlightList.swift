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

        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = isNight(readerConfig.nightModeBackground, UIColor.whiteColor())
        tableView.separatorColor = isNight(readerConfig.nightModeSeparatorColor, readerConfig.menuSeparatorColor)
        
        highlights = Highlight.allByBookId((kBookId as NSString).stringByDeletingPathExtension)
        title = readerConfig.localizedHighlightsTitle
        
        setCloseButton()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
    }
    
    func configureNavBar() {
        let navBackground = isNight(readerConfig.nightModeMenuBackground, UIColor.whiteColor())
        let tintColor = readerConfig.tintColor
        let navText = isNight(UIColor.whiteColor(), UIColor.blackColor())
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return highlights.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) 
        cell.backgroundColor = UIColor.clearColor()

        let highlight = highlights[indexPath.row]
        
        // Format date
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = readerConfig.localizedHighlightsDateFormat
        let dateString = dateFormatter.stringFromDate(highlight.date)
        
        // Date
        var dateLabel: UILabel!
        if cell.contentView.viewWithTag(456) == nil {
            dateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-40, height: 16))
            dateLabel.tag = 456
            dateLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
            dateLabel.font = UIFont(name: "Avenir-Medium", size: 12)
            cell.contentView.addSubview(dateLabel)
        } else {
            dateLabel = cell.contentView.viewWithTag(456) as! UILabel
        }
        
        dateLabel.text = dateString.uppercaseString
        dateLabel.textColor = isNight(UIColor(white: 5, alpha: 0.3), UIColor.lightGrayColor())
        dateLabel.frame = CGRect(x: 20, y: 20, width: view.frame.width-40, height: dateLabel.frame.height)
        
        // Text
        let cleanString = highlight.content.stripHtml().truncate(250, trailing: "...").stripLineBreaks()
        let text = NSMutableAttributedString(string: cleanString)
        let range = NSRange(location: 0, length: text.length)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        let textColor = isNight(readerConfig.menuTextColor, UIColor.blackColor())
        
        text.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: range)
        text.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Light", size: 16)!, range: range)
        text.addAttribute(NSForegroundColorAttributeName, value: textColor, range: range)
        
        if highlight.type.integerValue == HighlightStyle.Underline.rawValue {
            text.addAttribute(NSBackgroundColorAttributeName, value: UIColor.clearColor(), range: range)
            text.addAttribute(NSUnderlineColorAttributeName, value: HighlightStyle.colorForStyle(highlight.type.integerValue, nightMode: FolioReader.sharedInstance.nightMode), range: range)
            text.addAttribute(NSUnderlineStyleAttributeName, value: NSNumber(integer: NSUnderlineStyle.StyleSingle.rawValue), range: range)
        } else {
            text.addAttribute(NSBackgroundColorAttributeName, value: HighlightStyle.colorForStyle(highlight.type.integerValue, nightMode: FolioReader.sharedInstance.nightMode), range: range)
        }
        
        // Text
        var highlightLabel: UILabel!
        if cell.contentView.viewWithTag(123) == nil {
            highlightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-40, height: 0))
            highlightLabel.tag = 123
            highlightLabel.autoresizingMask = UIViewAutoresizing.FlexibleWidth
            highlightLabel.numberOfLines = 0
            highlightLabel.textColor = UIColor.blackColor()
            cell.contentView.addSubview(highlightLabel)
        } else {
            highlightLabel = cell.contentView.viewWithTag(123) as! UILabel
        }
 
        highlightLabel.attributedText = text
        highlightLabel.sizeToFit()
        highlightLabel.frame = CGRect(x: 20, y: 46, width: view.frame.width-40, height: highlightLabel.frame.height)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let highlight = highlights[indexPath.row]
        
        let cleanString = highlight.content.stripHtml().truncate(250, trailing: "...").stripLineBreaks()
        let text = NSMutableAttributedString(string: cleanString)
        let range = NSRange(location: 0, length: text.length)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        text.addAttribute(NSParagraphStyleAttributeName, value: paragraph, range: range)
        text.addAttribute(NSFontAttributeName, value: UIFont(name: "Avenir-Light", size: 16)!, range: range)
        
        let s = text.boundingRectWithSize(CGSize(width: view.frame.width-40, height: CGFloat.max),
            options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading],
            context: nil)
        
        return s.size.height + 66
    }
    
    // MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let highlight = highlights[indexPath.row]

        FolioReader.sharedInstance.readerCenter.changePageWith(page: highlight.page.integerValue, andFragment: highlight.highlightId)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let highlight = highlights[indexPath.row]
            
            if highlight.page == currentPageNumber {
                FRHighlight.removeById(highlight.highlightId) // Remove from HTML
            }
            
            Highlight.removeById(highlight.highlightId) // Remove from Core data
            highlights.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - Handle rotation transition
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }
}
