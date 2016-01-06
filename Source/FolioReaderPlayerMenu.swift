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

        let playNormal = play!.imageTintColor(normalColor).imageWithRenderingMode(.AlwaysOriginal)
        let pauseNormal = pause!.imageTintColor(normalColor).imageWithRenderingMode(.AlwaysOriginal)

        let playSelected = play!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)
        let pauseSelected = pause!.imageTintColor(selectedColor).imageWithRenderingMode(.AlwaysOriginal)

        // play / pause
        let playpause = SMSegmentView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 55),
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
        playpause.delegate = self
        playpause.tag = 1
//        playpause.selectSegmentAtIndex(Int(FolioReader.sharedInstance.nightMode))
        playpause.addSegmentWithTitle(readerConfig.localizedPlayMenu, onSelectionImage: playSelected, offSelectionImage: playNormal)
        playpause.addSegmentWithTitle(readerConfig.localizedPauseMenu, onSelectionImage: pauseSelected, offSelectionImage: pauseNormal)
        playpause.selectSegmentAtIndex( FolioReader.sharedInstance.readerAudioPlayer.isPlaying() ? 0 : 1 )
        menuView.addSubview(playpause)


        // Separator
        let line = UIView(frame: CGRectMake(0, playpause.frame.height+playpause.frame.origin.y, view.frame.width, 1))
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
        playbackRate.addSegmentWithTitle("0.5x", onSelectionImage: nil, offSelectionImage: nil)
        playbackRate.addSegmentWithTitle("1.0x", onSelectionImage: nil, offSelectionImage: nil)
        playbackRate.addSegmentWithTitle("1.25x", onSelectionImage: nil, offSelectionImage: nil)
        playbackRate.addSegmentWithTitle("1.5x", onSelectionImage: nil, offSelectionImage: nil)
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

        if segmentView.tag == 1 {
            switch index {
            case 0:
                audioPlayer.playAudio()
                break
            case 1:
                audioPlayer.pause()
                break
            default:
                break
            }

            closeView()
        }

        if segmentView.tag == 2 {

            audioPlayer.setRate(index)

            FolioReader.sharedInstance.currentAudioRate = index
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
