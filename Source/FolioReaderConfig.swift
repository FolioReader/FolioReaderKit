//
//  FolioReaderConfig.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

public class FolioReaderConfig: NSObject {
    // Reader Colors
    public var tintColor: UIColor!
    public lazy var toolBarBackgroundColor: UIColor! = self.tintColor
    public var toolBarTintColor: UIColor!
    public var menuBackgroundColor: UIColor!
    public var menuSeparatorColor: UIColor!
    public var menuTextColor: UIColor!
    public var nightModeBackground: UIColor!
    public var nightModeMenuBackground: UIColor!
    public var nightModeSeparatorColor: UIColor!
    public lazy var mediaOverlayColor: UIColor! = self.tintColor
    
    // Custom actions
    public var shouldHideNavigationOnTap = true
    public var allowSharing = true
    public var enableTTS = true
    
    // Reader Strings
    public var localizedHighlightsTitle: String
    public var localizedHighlightsDateFormat: String
    public var localizedHighlightMenu: String
    public var localizedDefineMenu: String
    public var localizedPlayMenu: String
    public var localizedPauseMenu: String
    public var localizedFontMenuNight: String
    public var localizedPlayerMenuStyle: String
    public var localizedFontMenuDay: String
    public var localizedReaderOnePageLeft: String
    public var localizedReaderManyPagesLeft: String
    public var localizedReaderManyMinutes: String
    public var localizedReaderOneMinute: String
    public var localizedReaderLessThanOneMinute: String
    public var localizedShareWebLink: String?
    public var localizedShareChapterSubject: String
    public var localizedShareHighlightSubject: String
    public var localizedShareAllExcerptsFrom: String
    public var localizedShareBy: String
    
    // MARK: - Init with defaults
    
    public override init() {
        self.tintColor = UIColor(rgba: "#6ACC50")
        self.toolBarTintColor = UIColor.whiteColor()
        self.menuBackgroundColor = UIColor(rgba: "#F5F5F5")
        self.menuSeparatorColor = UIColor(rgba: "#D7D7D7")
        self.menuTextColor = UIColor(rgba: "#767676")
        self.nightModeBackground = UIColor(rgba: "#131313")
        self.nightModeMenuBackground = UIColor(rgba: "#1E1E1E")
        self.nightModeSeparatorColor = UIColor(white: 0.5, alpha: 0.2)
        
        self.localizedHighlightsTitle = NSLocalizedString("Highlights", comment: "")
        self.localizedHighlightsDateFormat = "MMM dd, YYYY | HH:mm"
        self.localizedHighlightMenu = NSLocalizedString("Highlight", comment: "")
        self.localizedPlayMenu = NSLocalizedString("Play", comment: "")
        self.localizedPauseMenu = NSLocalizedString("Pause", comment: "")
        self.localizedDefineMenu = NSLocalizedString("Define", comment: "")
        self.localizedFontMenuNight = NSLocalizedString("Night", comment: "")
        self.localizedFontMenuDay = NSLocalizedString("Day", comment: "")
        self.localizedPlayerMenuStyle = NSLocalizedString("Style", comment: "")
        self.localizedReaderOnePageLeft = NSLocalizedString("1 page left", comment: "")
        self.localizedReaderManyPagesLeft = NSLocalizedString("pages left", comment: "")
        self.localizedReaderManyMinutes = NSLocalizedString("minutes", comment: "")
        self.localizedReaderOneMinute = NSLocalizedString("1 minute", comment: "")
        self.localizedReaderLessThanOneMinute = NSLocalizedString("Less than a minute", comment: "")
        self.localizedShareWebLink = nil
        self.localizedShareChapterSubject = NSLocalizedString("Check out this chapter from", comment: "")
        self.localizedShareHighlightSubject = NSLocalizedString("Notes from", comment: "")
        self.localizedShareAllExcerptsFrom = NSLocalizedString("All excerpts from", comment: "")
        self.localizedShareBy = NSLocalizedString("by", comment: "")
        
        super.init()
    }
}
