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

    /// The default scroll direction, if not overridden; works as .vertical
    case defaultVertical

    /**
     The current scroll direction
     
     - returns: Returns `UICollectionViewScrollDirection`
     */
    func collectionViewScrollDirection() -> UICollectionViewScrollDirection {
        switch self {
        case .vertical, .defaultVertical:
            return .vertical
        case .horizontal, .horizontalWithVerticalContent:
            return .horizontal
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
	public var onClickAction		: ((_ attributeContent: String?, _ touchPointRelativeToWebView: CGPoint) -> Void)

	/// Initializes a `ClassBasedOnClickListener` instance. Append it to the `classBasedOnClickListeners` property from the `FolioReaderConfig` to receive on click events. The default `selectAll` value is `true`.
	/**
	Initializes a `ClassBasedOnClickListener` instance. Append it to the `classBasedOnClickListeners` property from the `FolioReaderConfig` to receive on click events.
	
	- parameter schemeName: The name of the URL scheme which should be used. Note: Make sure that the given `String` is a valid as scheme name.
	- parameter querySelector: The query selector for the elements which the listener should be added to. See https://developer.mozilla.org/en-US/docs/Web/API/Document/querySelector for further information about query selectors.
	- parameter attributeName: The name of the attribute whose content should be passed to the `onClickAction` action.
	- parameter selectAll: Whether the listener should be added to all found elements or only to the first one. See https://developer.mozilla.org/en-US/docs/Web/API/Element/querySelectorAll for further information. The default value is `true`.
	- parameter onClickAction: The closure which will be called if the specified class was clicked. `attributeContent` contains the string content of the specified attribute and `touchPointRelativeToWebView` reprsents the touch point relative to the web view.
	*/
	public init(schemeName: String, querySelector: String, attributeName: String, selectAll: Bool = true, onClickAction: @escaping ((_ attributeContent: String?, _ touchPointRelativeToWebView: CGPoint) -> Void)) {
		self.schemeName = schemeName.lowercased()
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
open class FolioReaderConfig: NSObject {

	// MARK: ClassBasedOnClickListener

	/**
	Array of `ClassBasedOnClickListener` objects. A `ClassBasedOnClickListener` takes a closure which is performed if a given html `class` is clicked. The closure will reveice the content of the specified parameter.
	
	Eg. A ClassBasedOnClickListener with the className "quote" and parameterName "id" with the given epub html content "<section class="quote" id="12345">" would call the given closure on a click on this section with the String "12345" as parameter.
	
	*/
	open var classBasedOnClickListeners = [ClassBasedOnClickListener]()

    // MARK: Colors
    
    /// Base header custom TintColor
    open var tintColor = UIColor(rgba: "#6ACC50")
    
    /// Menu background color
    open var menuBackgroundColor = UIColor.white
    
    /// Menu separator Color
    open var menuSeparatorColor = UIColor(rgba: "#D7D7D7")
    
    /// Menu text color
    open var menuTextColor = UIColor(rgba: "#767676")
    
    /// Night mode background color
    open var nightModeBackground = UIColor(rgba: "#131313")
    
    /// Night mode menu background color
    open var nightModeMenuBackground = UIColor(rgba: "#1E1E1E")
    
    /// Night mode separator color
    open var nightModeSeparatorColor = UIColor(white: 0.5, alpha: 0.2)
    
    /// Media overlay or TTS selection color
    open lazy var mediaOverlayColor: UIColor! = self.tintColor
    
    // MARK: Custom actions
    
	/// hide the navigation bar and the bottom status view 
	open var hideBars = false

    /// If `canChangeScrollDirection` is `true` it will be overrided by user's option.
    open var scrollDirection: FolioReaderScrollDirection = .defaultVertical
    
    /// Enable or disable hability to user change scroll direction on menu.
    open var canChangeScrollDirection = true
    
    /// Should hide navigation bar on user tap
    open var shouldHideNavigationOnTap = true
    
    /// Allow sharing option, if `false` will hide all sharing icons and options
    open var allowSharing = true
    
    /// Enable TTS (Text To Speech)
    open var enableTTS = true
    
    // hide the page indicator
    open var hidePageIndicator = false
    
    // MARK: Quote image share
    
    /// Custom Quote logo
    open var quoteCustomLogoImage = UIImage(readerImageNamed: "icon-logo")
    
    /// Add custom backgrounds and font colors to Quote Images
    open var quoteCustomBackgrounds = [QuoteImage]()
    
    /// Enable or disable default Quote Image backgrounds
    open var quotePreserveDefaultBackgrounds = true
    
    // MARK: Localized strings
    
    /// Localizes Highlight title
    open var localizedHighlightsTitle = NSLocalizedString("Highlights", comment: "")
   
    /// Localizes Content title
    open var localizedContentsTitle = NSLocalizedString("Contents", comment: "")

	/// Use the readers `UIMenuController` which enables the highlighting etc. The default is `true`. If set to false it's possible to modify the shared `UIMenuController` for yourself. Note: This doesn't disable the text selection in the web view.
	open var useReaderMenuController = true
	
    /// Localizes Highlight date format. This is a `dateFormat` from `NSDateFormatter`, so be careful 🤔
    open var localizedHighlightsDateFormat = "MMM dd, YYYY | HH:mm"
    open var localizedHighlightMenu = NSLocalizedString("Highlight", comment: "")
    open var localizedDefineMenu = NSLocalizedString("Define", comment: "")
    open var localizedPlayMenu = NSLocalizedString("Play", comment: "")
    open var localizedPauseMenu = NSLocalizedString("Pause", comment: "")
    open var localizedFontMenuNight = NSLocalizedString("Night", comment: "")
    open var localizedPlayerMenuStyle = NSLocalizedString("Style", comment: "")
    open var localizedFontMenuDay = NSLocalizedString("Day", comment: "")
    open var localizedLayoutHorizontal = NSLocalizedString("Horizontal", comment: "")
    open var localizedLayoutVertical = NSLocalizedString("Vertical", comment: "")
    open var localizedReaderOnePageLeft = NSLocalizedString("1 page left", comment: "")
    open var localizedReaderManyPagesLeft = NSLocalizedString("pages left", comment: "")
    open var localizedReaderManyMinutes = NSLocalizedString("minutes", comment: "")
    open var localizedReaderOneMinute = NSLocalizedString("1 minute", comment: "")
    open var localizedReaderLessThanOneMinute = NSLocalizedString("Less than a minute", comment: "")
    open var localizedShareWebLink: URL? = nil
    open var localizedShareChapterSubject = NSLocalizedString("Check out this chapter from", comment: "")
    open var localizedShareHighlightSubject = NSLocalizedString("Notes from", comment: "")
    open var localizedShareAllExcerptsFrom = NSLocalizedString("All excerpts from", comment: "")
    open var localizedShareBy = NSLocalizedString("by", comment: "")
    open var localizedCancel = NSLocalizedString("Cancel", comment: "")
    open var localizedShare = NSLocalizedString("Share", comment: "")
    open var localizedChooseExisting = NSLocalizedString("Choose existing", comment: "")
    open var localizedTakePhoto = NSLocalizedString("Take Photo", comment: "")
    open var localizedShareImageQuote = NSLocalizedString("Share image quote", comment: "")
    open var localizedShareTextQuote = NSLocalizedString("Share text quote", comment: "")
}
