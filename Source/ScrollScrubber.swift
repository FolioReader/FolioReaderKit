//
//  ScrollScrubber.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 7/14/16.
//  Copyright © 2016 FolioReader. All rights reserved.
//

import UIKit

enum ScrollDirection: Int {
    case None
    case Right
    case Left
    case Up
    case Down
    
    init() {
        self = .None
    }
}

class ScrollScrubber: NSObject, UIScrollViewDelegate {
    
    weak var delegate: FolioReaderCenter!
    var showSpeed = 0.6
    var hideSpeed = 0.6
    var hideDelay = 1.0
    
    var visible = false
    var usingSlider = false
    var slider: UISlider!
    var hideTimer: NSTimer!
    var scrollStart: CGFloat!
    var scrollDelta: CGFloat!
    var scrollDeltaTimer: NSTimer!
    
    init(frame:CGRect) {
        super.init()
        
        slider = UISlider()
        slider.layer.anchorPoint = CGPoint(x: 0, y: 0)
        slider.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        slider.frame = frame
        slider.alpha = 0
        
        updateColors()
        
        // less obtrusive knob and fixes jump: http://stackoverflow.com/a/22301039/484780
        let thumbImg = UIImage(readerImageNamed: "knob")
        let thumbImgColor = thumbImg!.imageTintColor(readerConfig.tintColor).imageWithRenderingMode(.AlwaysOriginal)
        slider.setThumbImage(thumbImgColor, forState: .Normal)
        slider.setThumbImage(thumbImgColor, forState: .Selected)
        slider.setThumbImage(thumbImgColor, forState: .Highlighted)
        
        slider.addTarget(self, action: #selector(ScrollScrubber.sliderChange(_:)), forControlEvents: .ValueChanged)
        slider.addTarget(self, action: #selector(ScrollScrubber.sliderTouchDown(_:)), forControlEvents: .TouchDown)
        slider.addTarget(self, action: #selector(ScrollScrubber.sliderTouchUp(_:)), forControlEvents: .TouchUpInside)
        slider.addTarget(self, action: #selector(ScrollScrubber.sliderTouchUp(_:)), forControlEvents: .TouchUpOutside)
    }
    
    func updateColors() {
        slider.minimumTrackTintColor = readerConfig.tintColor
        slider.maximumTrackTintColor = isNight(readerConfig.nightModeSeparatorColor, readerConfig.menuSeparatorColor)
    }
    
    // MARK: - slider events
    
    func sliderTouchDown(slider:UISlider) {
        usingSlider = true
        show()
    }
    
    func sliderTouchUp(slider:UISlider) {
        usingSlider = false
        hideAfterDelay()
    }
    
    func sliderChange(slider:UISlider) {
        let offset = isVerticalDirection(CGPointMake(0, height()*CGFloat(slider.value)),
                                         CGPointMake(height()*CGFloat(slider.value), 0))
        scrollView().setContentOffset(offset, animated: false)
    }
    
    // MARK: - show / hide
    
    func show() {
        
        cancelHide()
        
        visible = true
        
        if slider.alpha <= 0 {
            UIView.animateWithDuration(showSpeed, animations: {
                
                self.slider.alpha = 1
                
                }, completion: { (Bool) -> Void in
                    self.hideAfterDelay()
            })
        } else {
            slider.alpha = 1
            if usingSlider == false {
                hideAfterDelay()
            }
        }
    }
    
    
    func hide() {
        visible = false
        resetScrollDelta()
        UIView.animateWithDuration(hideSpeed, animations: {
            self.slider.alpha = 0
        })
    }
    
    func hideAfterDelay() {
        cancelHide()
        hideTimer = NSTimer.scheduledTimerWithTimeInterval(hideDelay, target: self, selector: #selector(ScrollScrubber.hide), userInfo: nil, repeats: false)
    }
    
    func cancelHide() {
        
        if hideTimer != nil {
            hideTimer.invalidate()
            hideTimer = nil
        }
        
        if visible == false {
            slider.layer.removeAllAnimations()
        }
        
        visible = true
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        if scrollDeltaTimer != nil {
            scrollDeltaTimer.invalidate()
            scrollDeltaTimer = nil
        }
        
        if scrollStart == nil {
            scrollStart = scrollView.contentOffset.forDirection()
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard readerConfig.scrollDirection == .vertical else { return }
        
        if visible && usingSlider == false {
            setSliderVal()
        }
        
        if( slider.alpha > 0 ){
            
            show()
            
        } else if delegate.currentPage != nil && scrollStart != nil {
            scrollDelta = scrollView.contentOffset.forDirection() - scrollStart
            
            if scrollDeltaTimer == nil && scrollDelta > (pageHeight * 0.2 ) || (scrollDelta * -1) > (pageHeight * 0.2) {
                show()
                resetScrollDelta()
            }
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        resetScrollDelta()
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        scrollDeltaTimer = NSTimer(timeInterval:0.5, target: self, selector: #selector(ScrollScrubber.resetScrollDelta), userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(scrollDeltaTimer, forMode: NSRunLoopCommonModes)
    }
    
    
    func resetScrollDelta(){
        if scrollDeltaTimer != nil {
            scrollDeltaTimer.invalidate()
            scrollDeltaTimer = nil
        }
        
        scrollStart = scrollView().contentOffset.forDirection()
        scrollDelta = 0
    }
    
    
    func setSliderVal(){
        slider.value = Float(scrollTop() / height())
    }
    
    // MARK: - utility methods
    
    private func scrollView() -> UIScrollView {
        return delegate.currentPage.webView.scrollView
    }
    
    private func height() -> CGFloat {
        return delegate.currentPage.webView.scrollView.contentSize.height - pageHeight + 44
    }
    
    private func scrollTop() -> CGFloat {
        return delegate.currentPage.webView.scrollView.contentOffset.forDirection()
    }
}
