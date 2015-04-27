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
    func didSelectedIndex(indexPath: NSIndexPath)
}

class FolioReaderSidePanel: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate: FolioReaderSidePanelDelegate?
    var tableView: UITableView!
    var toolBar: UIToolbar!
    let toolBarHeight: CGFloat = 50
    let traits = UITraitCollection(displayScale: UIScreen.mainScreen().scale)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var tableViewFrame = screenBounds()
        tableViewFrame.size.height = tableViewFrame.height-toolBarHeight
        
        tableView = UITableView(frame: tableViewFrame)
        tableView.delaysContentTouches = true
        tableView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        tableView.backgroundColor = UIColor(rgba: "#F5F5F5")
        tableView.separatorColor = UIColor(rgba: "#D7D7D7")
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        
        toolBar = UIToolbar(frame: CGRectMake(0, screenBounds().height-toolBarHeight, view.frame.width, toolBarHeight))
        toolBar.autoresizingMask = .FlexibleWidth
        toolBar.barTintColor = UIColor(rgba: "#FF7900")
        toolBar.tintColor = UIColor.whiteColor()
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
        let iconSearch = UIBarButtonItem(image: imageSearch, style: .Plain, target: self, action: "didSelectHighlight:")
        iconSearch.width = space
        let iconFont = UIBarButtonItem(image: imageFont, style: .Plain, target: self, action: "didSelectHighlight:")
        iconFont.width = space
        toolBar.setItems([iconHighlight, iconSearch, iconFont], animated: false)
        
        
        // Register cell classes
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...
        cell.textLabel?.text = "Chapter \(indexPath.row+1)"
        cell.textLabel?.font = UIFont(name: "Avenir-Light ", size: 17)
        cell.textLabel?.textColor = UIColor(rgba: "#575757")
        
        cell.backgroundColor = UIColor.clearColor()

        return cell
    }
    
    // MARK: - Table view delegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectedIndex(indexPath)
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
    
    func didSelectHighlight(sender: UIBarButtonItem) {
        println("highlight")
    }

}
