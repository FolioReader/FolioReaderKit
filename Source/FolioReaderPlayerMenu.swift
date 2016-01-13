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
    var viewDidAppear = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clearColor()

        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapGesture")
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)

        // Menu view
        menuView = UIView(frame: CGRectMake(0, view.frame.height-110, view.frame.width, view.frame.height))
        menuView.backgroundColor = FolioReader.sharedInstance.nightMode ? readerConfig.nightModeMenuBackground : UIColor.whiteColor()
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
        let selectedColor = readerConfig.toolBarBackgroundColor
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
        let prevSelected = prev!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)
        let nextSelected = next!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)
        
        // prev button
        let prevBtn = UIButton(frame: CGRect(x: gutterX + padX, y: 0, width: size, height: size))
        prevBtn.setImage(prev, forState: .Normal)
        prevBtn.setImage(prevSelected, forState: .Selected)
        prevBtn.addTarget(self, action: "prevChapter:", forControlEvents: .TouchUpInside)
        menuView.addSubview(prevBtn)
        
        
        // play / pause button
        let playPauseBtn = UIButton(frame: CGRect(x: Int(prevBtn.frame.origin.x) + padX + size, y: 0, width: size, height: size))
        playPauseBtn.setTitleColor(selectedColor, forState: .Normal)
        playPauseBtn.setTitleColor(selectedColor, forState: .Selected)
        playPauseBtn.setImage(playSelected, forState: .Normal)
        playPauseBtn.setImage(pauseSelected, forState: .Selected)
        playPauseBtn.titleLabel!.font = UIFont(name: "Avenir", size: 22)!
        playPauseBtn.addTarget(self, action: "togglePlay:", forControlEvents: .TouchUpInside)
        menuView.addSubview(playPauseBtn)
        
        if FolioReader.sharedInstance.readerAudioPlayer.isPlaying() {
            playPauseBtn.selected = true
        }
        
        // next button
        let nextBtn = UIButton(frame: CGRect(x: Int(playPauseBtn.frame.origin.x) + padX + size, y: 0, width: size, height: size))
        nextBtn.setImage(next, forState: .Normal)
        nextBtn.setImage(nextSelected, forState: .Selected)
        nextBtn.addTarget(self, action: "nextChapter:", forControlEvents: .TouchUpInside)
        menuView.addSubview(nextBtn)
        
        // temp
//        playPause.backgroundColor =  UIColor.grayColor()
//        prevBtn.backgroundColor =  UIColor.grayColor()
//        nextBtn.backgroundColor = UIColor.grayColor()
        

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
