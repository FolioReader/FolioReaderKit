//
//  FolioReaderSidePanel.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 15/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

@objc
protocol FolioReaderSidePanelDelegate {
    /**
    Notifies when the user selected some item on menu.
    */
    func sidePanel(sidePanel: FolioReaderSidePanel, didSelectRowAtIndexPath indexPath: NSIndexPath, withTocReference reference: FRTocReference)
}

class FolioReaderSidePanel: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate: FolioReaderSidePanelDelegate?
    var tableView: UITableView!
    var toolBar: UIToolbar!
    let toolBarHeight: CGFloat = 50
    let traits = UITraitCollection(displayScale: UIScreen.mainScreen().scale)
    var tocItems = [FRTocReference]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tableViewFrame = screenBounds()
        tableViewFrame.size.height = tableViewFrame.height-toolBarHeight
        
        tableView = UITableView(frame: tableViewFrame)
        tableView.delaysContentTouches = true
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.backgroundColor =  readerConfig.menuBackgroundColor
        tableView.separatorColor = readerConfig.menuSeparatorColor
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        toolBar = UIToolbar(frame: CGRectMake(0, screenBounds().height-toolBarHeight, view.frame.width, toolBarHeight))
        toolBar.autoresizingMask = .FlexibleWidth
        toolBar.barTintColor = readerConfig.toolBarBackgroundColor
        toolBar.tintColor = readerConfig.toolBarTintColor
        toolBar.clipsToBounds = true
        toolBar.translucent = false
        view.addSubview(toolBar)
        
        let imageHighlight = UIImage(named: "icon-highlight", inBundle: kFrameworkBundle, compatibleWithTraitCollection: traits)
        let imageSearch = UIImage(named: "icon-search", inBundle: kFrameworkBundle, compatibleWithTraitCollection: traits)
        let imageFont = UIImage(named: "icon-font", inBundle: kFrameworkBundle, compatibleWithTraitCollection: traits)
        
//        let space = pageWidth/4
        let space = 80 as CGFloat
        
        let iconHighlight = UIBarButtonItem(image: imageHighlight, style: .Plain, target: self, action: "didSelectHighlight:")
        iconHighlight.width = space
        let iconSearch = UIBarButtonItem(image: imageSearch, style: .Plain, target: self, action: "didSelectSearch:")
        iconSearch.width = space
        let iconFont = UIBarButtonItem(image: imageFont, style: .Plain, target: self, action: "didSelectFont:")
        iconFont.width = space
        toolBar.setItems([iconHighlight, iconSearch, iconFont], animated: false)
        
        
        // Register cell classes
        self.tableView.registerClass(FolioReaderSidePanelCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        // Create TOC list
        createTocList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Recursive add items to a list
    
    func createTocList() {
        for item in book.tableOfContents {
            tocItems.append(item)
            countTocChild(item)
        }
    }
    
    func countTocChild(item: FRTocReference) {
        if item.children.count > 0 {
            for item in item.children {
                tocItems.append(item)
            }
        }
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tocItems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FolioReaderSidePanelCell
        
        let tocReference = tocItems[indexPath.row]
        let isSection = tocReference.fragmentID != ""
        
        cell.indexLabel.text = tocReference.title
        cell.indexLabel.font = UIFont(name: "Avenir-Light", size: 17)
        cell.indexLabel.textColor = readerConfig.menuTextColor
        
        if cell.respondsToSelector("layoutMargins") {
            cell.layoutMargins = UIEdgeInsetsZero
            cell.preservesSuperviewLayoutMargins = false
        }
        
        cell.contentView.backgroundColor = isSection ? UIColor(white: 0.7, alpha: 0.1) : UIColor.clearColor()
        cell.backgroundColor = UIColor.clearColor()
        
        // Adjust text position
        cell.indexLabel.center = cell.contentView.center
        var frame = cell.indexLabel.frame
        frame.origin = isSection ? CGPoint(x: 40, y: frame.origin.y) : CGPoint(x: 20, y: frame.origin.y)
        cell.indexLabel.frame = frame

        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tocReference = tocItems[indexPath.row]
        delegate?.sidePanel(self, didSelectRowAtIndexPath: indexPath, withTocReference: tocReference)
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - Get Screen bounds
    
    func screenBounds() -> CGRect {
        return UIScreen.mainScreen().bounds
    }
    
    // MARK: - Rotation
    
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        UIView.animateWithDuration(duration, animations: { () -> Void in
            var frame = self.toolBar.frame
            frame.origin.y = pageHeight-self.toolBarHeight
            self.toolBar.frame = frame
        })
    }
    
    // MARK: - Toolbar actions
    
    func didSelectHighlight(sender: UIBarButtonItem) {
        print("Highlight")
    }
    
    func didSelectSearch(sender: UIBarButtonItem) {
        print("Search")
    }
    
    func didSelectFont(sender: UIBarButtonItem) {
        print("Font")
    }

}
