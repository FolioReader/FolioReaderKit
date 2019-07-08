//
//  FolioReaderFontsMenu.swift
//  FolioReaderKit
//
//  Created by Kevin Jantzer on 1/6/16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderPlayerMenu: UIViewController, SMSegmentViewDelegate, UIGestureRecognizerDelegate {

    var menuView: UIView!
    var playPauseBtn: UIButton!
    var styleOptionBtns = [UIButton]()
    var viewDidAppear = false

    fileprivate var readerConfig: FolioReaderConfig
    fileprivate var folioReader: FolioReader

    init(folioReader: FolioReader, readerConfig: FolioReaderConfig) {
        self.readerConfig = readerConfig
        self.folioReader = folioReader

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clear

        // Tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FolioReaderPlayerMenu.tapGesture))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)

        // Menu view
        menuView = UIView(frame: CGRect(x: 0, y: view.frame.height-165, width: view.frame.width, height: view.frame.height))
        menuView.backgroundColor = self.folioReader.isNight(self.readerConfig.nightModeNavBackground, self.readerConfig.daysModeNavBackground)
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
        let selectedColor = self.readerConfig.tintColor
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
        let playSelected = play?.imageTintColor(selectedColor)?.withRenderingMode(.alwaysOriginal)
        let pauseSelected = pause?.imageTintColor(selectedColor)?.withRenderingMode(.alwaysOriginal)

        let prevNormal = prev?.imageTintColor(normalColor)?.withRenderingMode(.alwaysOriginal)
        let nextNormal = next?.imageTintColor(normalColor)?.withRenderingMode(.alwaysOriginal)
        let prevSelected = prev?.imageTintColor(selectedColor)?.withRenderingMode(.alwaysOriginal)
        let nextSelected = next?.imageTintColor(selectedColor)?.withRenderingMode(.alwaysOriginal)

        // prev button
        let prevBtn = UIButton(frame: CGRect(x: gutterX + padX, y: 0, width: size, height: size))
        prevBtn.setImage(prevNormal, for: UIControl.State())
        prevBtn.setImage(prevSelected, for: .selected)
        prevBtn.addTarget(self, action: #selector(FolioReaderPlayerMenu.prevChapter(_:)), for: .touchUpInside)
        menuView.addSubview(prevBtn)

        // play / pause button
        let playPauseBtn = UIButton(frame: CGRect(x: Int(prevBtn.frame.origin.x) + padX + size, y: 0, width: size, height: size))
        playPauseBtn.setTitleColor(selectedColor, for: UIControl.State())
        playPauseBtn.setTitleColor(selectedColor, for: .selected)
        playPauseBtn.setImage(playSelected, for: UIControl.State())
        playPauseBtn.setImage(pauseSelected, for: .selected)
        playPauseBtn.titleLabel!.font = UIFont(name: "Avenir", size: 22)!
        playPauseBtn.addTarget(self, action: #selector(FolioReaderPlayerMenu.togglePlay(_:)), for: .touchUpInside)
        menuView.addSubview(playPauseBtn)

        if let audioPlayer = self.folioReader.readerAudioPlayer , audioPlayer.isPlaying() {
            playPauseBtn.isSelected = true
        }

        // next button
        let nextBtn = UIButton(frame: CGRect(x: Int(playPauseBtn.frame.origin.x) + padX + size, y: 0, width: size, height: size))
        nextBtn.setImage(nextNormal, for: UIControl.State())
        nextBtn.setImage(nextSelected, for: .selected)
        nextBtn.addTarget(self, action: #selector(FolioReaderPlayerMenu.nextChapter(_:)), for: .touchUpInside)
        menuView.addSubview(nextBtn)


        // Separator
        let line = UIView(frame: CGRect(x: 0, y: playPauseBtn.frame.height+playPauseBtn.frame.origin.y, width: view.frame.width, height: 1))
        line.backgroundColor = self.readerConfig.nightModeSeparatorColor
        menuView.addSubview(line)

        // audio playback rate adjust
        let playbackRate = SMSegmentView(frame: CGRect(x: 15, y: line.frame.height+line.frame.origin.y, width: view.frame.width-30, height: 55),
                                         separatorColour: UIColor.clear,
                                         separatorWidth: 0,
                                         segmentProperties:  [
                                            keySegmentOnSelectionColour: UIColor.clear,
                                            keySegmentOffSelectionColour: UIColor.clear,
                                            keySegmentOnSelectionTextColour: selectedColor,
                                            keySegmentOffSelectionTextColour: normalColor,
                                            keyContentVerticalMargin: 17 as AnyObject
            ])
        playbackRate.delegate = self
        playbackRate.tag = 2
        playbackRate.addSegmentWithTitle("½x", onSelectionImage: nil, offSelectionImage: nil)
        playbackRate.addSegmentWithTitle("1x", onSelectionImage: nil, offSelectionImage: nil)
        playbackRate.addSegmentWithTitle("1½x", onSelectionImage: nil, offSelectionImage: nil)
        playbackRate.addSegmentWithTitle("2x", onSelectionImage: nil, offSelectionImage: nil)
        playbackRate.segmentTitleFont = UIFont(name: "Avenir-Light", size: 17)!
        playbackRate.selectSegmentAtIndex(Int(self.folioReader.currentAudioRate))
        menuView.addSubview(playbackRate)


        // Separator
        let line2 = UIView(frame: CGRect(x: 0, y: playbackRate.frame.height+playbackRate.frame.origin.y, width: view.frame.width, height: 1))
        line2.backgroundColor = self.readerConfig.nightModeSeparatorColor
        menuView.addSubview(line2)


        // Media overlay highlight styles
        let style0 = UIButton(frame: CGRect(x: 0, y: line2.frame.height+line2.frame.origin.y, width: view.frame.width/3, height: 55))
        style0.titleLabel!.textAlignment = .center
        style0.titleLabel!.font = UIFont(name: "Avenir-Light", size: 17)
        style0.setTitleColor(self.folioReader.isNight(self.readerConfig.nightModeMenuBackground, UIColor.white), for: UIControl.State())
        style0.setTitleColor(self.folioReader.isNight(self.readerConfig.nightModeMenuBackground, UIColor.white), for: .selected)
        style0.setTitle(self.readerConfig.localizedPlayerMenuStyle, for: UIControl.State())
        menuView.addSubview(style0);
        style0.titleLabel?.sizeToFit()
        let style0Bgd = UIView(frame: style0.titleLabel!.frame)
        style0Bgd.center = CGPoint(x: style0.frame.size.width  / 2, y: style0.frame.size.height / 2);
        style0Bgd.frame.size.width += 8
        style0Bgd.frame.origin.x -= 4
        style0Bgd.backgroundColor = normalColor;
        style0Bgd.layer.cornerRadius = 3.0;
        style0Bgd.isUserInteractionEnabled = false
        style0.insertSubview(style0Bgd, belowSubview: style0.titleLabel!)

        let style1 = UIButton(frame: CGRect(x: view.frame.width/3, y: line2.frame.height+line2.frame.origin.y, width: view.frame.width/3, height: 55))
        style1.titleLabel!.textAlignment = .center
        style1.titleLabel!.font = UIFont(name: "Avenir-Light", size: 17)
        style1.setTitleColor(normalColor, for: UIControl.State())
        style1.setAttributedTitle(NSAttributedString(string: "Style", attributes: [
            NSAttributedString.Key.foregroundColor: normalColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.patternDot.rawValue|NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.underlineColor: normalColor
            ]), for: UIControl.State())
        style1.setAttributedTitle(NSAttributedString(string: self.readerConfig.localizedPlayerMenuStyle, attributes: [
            NSAttributedString.Key.foregroundColor: self.folioReader.isNight(UIColor.white, UIColor.black),
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.patternDot.rawValue|NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.underlineColor: selectedColor
            ]), for: .selected)
        menuView.addSubview(style1);

        let style2 = UIButton(frame: CGRect(x: view.frame.width/1.5, y: line2.frame.height+line2.frame.origin.y, width: view.frame.width/3, height: 55))
        style2.titleLabel!.textAlignment = .center
        style2.titleLabel!.font = UIFont(name: "Avenir-Light", size: 17)
        style2.setTitleColor(normalColor, for: UIControl.State())
        style2.setTitleColor(selectedColor, for: .selected)
        style2.setTitle(self.readerConfig.localizedPlayerMenuStyle, for: UIControl.State())
        menuView.addSubview(style2);

        // add line dividers between style buttons
        let style1line = UIView(frame: CGRect(x: style1.frame.origin.x, y: style1.frame.origin.y, width: 1, height: style1.frame.height))
        style1line.backgroundColor = self.readerConfig.nightModeSeparatorColor
        menuView.addSubview(style1line)
        let style2line = UIView(frame: CGRect(x: style2.frame.origin.x, y: style2.frame.origin.y, width: 1, height: style2.frame.height))
        style2line.backgroundColor = self.readerConfig.nightModeSeparatorColor
        menuView.addSubview(style2line)

        // select the current style
        style0.isSelected = (self.folioReader.currentMediaOverlayStyle == .default)
        style1.isSelected = (self.folioReader.currentMediaOverlayStyle == .underline)
        style2.isSelected = (self.folioReader.currentMediaOverlayStyle == .textColor)
        if style0.isSelected { style0Bgd.backgroundColor = selectedColor }

        // hook up button actions
        style0.tag = MediaOverlayStyle.default.rawValue
        style1.tag = MediaOverlayStyle.underline.rawValue
        style2.tag = MediaOverlayStyle.textColor.rawValue
        style0.addTarget(self, action: #selector(FolioReaderPlayerMenu.changeStyle(_:)), for: .touchUpInside)
        style1.addTarget(self, action: #selector(FolioReaderPlayerMenu.changeStyle(_:)), for: .touchUpInside)
        style2.addTarget(self, action: #selector(FolioReaderPlayerMenu.changeStyle(_:)), for: .touchUpInside)

        // store ref to buttons
        styleOptionBtns.append(style0)
        styleOptionBtns.append(style1)
        styleOptionBtns.append(style2)
    }


    override func viewDidAppear(_ animated: Bool) {
        viewDidAppear = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        viewDidAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Status Bar

    override var prefersStatusBarHidden : Bool {
        return (self.readerConfig.shouldHideNavigationOnTap == true)
    }

    // MARK: - SMSegmentView delegate

    func segmentView(_ segmentView: SMSegmentView, didSelectSegmentAtIndex index: Int) {
        guard viewDidAppear else { return }

        if let audioPlayer = self.folioReader.readerAudioPlayer, (segmentView.tag == 2) {
            audioPlayer.setRate(index)
            self.folioReader.currentAudioRate = index
        }
    }

    @objc func prevChapter(_ sender: UIButton!) {
        self.folioReader.readerAudioPlayer?.playPrevChapter()
    }

    @objc func nextChapter(_ sender: UIButton!) {
        self.folioReader.readerAudioPlayer?.playNextChapter()
    }

    @objc func togglePlay(_ sender: UIButton!) {
        sender.isSelected = sender.isSelected != true
        self.folioReader.readerAudioPlayer?.togglePlay()
        closeView()
    }

    @objc func changeStyle(_ sender: UIButton!) {
        self.folioReader.currentMediaOverlayStyle = MediaOverlayStyle(rawValue: sender.tag)!

        // select the proper style button
        for btn in styleOptionBtns {
            btn.isSelected = btn == sender

            if btn.tag == MediaOverlayStyle.default.rawValue {
                btn.subviews.first?.backgroundColor = (btn.isSelected ? self.readerConfig.tintColor : UIColor(white: 0.5, alpha: 0.7))
            }
        }

        // update the current page style
        if let currentPage = self.folioReader.readerCenter?.currentPage {
            currentPage.webView?.js("setMediaOverlayStyle(\"\(self.folioReader.currentMediaOverlayStyle.className())\")")
        }
    }

    func closeView() {
        self.dismiss()

        if (self.readerConfig.shouldHideNavigationOnTap == false) {
            self.folioReader.readerCenter?.showBars()
        }
    }
    
    // MARK: - Gestures
    
    @objc func tapGesture() {
        closeView()
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer is UITapGestureRecognizer && touch.view == view {
            return true
        }
        return false
    }
}
