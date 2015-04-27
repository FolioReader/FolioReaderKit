//
//  FolioReaderConfig.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import Foundation

public class FolioReaderConfig: NSObject {
    public var toolBarBackgroundColor: UIColor!
    public var toolBarTintColor: UIColor!
    public var menuBackgroundColor: UIColor!
    public var menuSeparatorColor: UIColor!
    public var menuTextColor: UIColor!
    
    // MARK: - Init with defaults
    
    public override init() {
        self.toolBarBackgroundColor = UIColor(rgba: "#FF7900")
        self.toolBarTintColor = UIColor.whiteColor()
        self.menuBackgroundColor = UIColor(rgba: "#F5F5F5")
        self.menuSeparatorColor = UIColor(rgba: "#D7D7D7")
        self.menuTextColor = UIColor(rgba: "#575757")
        
        super.init()
    }
}
