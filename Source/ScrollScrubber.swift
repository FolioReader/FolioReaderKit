//
//  ScrollScrubber.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 7/14/16.
//  Copyright © 2016 FolioReader. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum ScrollDirection: Int {
    case none
    case right
    case left
    case up
    case down
    
    init() {
        self = .none
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
    var hideTimer: Timer!
    var scrollStart: CGFloat!
    var scrollDelta: CGFloat!
    var scrollDeltaTimer: Timer!

	var frame: CGRect! {
		didSet {
			self.slider.frame = frame
		}
	}

    init(frame:CGRect) {
        super.init()
        
        slider = UISlider()
        slider.layer.anchorPoint = CGPoint(x: 0, y: 0)
        slider.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        slider.alpha = 0

		self.frame = frame

		reloadColors()
        
        // less obtrusive knob and fixes jump: http://stackoverflow.com/a/22301039/484780
        let thumbImg = UIImage(readerImageNamed: "knob")
        let thumbImgColor = thumbImg!.imageTintColor(readerConfig.tintColor).withRenderingMode(.alwaysOriginal)
        slider.setThumbImage(thumbImgColor, for: UIControlState())
        slider.setThumbImage(thumbImgColor, for: .selected)
        slider.setThumbImage(thumbImgColor, for: .highlighted)
        
        slider.addTarget(self, action: #selector(ScrollScrubber.sliderChange(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(ScrollScrubber.sliderTouchDown(_:)), for: .touchDown)
        slider.addTarget(self, action: #selector(ScrollScrubber.sliderTouchUp(_:)), for: .touchUpInside)
        slider.addTarget(self, action: #selector(ScrollScrubber.sliderTouchUp(_:)), for: .touchUpOutside)
    }
    
    func reloadColors() {
        slider.minimumTrackTintColor = readerConfig.tintColor
        slider.maximumTrackTintColor = isNight(readerConfig.nightModeSeparatorColor, readerConfig.menuSeparatorColor)
    }
    
    // MARK: - slider events
    
    func sliderTouchDown(_ slider:UISlider) {
        usingSlider = true
        show()
    }
    
    func sliderTouchUp(_ slider:UISlider) {
        usingSlider = false
        hideAfterDelay()
    }
    
    func sliderChange(_ slider:UISlider) {
        let movePosition = height()*CGFloat(slider.value)
        let offset = isDirection(CGPoint(x: 0, y: movePosition), CGPoint(x: movePosition, y: 0))
        scrollView().setContentOffset(offset, animated: false)
    }
    
    // MARK: - show / hide
    
    func show() {
        
        cancelHide()
        
        visible = true
        
        if slider.alpha <= 0 {
            UIView.animate(withDuration: showSpeed, animations: {
                
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
        UIView.animate(withDuration: hideSpeed, animations: {
            self.slider.alpha = 0
        })
    }
    
    func hideAfterDelay() {
        cancelHide()
        hideTimer = Timer.scheduledTimer(timeInterval: hideDelay, target: self, selector: #selector(ScrollScrubber.hide), userInfo: nil, repeats: false)
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if scrollDeltaTimer != nil {
            scrollDeltaTimer.invalidate()
            scrollDeltaTimer = nil
        }
        
        if scrollStart == nil {
            scrollStart = scrollView.contentOffset.forDirection()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard readerConfig.scrollDirection == .vertical || readerConfig.scrollDirection == .defaultVertical || readerConfig.scrollDirection == .horizontalWithVerticalContent else {
            return
        }
        
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        resetScrollDelta()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollDeltaTimer = Timer(timeInterval:0.5, target: self, selector: #selector(ScrollScrubber.resetScrollDelta), userInfo: nil, repeats: false)
        RunLoop.current.add(scrollDeltaTimer, forMode: RunLoopMode.commonModes)
    }
    
    func resetScrollDelta() {
        if scrollDeltaTimer != nil {
            scrollDeltaTimer.invalidate()
            scrollDeltaTimer = nil
        }
        
        scrollStart = scrollView().contentOffset.forDirection()
        scrollDelta = 0
    }
    
    
    func setSliderVal() {
        slider.value = Float(scrollTop() / height())
    }
    
    // MARK: - utility methods
    
    fileprivate func scrollView() -> UIScrollView {
        return delegate.currentPage!.webView.scrollView
    }
    
    fileprivate func height() -> CGFloat {
        return delegate.currentPage!.webView.scrollView.contentSize.height - pageHeight + 44
    }
    
    fileprivate func scrollTop() -> CGFloat {
        return delegate.currentPage!.webView.scrollView.contentOffset.forDirection()
    }
}
