//
//  FolioReaderConfig.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

public enum FolioReaderScrollDirection: Int {
    case vertical
    case horizontal
    
    /**
     The current scroll direction
     
     - returns: Returns `UICollectionViewScrollDirection`
     */
    func collectionViewScrollDirection() -> UICollectionViewScrollDirection {
        switch self {
        case vertical:
            return .Vertical
        case horizontal:
            return .Horizontal
        }
    }
}

public class FolioReaderConfig: NSObject {
    // Colors
    public var tintColor = UIColor(rgba: "#6ACC50")
    public var menuBackgroundColor = UIColor.whiteColor()
    public var menuSeparatorColor = UIColor(rgba: "#D7D7D7")
    public var menuTextColor = UIColor(rgba: "#767676")
    public var nightModeBackground = UIColor(rgba: "#131313")
    public var nightModeMenuBackground = UIColor(rgba: "#1E1E1E")
    public var nightModeSeparatorColor = UIColor(white: 0.5, alpha: 0.2)
    public lazy var mediaOverlayColor: UIColor! = self.tintColor
    
    // Custom actions
    public var scrollDirection: FolioReaderScrollDirection = .vertical
    public var shouldHideNavigationOnTap = true
    public var allowSharing = true
    public var enableTTS = true
    
    // Licalized strings
    public var localizedHighlightsTitle = NSLocalizedString("Highlights", comment: "")
    public var localizedHighlightsDateFormat = "MMM dd, YYYY | HH:mm"
    public var localizedHighlightMenu = NSLocalizedString("Highlight", comment: "")
    public var localizedDefineMenu = NSLocalizedString("Define", comment: "")
    public var localizedPlayMenu = NSLocalizedString("Play", comment: "")
    public var localizedPauseMenu = NSLocalizedString("Pause", comment: "")
    public var localizedFontMenuNight = NSLocalizedString("Night", comment: "")
    public var localizedPlayerMenuStyle = NSLocalizedString("Style", comment: "")
    public var localizedFontMenuDay = NSLocalizedString("Day", comment: "")
    public var localizedReaderOnePageLeft = NSLocalizedString("1 page left", comment: "")
    public var localizedReaderManyPagesLeft = NSLocalizedString("pages left", comment: "")
    public var localizedReaderManyMinutes = NSLocalizedString("minutes", comment: "")
    public var localizedReaderOneMinute = NSLocalizedString("1 minute", comment: "")
    public var localizedReaderLessThanOneMinute = NSLocalizedString("Less than a minute", comment: "")
    public var localizedShareWebLink: String? = nil
    public var localizedShareChapterSubject = NSLocalizedString("Check out this chapter from", comment: "")
    public var localizedShareHighlightSubject = NSLocalizedString("Notes from", comment: "")
    public var localizedShareAllExcerptsFrom = NSLocalizedString("All excerpts from", comment: "")
    public var localizedShareBy = NSLocalizedString("by", comment: "")
}
