//
//  FolioReaderFontsMenu.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 27/08/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

public enum FolioReaderFont: Int {
	case andada = 0
	case lato
	case lora
	case raleway

	public static func folioReaderFont(fontName: String) -> FolioReaderFont? {
		var font: FolioReaderFont?
		switch fontName {
		case "andada"		: font = .andada
		case "lato"			: font = .lato
		case "lora"			: font = .lora
		case "raleway"		: font = .raleway
		default 			: break
		}
		return font
	}

	public var cssIdentifier: String {
		switch self {
		case .andada	: return "andada"
		case .lato		: return "lato"
		case .lora		: return "lora"
		case .raleway	: return "raleway"
		}
	}
}

public enum FolioReaderFontSize: Int {
	case xs = 0
	case s
	case m
	case l
	case xl

	public static func folioReaderFontSize(fontSizeStringRepresentation: String) -> FolioReaderFontSize? {
		var fontSize: FolioReaderFontSize?
		switch fontSizeStringRepresentation {
		case "textSizeOne"		: fontSize = .xs
		case "textSizeTwo"		: fontSize = .s
		case "textSizeThree"	: fontSize = .m
		case "textSizeFour"		: fontSize = .l
		case "textSizeFive"		: fontSize = .xl
		default 				: break
		}
		return fontSize
	}

	public var cssIdentifier: String {
		switch self {
		case .xs	: return "textSizeOne"
		case .s		: return "textSizeTwo"
		case .m		: return "textSizeThree"
		case .l		: return "textSizeFour"
		case .xl	: return "textSizeFive"
		}
	}
}

class FolioReaderFontsMenu: UIViewController, SMSegmentViewDelegate, UIGestureRecognizerDelegate {
    
    var menuView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear
        
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FolioReaderFontsMenu.tapGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        // Menu view
        let visibleHeight: CGFloat = readerConfig.canChangeScrollDirection ? 222 : 170
        menuView = UIView(frame: CGRect(x: 0, y: view.frame.height-visibleHeight, width: view.frame.width, height: view.frame.height))
        menuView.backgroundColor = isNight(readerConfig.nightModeMenuBackground, UIColor.white)
        menuView.autoresizingMask = .flexibleWidth
        menuView.layer.shadowColor = UIColor.black.cgColor
        menuView.layer.shadowOffset = CGSize(width: 0, height: 0)
        menuView.layer.shadowOpacity = 0.3
        menuView.layer.shadowRadius = 6
        menuView.layer.shadowPath = UIBezierPath(rect: menuView.bounds).cgPath
        menuView.layer.rasterizationScale = UIScreen.main.scale
        menuView.layer.shouldRasterize = true
        view.addSubview(menuView)
        
        let normalColor = UIColor(white: 0.5, alpha: 0.7)
        let selectedColor = readerConfig.tintColor
        let sun = UIImage(readerImageNamed: "icon-sun")
        let moon = UIImage(readerImageNamed: "icon-moon")
        let fontSmall = UIImage(readerImageNamed: "icon-font-small")
        let fontBig = UIImage(readerImageNamed: "icon-font-big")
        
        let sunNormal = sun!.imageTintColor(normalColor).withRenderingMode(.alwaysOriginal)
        let moonNormal = moon!.imageTintColor(normalColor).withRenderingMode(.alwaysOriginal)
        let fontSmallNormal = fontSmall!.imageTintColor(normalColor).withRenderingMode(.alwaysOriginal)
        let fontBigNormal = fontBig!.imageTintColor(normalColor).withRenderingMode(.alwaysOriginal)
        
        let sunSelected = sun!.imageTintColor(selectedColor).withRenderingMode(.alwaysOriginal)
        let moonSelected = moon!.imageTintColor(selectedColor).withRenderingMode(.alwaysOriginal)
        
