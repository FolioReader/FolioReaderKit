//
//  FolioReaderPageIndicator.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 10/09/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderPageIndicator: UIView {
    var pagesLabel: UILabel!
    var minutesLabel: UILabel!
    var totalMinutes: Int!
    var totalPages: Int!
    var currentPage: Int = 1 {
        didSet { self.reloadViewWithPage(self.currentPage) }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let color = isNight(readerConfig.nightModeBackground, UIColor.whiteColor())
        backgroundColor = color
        layer.shadowColor = color.CGColor
        layer.shadowOffset = CGSize(width: 0, height: -6)
        layer.shadowOpacity = 1
        layer.shadowRadius = 4
        layer.shadowPath = UIBezierPath(rect: bounds).CGPath
        layer.rasterizationScale = UIScreen.mainScreen().scale
        layer.shouldRasterize = true
        
        pagesLabel = UILabel(frame: CGRectZero)
        pagesLabel.font = UIFont(name: "Avenir-Light", size: 10)!
        pagesLabel.textAlignment = NSTextAlignment.Right
        addSubview(pagesLabel)
        
        minutesLabel = UILabel(frame: CGRectZero)
        minutesLabel.font = UIFont(name: "Avenir-Light", size: 10)!
        minutesLabel.textAlignment = NSTextAlignment.Right
//        minutesLabel.alpha = 0
        addSubview(minutesLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    func reloadView(updateShadow updateShadow: Bool) {
        minutesLabel.sizeToFit()
        pagesLabel.sizeToFit()
        
        let fullW = pagesLabel.frame.width + minutesLabel.frame.width
        minutesLabel.frame.origin = CGPoint(x: frame.width/2-fullW/2, y: 2)
        pagesLabel.frame.origin = CGPoint(x: minutesLabel.frame.origin.x+minutesLabel.frame.width, y: 2)
        
        if updateShadow {
            layer.shadowPath = UIBezierPath(rect: bounds).CGPath
			reloadColors()
        }
    }

	func reloadColors() {
		let color = isNight(readerConfig.nightModeBackground, UIColor.whiteColor())
		backgroundColor = color

		// Animate the shadow color change
		let animation = CABasicAnimation(keyPath: "shadowColor")
		let currentColor = UIColor(CGColor: layer.shadowColor!)
		animation.fromValue = currentColor.CGColor
		animation.toValue = color.CGColor
		animation.fillMode = kCAFillModeForwards
		animation.removedOnCompletion = false
		animation.duration = 0.6
		animation.delegate = self
		animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		layer.addAnimation(animation, forKey: "shadowColor")

		minutesLabel.textColor = isNight(UIColor(white: 5, alpha: 0.3), UIColor(white: 0, alpha: 0.6))
		pagesLabel.textColor = isNight(UIColor(white: 5, alpha: 0.6), UIColor(white: 0, alpha: 0.9))
	}

    private func reloadViewWithPage(page: Int) {
        let pagesRemaining = FolioReader.needsRTLChange ? totalPages-(totalPages-page+1) : totalPages-page
        
        if pagesRemaining == 1 {
            pagesLabel.text = " "+readerConfig.localizedReaderOnePageLeft
        } else {
            pagesLabel.text = " \(pagesRemaining) "+readerConfig.localizedReaderManyPagesLeft
        }
        
        
        let minutesRemaining = Int(ceil(CGFloat((pagesRemaining * totalMinutes)/totalPages)))
        if minutesRemaining > 1 {
            minutesLabel.text = "\(minutesRemaining) "+readerConfig.localizedReaderManyMinutes+" ·"
        } else if minutesRemaining == 1 {
            minutesLabel.text = readerConfig.localizedReaderOneMinute+" ·"
        } else {
            minutesLabel.text = readerConfig.localizedReaderLessThanOneMinute+" ·"
        }
        
        reloadView(updateShadow: false)
    }
}

extension FolioReaderPageIndicator: CAAnimationDelegate {
    func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        // Set the shadow color to the final value of the animation is done
        if let keyPath = anim.valueForKeyPath("keyPath") as? String where keyPath == "shadowColor" {
            let color = isNight(readerConfig.nightModeBackground, UIColor.whiteColor())
            layer.shadowColor = color.CGColor
        }
    }
}
