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
        let play = UIImage(readerImageNamed: "play-btn")
        let pause = UIImage(readerImageNamed: "pause-btn")

        let playSelected = play!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)
        let pauseSelected = pause!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)

        // play / pause button
        let playPause = UIButton(frame: CGRect(x: 0, y: 2, width: view.frame.width, height: 55))
        playPause.setTitle("  "+readerConfig.localizedPlayMenu, forState: .Normal)
        playPause.setTitle("  "+readerConfig.localizedPauseMenu, forState: .Selected)
        playPause.setTitleColor(selectedColor, forState: .Normal)
        playPause.setTitleColor(selectedColor, forState: .Selected)
        playPause.setImage(playSelected, forState: .Normal)
        playPause.setImage(pauseSelected, forState: .Selected)
        playPause.titleLabel!.font = UIFont(name: "Avenir", size: 22)!
        playPause.addTarget(self, action: "togglePlay:", forControlEvents: .TouchUpInside)
        menuView.addSubview(playPause)

        if FolioReader.sharedInstance.readerAudioPlayer.isPlaying() {
            playPause.selected = true
        }

        // Separator
        let line = UIView(frame: CGRectMake(0, playPause.frame.height+playPause.frame.origin.y, view.frame.width, 1))
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