        // Day night mode
        let dayNight = SMSegmentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 55),
            separatorColour: readerConfig.nightModeSeparatorColor,
            separatorWidth: 1,
            segmentProperties:  [
                keySegmentTitleFont: UIFont(name: "Avenir-Light", size: 17)!,
                keySegmentOnSelectionColour: UIColor.clear,
                keySegmentOffSelectionColour: UIColor.clear,
                keySegmentOnSelectionTextColour: selectedColor,
                keySegmentOffSelectionTextColour: normalColor,
                keyContentVerticalMargin: 17 as AnyObject
            ])
        dayNight.delegate = self
        dayNight.tag = 1
        dayNight.addSegmentWithTitle(readerConfig.localizedFontMenuDay, onSelectionImage: sunSelected, offSelectionImage: sunNormal)
        dayNight.addSegmentWithTitle(readerConfig.localizedFontMenuNight, onSelectionImage: moonSelected, offSelectionImage: moonNormal)
        dayNight.selectSegmentAtIndex(FolioReader.nightMode.hashValue)
        menuView.addSubview(dayNight)
        
        
        // Separator
        let line = UIView(frame: CGRect(x: 0, y: dayNight.frame.height+dayNight.frame.origin.y, width: view.frame.width, height: 1))
        line.backgroundColor = readerConfig.nightModeSeparatorColor
        menuView.addSubview(line)

        // Fonts adjust
        let fontName = SMSegmentView(frame: CGRect(x: 15, y: line.frame.height+line.frame.origin.y, width: view.frame.width-30, height: 55),
            separatorColour: UIColor.clear,
            separatorWidth: 0,
            segmentProperties:  [
                keySegmentOnSelectionColour: UIColor.clear,
                keySegmentOffSelectionColour: UIColor.clear,
                keySegmentOnSelectionTextColour: selectedColor,
                keySegmentOffSelectionTextColour: normalColor,
                keyContentVerticalMargin: 17 as AnyObject
            ])
        fontName.delegate = self
        fontName.tag = 2
        fontName.addSegmentWithTitle("Andada", onSelectionImage: nil, offSelectionImage: nil)
        fontName.addSegmentWithTitle("Lato", onSelectionImage: nil, offSelectionImage: nil)
        fontName.addSegmentWithTitle("Lora", onSelectionImage: nil, offSelectionImage: nil)
        fontName.addSegmentWithTitle("Raleway", onSelectionImage: nil, offSelectionImage: nil)
        fontName.segments[0].titleFont = UIFont(name: "Andada-Regular", size: 18)!
        fontName.segments[1].titleFont = UIFont(name: "Lato-Regular", size: 18)!
        fontName.segments[2].titleFont = UIFont(name: "Lora-Regular", size: 18)!
        fontName.segments[3].titleFont = UIFont(name: "Raleway-Regular", size: 18)!

		fontName.selectSegmentAtIndex(FolioReader.currentFont.rawValue)
        menuView.addSubview(fontName)
        
        // Separator 2
        let line2 = UIView(frame: CGRect(x: 0, y: fontName.frame.height+fontName.frame.origin.y, width: view.frame.width, height: 1))
        line2.backgroundColor = readerConfig.nightModeSeparatorColor
        menuView.addSubview(line2)
        
        // Font slider size
        let slider = HADiscreteSlider(frame: CGRect(x: 60, y: line2.frame.origin.y+2, width: view.frame.width-120, height: 55))
        slider.tickStyle = ComponentStyle.rounded
        slider.tickCount = 5
        slider.tickSize = CGSize(width: 8, height: 8)
        
        slider.thumbStyle = ComponentStyle.rounded
        slider.thumbSize = CGSize(width: 28, height: 28)
        slider.thumbShadowOffset = CGSize(width: 0, height: 2)
        slider.thumbShadowRadius = 3
        slider.thumbColor = selectedColor
        
        slider.backgroundColor = UIColor.clear
        slider.tintColor = readerConfig.nightModeSeparatorColor
        slider.minimumValue = 0
        slider.value = CGFloat(FolioReader.currentFontSize.rawValue)
        slider.addTarget(self, action: #selector(FolioReaderFontsMenu.sliderValueChanged(_:)), for: UIControlEvents.valueChanged)
        
        // Force remove fill color
        slider.layer.sublayers?.forEach({ layer in
            layer.backgroundColor = UIColor.clear.cgColor
        })
        
        menuView.addSubview(slider)
        
        // Font icons
        let fontSmallView = UIImageView(frame: CGRect(x: 20, y: line2.frame.origin.y+14, width: 30, height: 30))
        fontSmallView.image = fontSmallNormal
        fontSmallView.contentMode = UIViewContentMode.center
        menuView.addSubview(fontSmallView)
        
        let fontBigView = UIImageView(frame: CGRect(x: view.frame.width-50, y: line2.frame.origin.y+14, width: 30, height: 30))
        fontBigView.image = fontBigNormal
        fontBigView.contentMode = UIViewContentMode.center
        menuView.addSubview(fontBigView)
        
        // Only continues if user can change scroll direction
        guard readerConfig.canChangeScrollDirection else { return }
        
        // Separator 3
        let line3 = UIView(frame: CGRect(x: 0, y: line2.frame.origin.y+56, width: view.frame.width, height: 1))
        line3.backgroundColor = readerConfig.nightModeSeparatorColor
        menuView.addSubview(line3)
        
        let vertical = UIImage(readerImageNamed: "icon-menu-vertical")
        let horizontal = UIImage(readerImageNamed: "icon-menu-horizontal")
        let verticalNormal = vertical!.imageTintColor(normalColor).withRenderingMode(.alwaysOriginal)
        let horizontalNormal = horizontal!.imageTintColor(normalColor).withRenderingMode(.alwaysOriginal)
        let verticalSelected = vertical!.imageTintColor(selectedColor).withRenderingMode(.alwaysOriginal)
        let horizontalSelected = horizontal!.imageTintColor(selectedColor).withRenderingMode(.alwaysOriginal)
        
        // Layout direction
        let layoutDirection = SMSegmentView(frame: CGRect(x: 0, y: line3.frame.origin.y, width: view.frame.width, height: 55),
                                     separatorColour: readerConfig.nightModeSeparatorColor,
                                     separatorWidth: 1,
                                     segmentProperties:  [
                                        keySegmentTitleFont: UIFont(name: "Avenir-Light", size: 17)!,
                                        keySegmentOnSelectionColour: UIColor.clear,
                                        keySegmentOffSelectionColour: UIColor.clear,
                                        keySegmentOnSelectionTextColour: selectedColor,
                                        keySegmentOffSelectionTextColour: normalColor,
                                        keyContentVerticalMargin: 17 as AnyObject
            ])
        layoutDirection.delegate = self
        layoutDirection.tag = 3
        layoutDirection.addSegmentWithTitle(readerConfig.localizedLayoutVertical, onSelectionImage: verticalSelected, offSelectionImage: verticalNormal)
        layoutDirection.addSegmentWithTitle(readerConfig.localizedLayoutHorizontal, onSelectionImage: horizontalSelected, offSelectionImage: horizontalNormal)

        var scrollDirection = FolioReaderScrollDirection(rawValue: FolioReader.currentScrollDirection)

        if scrollDirection == .defaultVertical && readerConfig.scrollDirection != .defaultVertical {
            scrollDirection = readerConfig.scrollDirection
        }

        layoutDirection.selectSegmentAtIndex(scrollDirection?.rawValue ?? 0)
        menuView.addSubview(layoutDirection)
    }
    
    // MARK: - SMSegmentView delegate
    
    func segmentView(_ segmentView: SMSegmentView, didSelectSegmentAtIndex index: Int) {
        guard (FolioReader.shared.readerCenter?.currentPage) != nil else { return }
        
        if segmentView.tag == 1 {

			FolioReader.nightMode = Bool(index == 1)

			UIView.animate(withDuration: 0.6, animations: {
				self.menuView.backgroundColor = (FolioReader.nightMode ?readerConfig.nightModeBackground : UIColor.white)
			})

		} else if segmentView.tag == 2 {

			FolioReader.currentFont = FolioReaderFont(rawValue: index)!

        }  else if segmentView.tag == 3 {

			guard FolioReader.currentScrollDirection != index else { return }
            
            FolioReader.currentScrollDirection = index
        }
    }
    
    // MARK: - Font slider changed
    
    func sliderValueChanged(_ sender: HADiscreteSlider) {
        guard (FolioReader.shared.readerCenter?.currentPage) != nil else { return }
        let index = Int(sender.value)

		if let _fontSize = FolioReaderFontSize(rawValue: index) {
			FolioReader.currentFontSize = _fontSize
		}
    }
    
    // MARK: - Gestures
    
    func tapGesture() {
        dismiss()
        
        if readerConfig.shouldHideNavigationOnTap == false {
            FolioReader.shared.readerCenter?.showBars()
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer && touch.view == view {
            return true
        }
        return false
    }
    
    // MARK: - Status Bar
    
    override var prefersStatusBarHidden : Bool {
        return readerConfig.shouldHideNavigationOnTap == true
    }
}
