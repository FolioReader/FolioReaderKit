//
//  FolioReaderConfig.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

// MARK: - FolioReaderScrollDirection

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

// MARK: - ClassBasedOnClickListener

/**
A `ClassBasedOnClickListener` takes a closure which is performed if a given html `class` is clicked. The closure will reveice the content of the specified parameter.

Eg. A ClassBasedOnClickListener with the className "quote" and parameterName "id" with the given epub html content "<section class="quote" id="12345">" would call the given closure on a click on this section with the String "12345" as parameter.

*/
public struct ClassBasedOnClickListener {

	/// The name of the URL scheme which should be used. Note: Make sure that the given `String` is a valid as scheme name.
	public var schemeName			: String

	/// The query selector for the elements which the listener should be added to. See https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector for further information about query selectors.
	public var querySelector		: String

	/// The name of the attribute whose content should be passed to the `onClickAction` action.
	public var attributeName		: String

	/// Whether the listener should be added to all found elements or only to the first one. See https://developer.mozilla.org/en-US/docs/Web/API/Element/querySelectorAll for further information. The default value is `true`.
	public var selectAll			: Bool

	/// The closure which will be called if the specified class was clicked. `attributeContent` contains the string content of the specified attribute and `touchPointRelativeToWebView` reprsents the touch point relative to the web view.
	public var onClickAction		: ((attributeContent: String?, touchPointRelativeToWebView: CGPoint) -> Void)

	/// Initializes a `ClassBasedOnClickListener` instance. Append it to the `classBasedOnClickListeners` property from the `FolioReaderConfig` to receive on click events. The default `selectAll` value is `true`.
	/**
	Initializes a `ClassBasedOnClickListener` instance. Append it to the `classBasedOnClickListeners` property from the `FolioReaderConfig` to receive on click events.
	
	- parameter schemeName: The name of the URL scheme which should be used. Note: Make sure that the given `String` is a valid as scheme name.
	- parameter querySelector: The query selector for the elements which the listener should be added to. See https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector for further information about query selectors.
	- parameter attributeName: The name of the attribute whose content should be passed to the `onClickAction` action.
	- parameter selectAll: Whether the listener should be added to all found elements or only to the first one. See https://developer.mozilla.org/en-US/docs/Web/API/Element/querySelectorAll for further information. The default value is `true`.
	- parameter onClickAction: The closure which will be called if the specified class was clicked. `attributeContent` contains the string content of the specified attribute and `touchPointRelativeToWebView` reprsents the touch point relative to the web view.
	*/
	public init(schemeName: String, querySelector: String, attributeName: String, selectAll: Bool = true, onClickAction: ((attributeContent: String?, touchPointRelativeToWebView: CGPoint) -> Void)) {
		self.schemeName = schemeName.lowercaseString
		self.querySelector = querySelector
		self.attributeName = attributeName
		self.selectAll = selectAll
		self.onClickAction = onClickAction
	}
}

// MARK: - FolioReaderConfig

/**
 Defines the Reader custom configuration
 */
public class FolioReaderConfig: NSObject {

	// MARK: ClassBasedOnClickListener

	/**
	Array of `ClassBasedOnClickListener` objects. A `ClassBasedOnClickListener` takes a closure which is performed if a given html `class` is clicked. The closure will reveice the content of the specified parameter.
	
	Eg. A ClassBasedOnClickListener with the className "quote" and parameterName "id" with the given epub html content "<section class="quote" id="12345">" would call the given closure on a click on this section with the String "12345" as parameter.
	
	*/
	public var classBasedOnClickListeners = [ClassBasedOnClickListener]()

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
    
    // MARK: Quote image share
    
    /// Custom Quote logo
    public var quoteCustomLogoImage = UIImage(readerImageNamed: "icon-logo")
    
    /// Add custom backgrounds and font colors to Quote Images
    public var quoteCustomBackgrounds = [QuoteImage]()
    
    /// Enable or disable default Quote Image backgrounds
    public var quotePreserveDefaultBackgrounds = true
    
    // MARK: Localized strings
    
    /// Localizes Highlight title
    public var localizedHighlightsTitle = NSLocalizedString("Highlights", comment: "")
   
    /// Localizes Content title
    public var localizedContentsTitle = NSLocalizedString("Contents", comment: "")

	/// Use the readers `UIMenuController` which enables the highlighting etc. The default is `true`. If set to false it's possible to modify the shared `UIMenuController` for yourself. Note: This doesn't disable the text selection in the web view.
	public var useReaderMenuController = true
	
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
    public var localizedShareWebLink: NSURL? = nil
    public var localizedShareChapterSubject = NSLocalizedString("Check out this chapter from", comment: "")
    public var localizedShareHighlightSubject = NSLocalizedString("Notes from", comment: "")
    public var localizedShareAllExcerptsFrom = NSLocalizedString("All excerpts from", comment: "")
    public var localizedShareBy = NSLocalizedString("by", comment: "")
    public var localizedCancel = NSLocalizedString("Cancel", comment: "")
    public var localizedShare = NSLocalizedString("Share", comment: "")
    public var localizedChooseExisting = NSLocalizedString("Choose existing", comment: "")
    public var localizedTakePhoto = NSLocalizedString("Take Photo", comment: "")
    public var localizedShareImageQuote = NSLocalizedString("Share image quote", comment: "")
    public var localizedShareTextQuote = NSLocalizedString("Share text quote", comment: "")
}
