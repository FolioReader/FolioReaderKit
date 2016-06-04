//
//  FolioReaderFontsMenu.swift
//  FolioReaderKit
//
//  Created by Kevin Jantzer on 1/6/16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderPlayerMenu: UIViewController, SMSegmentViewDelegate {

    var menuView: UIView!
    var playPauseBtn: UIButton!
    var styleOptionBtns = [UIButton]()
    var viewDidAppear = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clearColor()

        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FolioReaderPlayerMenu.tapGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)

        // Menu view
        menuView = UIView(frame: CGRectMake(0, view.frame.height-165, view.frame.width, view.frame.height))
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
        let size = 55
        let padX = 32
        // @NOTE: could this be improved/simplified with autolayout?
        let gutterX = (Int(view.frame.width) - (size * 3 ) - (padX * 4) ) / 2
        
        //let btnX = (Int(view.frame.width) - (size * 3)) / 4
        
        // get icon images
        let play = UIImage(readerImageNamed: "play-icon")
        let pause = UIImage(readerImageNamed: "pause-icon")
        let prev = UIImage(readerImageNamed: "prev-icon")
        let next = UIImage(readerImageNamed: "next-icon")
        let playSelected = play!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)
        let pauseSelected = pause!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)
        
        let prevNormal = prev!.imageTintColor(normalColor).imageWithRenderingMode(.AlwaysOriginal)
        let nextNormal = next!.imageTintColor(normalColor).imageWithRenderingMode(.AlwaysOriginal)
        let prevSelected = prev!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)
        let nextSelected = next!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)
        
        // prev button
        let prevBtn = UIButton(frame: CGRect(x: gutterX + padX, y: 0, width: size, height: size))
        prevBtn.setImage(prevNormal, forState: .Normal)
        prevBtn.setImage(prevSelected, forState: .Selected)
        prevBtn.addTarget(self, action: #selector(FolioReaderPlayerMenu.prevChapter(_:)), forControlEvents: .TouchUpInside)
        menuView.addSubview(prevBtn)
        
        // play / pause button
        let playPauseBtn = UIButton(frame: CGRect(x: Int(prevBtn.frame.origin.x) + padX + size, y: 0, width: size, height: size))
        playPauseBtn.setTitleColor(selectedColor, forState: .Normal)
        playPauseBtn.setTitleColor(selectedColor, forState: .Selected)
        playPauseBtn.setImage(playSelected, forState: .Normal)
        playPauseBtn.setImage(pauseSelected, forState: .Selected)
        playPauseBtn.titleLabel!.font = UIFont(name: "Avenir", size: 22)!
        playPauseBtn.addTarget(self, action: #selector(FolioReaderPlayerMenu.togglePlay(_:)), forControlEvents: .TouchUpInside)
        menuView.addSubview(playPauseBtn)
        
        if FolioReader.sharedInstance.readerAudioPlayer.isPlaying() {
            playPauseBtn.selected = true
        }
        
        // next button
        let nextBtn = UIButton(frame: CGRect(x: Int(playPauseBtn.frame.origin.x) + padX + size, y: 0, width: size, height: size))
        nextBtn.setImage(nextNormal, forState: .Normal)
        nextBtn.setImage(nextSelected, forState: .Selected)
        nextBtn.addTarget(self, action: #selector(FolioReaderPlayerMenu.nextChapter(_:)), forControlEvents: .TouchUpInside)
        menuView.addSubview(nextBtn)
        

        // Separator
        let line = UIView(frame: CGRectMake(0, playPauseBtn.frame.height+playPauseBtn.frame.origin.y, view.frame.width, 1))
        line.backgroundColor = readerConfig.nightModeSeparatorColor
        menuView.addSubview(line)

        // audio playback rate adjust
        let playbackRate = SMSegmentView(frame: CGRect(x: 15, y: line.frame.height+line.frame.origin.y, width: view.frame.width-30, height: 55),
            separatorColour: UIColor.clearColor(),
            separatorWidth: 0,
            segmentProperties:  [
                keySegmentOnSelectionColour: UIColor.clearColor(),
                keySegmentOffSelectionColour: UIColor.clearColor(),
                keySegmentOnSelectionTextColour: selectedColor,
                keySegmentOffSelectionTextColour: normalColor,
                keyContentVerticalMargin: 17
            ])
        playbackRate.delegate = self
        playbackRate.tag = 2
        playbackRate.addSegmentWithTitle("½x", onSelectionImage: nil, offSelectionImage: nil)
        playbackRate.addSegmentWithTitle("1x", onSelectionImage: nil, offSelectionImage: nil)
        playbackRate.addSegmentWithTitle("1½x", onSelectionImage: nil, offSelectionImage: nil)
        playbackRate.addSegmentWithTitle("2x", onSelectionImage: nil, offSelectionImage: nil)
        playbackRate.segmentTitleFont = UIFont(name: "Avenir-Light", size: 17)!
        playbackRate.selectSegmentAtIndex(Int(FolioReader.sharedInstance.currentAudioRate))
        menuView.addSubview(playbackRate)
        
        
        // Separator
        let line2 = UIView(frame: CGRectMake(0, playbackRate.frame.height+playbackRate.frame.origin.y, view.frame.width, 1))
        line2.backgroundColor = readerConfig.nightModeSeparatorColor
        menuView.addSubview(line2)
        
        
        // Media overlay highlight styles
        let style0 = UIButton(frame: CGRectMake(0, line2.frame.height+line2.frame.origin.y, view.frame.width/3, 55))
        style0.titleLabel!.textAlignment = .Center
        style0.titleLabel!.font = UIFont(name: "Avenir-Light", size: 17)
        style0.setTitleColor(isNight(readerConfig.nightModeMenuBackground, UIColor.whiteColor()), forState: .Normal)
        style0.setTitleColor(isNight(readerConfig.nightModeMenuBackground, UIColor.whiteColor()), forState: .Selected)
        style0.setTitle(readerConfig.localizedPlayerMenuStyle, forState: .Normal)
        menuView.addSubview(style0);
        style0.titleLabel?.sizeToFit()
        let style0Bgd = UIView(frame: style0.titleLabel!.frame)
        style0Bgd.center = CGPointMake(style0.frame.size.width  / 2, style0.frame.size.height / 2);
        style0Bgd.frame.size.width += 8
        style0Bgd.frame.origin.x -= 4
        style0Bgd.backgroundColor = normalColor;
        style0Bgd.layer.cornerRadius = 3.0;
        style0Bgd.userInteractionEnabled = false
        style0.insertSubview(style0Bgd, belowSubview: style0.titleLabel!)
        
        let style1 = UIButton(frame: CGRectMake(view.frame.width/3, line2.frame.height+line2.frame.origin.y, view.frame.width/3, 55))
        style1.titleLabel!.textAlignment = .Center
        style1.titleLabel!.font = UIFont(name: "Avenir-Light", size: 17)
        style1.setTitleColor(normalColor, forState: .Normal)
        style1.setAttributedTitle(NSAttributedString(string: "Style", attributes: [
            NSForegroundColorAttributeName: normalColor,
            NSUnderlineStyleAttributeName: NSUnderlineStyle.PatternDot.rawValue|NSUnderlineStyle.StyleSingle.rawValue,
            NSUnderlineColorAttributeName: normalColor
        ]), forState: .Normal)
        style1.setAttributedTitle(NSAttributedString(string: readerConfig.localizedPlayerMenuStyle, attributes: [
            NSForegroundColorAttributeName: isNight(UIColor.whiteColor(), UIColor.blackColor()),
            NSUnderlineStyleAttributeName: NSUnderlineStyle.PatternDot.rawValue|NSUnderlineStyle.StyleSingle.rawValue,
            NSUnderlineColorAttributeName: selectedColor
            ]), forState: .Selected)
        menuView.addSubview(style1);
        
        let style2 = UIButton(frame: CGRectMake(view.frame.width/1.5, line2.frame.height+line2.frame.origin.y, view.frame.width/3, 55))
        style2.titleLabel!.textAlignment = .Center
        style2.titleLabel!.font = UIFont(name: "Avenir-Light", size: 17)
        style2.setTitleColor(normalColor, forState: .Normal)
        style2.setTitleColor(selectedColor, forState: .Selected)
        style2.setTitle(readerConfig.localizedPlayerMenuStyle, forState: .Normal)
        menuView.addSubview(style2);
        
        // add line dividers between style buttons
        let style1line = UIView(frame: CGRectMake(style1.frame.origin.x, style1.frame.origin.y, 1, style1.frame.height))
        style1line.backgroundColor = readerConfig.nightModeSeparatorColor
        menuView.addSubview(style1line)
        let style2line = UIView(frame: CGRectMake(style2.frame.origin.x, style2.frame.origin.y, 1, style2.frame.height))
        style2line.backgroundColor = readerConfig.nightModeSeparatorColor
        menuView.addSubview(style2line)
        
        // select the current style
        style0.selected = (FolioReader.sharedInstance.currentMediaOverlayStyle == .Default)
        style1.selected = (FolioReader.sharedInstance.currentMediaOverlayStyle == .Underline)
        style2.selected = (FolioReader.sharedInstance.currentMediaOverlayStyle == .TextColor)
        if style0.selected { style0Bgd.backgroundColor = selectedColor }
        
        // hook up button actions
        style0.tag = MediaOverlayStyle.Default.rawValue
        style1.tag = MediaOverlayStyle.Underline.rawValue
        style2.tag = MediaOverlayStyle.TextColor.rawValue
        style0.addTarget(self, action: #selector(FolioReaderPlayerMenu.changeStyle(_:)), forControlEvents: .TouchUpInside)
        style1.addTarget(self, action: #selector(FolioReaderPlayerMenu.changeStyle(_:)), forControlEvents: .TouchUpInside)
        style2.addTarget(self, action: #selector(FolioReaderPlayerMenu.changeStyle(_:)), forControlEvents: .TouchUpInside)
        
        // store ref to buttons
        styleOptionBtns.append(style0)
        styleOptionBtns.append(style1)
        styleOptionBtns.append(style2)
    }
    

    override func viewDidAppear(animated: Bool) {
        viewDidAppear = true
    }

    override func viewDidDisappear(animated: Bool) {
        viewDidAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Status Bar

    override func prefersStatusBarHidden() -> Bool {
        return readerConfig.shouldHideNavigationOnTap == true
    }

    // MARK: - SMSegmentView delegate

    func segmentView(segmentView: SMSegmentView, didSelectSegmentAtIndex index: Int) {

        if( viewDidAppear != true ){ return }

        let audioPlayer = FolioReader.sharedInstance.readerAudioPlayer

        if segmentView.tag == 2 {

            audioPlayer.setRate(index)

            FolioReader.sharedInstance.currentAudioRate = index
        }
    }

    func prevChapter(sender: UIButton!) {
        FolioReader.sharedInstance.readerAudioPlayer.playPrevChapter()
    }
    
    func nextChapter(sender: UIButton!) {
        FolioReader.sharedInstance.readerAudioPlayer.playNextChapter()
    }
    
    func togglePlay(sender: UIButton!) {
        sender.selected = sender.selected != true
        FolioReader.sharedInstance.readerAudioPlayer.togglePlay()
        closeView()
    }
    
    func changeStyle(sender: UIButton!) {
        FolioReader.sharedInstance.currentMediaOverlayStyle = MediaOverlayStyle(rawValue: sender.tag)!
        
        // select the proper style button
        for btn in styleOptionBtns {
            btn.selected = btn == sender
            
            if btn.tag == MediaOverlayStyle.Default.rawValue {
                btn.subviews.first?.backgroundColor = btn.selected ? readerConfig.tintColor : UIColor(white: 0.5, alpha: 0.7)
            }
        }
        
        // update the current page style
        if let currentPage = FolioReader.sharedInstance.readerCenter.currentPage {
            currentPage.webView.js("setMediaOverlayStyle(\"\(FolioReader.sharedInstance.currentMediaOverlayStyle.className())\")")
        }
    }

    func closeView() {
        dismissViewControllerAnimated(true, completion: nil)

        if readerConfig.shouldHideNavigationOnTap == false {
            FolioReader.sharedInstance.readerCenter.showBars()
        }
    }

    // MARK: - Gestures

    func tapGesture() {
        closeView()
    }


    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer && touch.view == view {
            return true
        }
        return false
    }
}
