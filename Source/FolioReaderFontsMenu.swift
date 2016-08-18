//
//  FolioReaderFontsMenu.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 27/08/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderFontsMenu: UIViewController, SMSegmentViewDelegate, UIGestureRecognizerDelegate {
    
    var menuView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clearColor()
        
        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FolioReaderFontsMenu.tapGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        // Menu view
        let visibleHeight: CGFloat = readerConfig.canChangeScrollDirection ? 222 : 170
        menuView = UIView(frame: CGRectMake(0, view.frame.height-visibleHeight, view.frame.width, view.frame.height))
        menuView.backgroundColor = isNight(readerConfig.nightModeMenuBackground, UIColor.whiteColor())
        menuView.autoresizingMask = .FlexibleWidth
        menuView.layer.shadowColor = UIColor.blackColor().CGColor
        menuView.layer.shadowOffset = CGSize(width: 0, height: 0)
        menuView.layer.shadowOpacity = 0.3
        menuView.layer.shadowRadius = 6
        menuView.layer.shadowPath = UIBezierPath(rect: menuView.bounds).CGPath
        menuView.layer.rasterizationScale = UIScreen.mainScreen().scale
        menuView.layer.shouldRasterize = true
        view.addSubview(menuView)
        
        let normalColor = UIColor(white: 0.5, alpha: 0.7)
        let selectedColor = readerConfig.tintColor
        let sun = UIImage(readerImageNamed: "icon-sun")
        let moon = UIImage(readerImageNamed: "icon-moon")
        let fontSmall = UIImage(readerImageNamed: "icon-font-small")
        let fontBig = UIImage(readerImageNamed: "icon-font-big")
        
        let sunNormal = sun!.imageTintColor(normalColor).imageWithRenderingMode(.AlwaysOriginal)
        let moonNormal = moon!.imageTintColor(normalColor).imageWithRenderingMode(.AlwaysOriginal)
        let fontSmallNormal = fontSmall!.imageTintColor(normalColor).imageWithRenderingMode(.AlwaysOriginal)
        let fontBigNormal = fontBig!.imageTintColor(normalColor).imageWithRenderingMode(.AlwaysOriginal)
        
        let sunSelected = sun!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)
        let moonSelected = moon!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)
        
        // Day night mode
        let dayNight = SMSegmentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 55),
            separatorColour: readerConfig.nightModeSeparatorColor,
            separatorWidth: 1,
            segmentProperties:  [
                keySegmentTitleFont: UIFont(name: "Avenir-Light", size: 17)!,
                keySegmentOnSelectionColour: UIColor.clearColor(),
                keySegmentOffSelectionColour: UIColor.clearColor(),
                keySegmentOnSelectionTextColour: selectedColor,
                keySegmentOffSelectionTextColour: normalColor,
                keyContentVerticalMargin: 17
            ])
        dayNight.delegate = self
        dayNight.tag = 1
        dayNight.addSegmentWithTitle(readerConfig.localizedFontMenuDay, onSelectionImage: sunSelected, offSelectionImage: sunNormal)
        dayNight.addSegmentWithTitle(readerConfig.localizedFontMenuNight, onSelectionImage: moonSelected, offSelectionImage: moonNormal)
        dayNight.selectSegmentAtIndex(Int(FolioReader.nightMode))
        menuView.addSubview(dayNight)
        
        
        // Separator
        let line = UIView(frame: CGRectMake(0, dayNight.frame.height+dayNight.frame.origin.y, view.frame.width, 1))
        line.backgroundColor = readerConfig.nightModeSeparatorColor
        menuView.addSubview(line)

        // Fonts adjust
        let fontName = SMSegmentView(frame: CGRect(x: 15, y: line.frame.height+line.frame.origin.y, width: view.frame.width-30, height: 55),
            separatorColour: UIColor.clearColor(),
            separatorWidth: 0,
            segmentProperties:  [
                keySegmentOnSelectionColour: UIColor.clearColor(),
                keySegmentOffSelectionColour: UIColor.clearColor(),
                keySegmentOnSelectionTextColour: selectedColor,
                keySegmentOffSelectionTextColour: normalColor,
                keyContentVerticalMargin: 17
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
        fontName.selectSegmentAtIndex(FolioReader.currentFontName)
        menuView.addSubview(fontName)
        
        // Separator 2
        let line2 = UIView(frame: CGRectMake(0, fontName.frame.height+fontName.frame.origin.y, view.frame.width, 1))
        line2.backgroundColor = readerConfig.nightModeSeparatorColor
        menuView.addSubview(line2)
        
        // Font slider size
        let slider = HADiscreteSlider(frame: CGRect(x: 60, y: line2.frame.origin.y+2, width: view.frame.width-120, height: 55))
        slider.tickStyle = ComponentStyle.Rounded
        slider.tickCount = 5
        slider.tickSize = CGSize(width: 8, height: 8)
        
        slider.thumbStyle = ComponentStyle.Rounded
        slider.thumbSize = CGSize(width: 28, height: 28)
        slider.thumbShadowOffset = CGSize(width: 0, height: 2)
        slider.thumbShadowRadius = 3
        slider.thumbColor = selectedColor
        
        slider.backgroundColor = UIColor.clearColor()
        slider.tintColor = readerConfig.nightModeSeparatorColor
        slider.minimumValue = 0
        slider.value = CGFloat(FolioReader.currentFontSize)
        slider.addTarget(self, action: #selector(FolioReaderFontsMenu.sliderValueChanged(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        // Force remove fill color
        slider.layer.sublayers?.forEach({ layer in
            layer.backgroundColor = UIColor.clearColor().CGColor
        })
        
        menuView.addSubview(slider)
        
        // Font icons
        let fontSmallView = UIImageView(frame: CGRect(x: 20, y: line2.frame.origin.y+14, width: 30, height: 30))
        fontSmallView.image = fontSmallNormal
        fontSmallView.contentMode = UIViewContentMode.Center
        menuView.addSubview(fontSmallView)
        
        let fontBigView = UIImageView(frame: CGRect(x: view.frame.width-50, y: line2.frame.origin.y+14, width: 30, height: 30))
        fontBigView.image = fontBigNormal
        fontBigView.contentMode = UIViewContentMode.Center
        menuView.addSubview(fontBigView)
        
        // Only continues if user can change scroll direction
        guard readerConfig.canChangeScrollDirection else { return }
        
        // Separator 3
        let line3 = UIView(frame: CGRectMake(0, line2.frame.origin.y+56, view.frame.width, 1))
        line3.backgroundColor = readerConfig.nightModeSeparatorColor
        menuView.addSubview(line3)
        
        let vertical = UIImage(readerImageNamed: "icon-menu-vertical")
        let horizontal = UIImage(readerImageNamed: "icon-menu-horizontal")
        let verticalNormal = vertical!.imageTintColor(normalColor).imageWithRenderingMode(.AlwaysOriginal)
        let horizontalNormal = horizontal!.imageTintColor(normalColor).imageWithRenderingMode(.AlwaysOriginal)
        let verticalSelected = vertical!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)
        let horizontalSelected = horizontal!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)
        
        // Layout direction
        let layoutDirection = SMSegmentView(frame: CGRect(x: 0, y: line3.frame.origin.y, width: view.frame.width, height: 55),
                                     separatorColour: readerConfig.nightModeSeparatorColor,
                                     separatorWidth: 1,
                                     segmentProperties:  [
                                        keySegmentTitleFont: UIFont(name: "Avenir-Light", size: 17)!,
                                        keySegmentOnSelectionColour: UIColor.clearColor(),
                                        keySegmentOffSelectionColour: UIColor.clearColor(),
                                        keySegmentOnSelectionTextColour: selectedColor,
                                        keySegmentOffSelectionTextColour: normalColor,
                                        keyContentVerticalMargin: 17
            ])
        layoutDirection.delegate = self
        layoutDirection.tag = 3
        layoutDirection.addSegmentWithTitle(readerConfig.localizedLayoutVertical, onSelectionImage: verticalSelected, offSelectionImage: verticalNormal)
        layoutDirection.addSegmentWithTitle(readerConfig.localizedLayoutHorizontal, onSelectionImage: horizontalSelected, offSelectionImage: horizontalNormal)
        layoutDirection.selectSegmentAtIndex(Int(FolioReader.currentScrollDirection))
        menuView.addSubview(layoutDirection)
    }
    
    // MARK: - SMSegmentView delegate
    
    func segmentView(segmentView: SMSegmentView, didSelectSegmentAtIndex index: Int) {
        guard let currentPage = FolioReader.sharedInstance.readerCenter.currentPage else { return }
        
        if segmentView.tag == 1 {

            FolioReader.nightMode = Bool(index)
            
            let readerCenter = FolioReader.sharedInstance.readerCenter
            
            switch index {
            case 0:
                currentPage.webView.js("nightMode(false)")
                UIView.animateWithDuration(0.6, animations: {
                    self.menuView.backgroundColor = UIColor.whiteColor()
                    readerCenter.collectionView.backgroundColor = UIColor.whiteColor()
                    readerCenter.configureNavBar()
                    readerCenter.scrollScrubber?.updateColors()
                })
                break
            case 1:
                currentPage.webView.js("nightMode(true)")
                UIView.animateWithDuration(0.6, animations: {
                    self.menuView.backgroundColor = readerConfig.nightModeMenuBackground
                    readerCenter.collectionView.backgroundColor = readerConfig.nightModeBackground
                    readerCenter.configureNavBar()
                    readerCenter.scrollScrubber?.updateColors()
                })
                break
            default:
                break
            }
            
            NSNotificationCenter.defaultCenter().postNotificationName("needRefreshPageMode", object: nil)
        }
        
        if segmentView.tag == 2 {
            switch index {
            case 0:
                currentPage.webView.js("setFontName('andada')")
                break
            case 1:
                currentPage.webView.js("setFontName('lato')")
                break
            case 2:
                currentPage.webView.js("setFontName('lora')")
                break
            case 3:
                currentPage.webView.js("setFontName('raleway')")
                break
            default:
                break
            }
            
            FolioReader.currentFontName = index
        }
        
        if segmentView.tag == 3 {
            guard FolioReader.currentScrollDirection != index else { return }
            
            let direction = FolioReaderScrollDirection(rawValue: index) ?? .vertical
            FolioReader.sharedInstance.readerCenter.setScrollDirection(direction)
            FolioReader.currentScrollDirection = index
        }
    }
    
    // MARK: - Font slider changed
    
    func sliderValueChanged(sender: HADiscreteSlider) {
        guard let currentPage = FolioReader.sharedInstance.readerCenter.currentPage else { return }
        let index = Int(sender.value)
        
        switch index {
        case 0:
            currentPage.webView.js("setFontSize('textSizeOne')")
            break
        case 1:
            currentPage.webView.js("setFontSize('textSizeTwo')")
            break
        case 2:
            currentPage.webView.js("setFontSize('textSizeThree')")
            break
        case 3:
            currentPage.webView.js("setFontSize('textSizeFour')")
            break
        case 4:
            currentPage.webView.js("setFontSize('textSizeFive')")
            break
        default:
            break
        }
        
        FolioReader.currentFontSize = index
    }
    
    // MARK: - Gestures
    
    func tapGesture() {
        dismiss()
        
        if readerConfig.shouldHideNavigationOnTap == false {
            FolioReader.sharedInstance.readerCenter.showBars()
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer && touch.view == view {
            return true
        }
        return false
    }
    
    // MARK: - Status Bar
    
    override func prefersStatusBarHidden() -> Bool {
        return readerConfig.shouldHideNavigationOnTap == true
    }
}
