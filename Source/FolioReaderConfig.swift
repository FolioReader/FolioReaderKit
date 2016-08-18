//
//  FolioReaderConfig.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

/**
 Defines the Reader scrolling direction
 */
public enum FolioReaderScrollDirection: Int {
    
    /// Section and content scroll on vertical
    case vertical
    
    /// Section and content scroll on horizontal
    case horizontal
    
    /// Sections scroll horizontal and content scroll on vertical
	case horizontalWithVerticalContent
    
    /**
     The current scroll direction
     
     - returns: Returns `UICollectionViewScrollDirection`
     */
    func collectionViewScrollDirection() -> UICollectionViewScrollDirection {
        switch self {
        case vertical:
            return .Vertical
        case horizontal, horizontalWithVerticalContent:
            return .Horizontal
        }
    }
}


/**
 Defines the Reader custom configuration
 */
public class FolioReaderConfig: NSObject {
    
    // MARK: Colors
    
    /// Base header custom TintColor
    public var tintColor = UIColor(rgba: "#6ACC50")
    
    /// Menu background color
    public var menuBackgroundColor = UIColor.whiteColor()
    
    /// Menu separator Color
    public var menuSeparatorColor = UIColor(rgba: "#D7D7D7")
    
    /// Menu text color
    public var menuTextColor = UIColor(rgba: "#767676")
    
    /// Night mode background color
    public var nightModeBackground = UIColor(rgba: "#131313")
    
    /// Night mode menu background color
    public var nightModeMenuBackground = UIColor(rgba: "#1E1E1E")
    
    /// Night mode separator color
    public var nightModeSeparatorColor = UIColor(white: 0.5, alpha: 0.2)
    
    /// Media overlay or TTS selection color
    public lazy var mediaOverlayColor: UIColor! = self.tintColor
    
    // MARK: Custom actions
    
	/// hide the navigation bar and the bottom status view 
	public var hideBars = false

    /// If `canChangeScrollDirection` is `true` it will be overrided by user's option.
    public var scrollDirection: FolioReaderScrollDirection = .vertical
    
    /// Enable or disable hability to user change scroll direction on menu.
    public var canChangeScrollDirection = true
    
    /// Should hide navigation bar on user tap
    public var shouldHideNavigationOnTap = true
    
    /// Allow sharing option, if `false` will hide all sharing icons and options
    public var allowSharing = true
    
    /// Enable TTS (Text To Speech)
    public var enableTTS = true
    
    // MARK: Localized strings
    
    /// Localizes Highlight title
    public var localizedHighlightsTitle = NSLocalizedString("Highlights", comment: "")
   
    /// Localizes Content title
    public var localizedContentsTitle = NSLocalizedString("Contents", comment: "")
 
    /// Localizes Highlight date format. This is a `dateFormat` from `NSDateFormatter`, so be careful 🤔
    public var localizedHighlightsDateFormat = "MMM dd, YYYY | HH:mm"
    public var localizedHighlightMenu = NSLocalizedString("Highlight", comment: "")
    public var localizedDefineMenu = NSLocalizedString("Define", comment: "")
    public var localizedPlayMenu = NSLocalizedString("Play", comment: "")
    public var localizedPauseMenu = NSLocalizedString("Pause", comment: "")
    public var localizedFontMenuNight = NSLocalizedString("Night", comment: "")
    public var localizedPlayerMenuStyle = NSLocalizedString("Style", comment: "")
    public var localizedFontMenuDay = NSLocalizedString("Day", comment: "")
    public var localizedLayoutHorizontal = NSLocalizedString("Horizontal", comment: "")
    public var localizedLayoutVertical = NSLocalizedString("Vertical", comment: "")
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
