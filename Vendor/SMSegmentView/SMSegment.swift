//
//  SMSegment.swift
//
//  Created by Si MA on 03/01/2015.
//  Copyright (c) 2015 Si Ma. All rights reserved.
//

import UIKit

protocol SMSegmentDelegate: class {
    func selectSegment(segment: SMSegment)
}

class SMSegment: UIView {
    
    weak var delegate: SMSegmentDelegate?
    
    private(set) var isSelected: Bool = false
    private var shouldResponse: Bool!
    var index: Int = 0
    var verticalMargin: CGFloat = 5.0 {
        didSet {
            self.resetContentFrame()
        }
    }
    
    var separatorWidth: CGFloat
    
    // Segment Colour
    var onSelectionColour: UIColor = UIColor.darkGrayColor() {
        didSet {
            if self.isSelected == true {
                self.backgroundColor = self.onSelectionColour
            }
        }
    }
    var offSelectionColour: UIColor = UIColor.whiteColor() {
        didSet {
            if self.isSelected == false {
                self.backgroundColor = self.offSelectionColour
            }
        }
    }
    private var willOnSelectionColour: UIColor! {
        get {
            var hue: CGFloat = 0.0
            var saturation: CGFloat = 0.0
            var brightness: CGFloat = 0.0
            var alpha: CGFloat = 0.0
            self.onSelectionColour.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            return UIColor(hue: hue, saturation: saturation*0.5, brightness: min(brightness*1.5, 1.0), alpha: alpha)
        }
    }
    
    // Segment Title Text & Colour & Font
    var title: String? {
        didSet {
            self.label.text = self.title
            
            if let titleText = self.label.text as NSString? {
                self.labelWidth = titleText.boundingRectWithSize(CGSize(width: self.frame.size.width, height: self.frame.size.height), options:NSStringDrawingOptions.UsesLineFragmentOrigin , attributes: [NSFontAttributeName: self.label.font], context: nil).size.width
            }
            else {
                self.labelWidth = 0.0
            }
            
            self.resetContentFrame()
        }
    }
    var onSelectionTextColour: UIColor = UIColor.whiteColor() {
        didSet {
            if self.isSelected == true {
                self.label.textColor = self.onSelectionTextColour
            }
        }
    }
    var offSelectionTextColour: UIColor = UIColor.darkGrayColor() {
        didSet {
            if self.isSelected == false {
                self.label.textColor = self.offSelectionTextColour
            }
        }
    }
    var titleFont: UIFont = UIFont.systemFontOfSize(17.0) {
        didSet {
            self.label.font = self.titleFont
            
            if let titleText = self.label.text as NSString? {
                self.labelWidth = titleText.boundingRectWithSize(CGSize(width: self.frame.size.width + 1.0, height: self.frame.size.height), options:NSStringDrawingOptions.UsesLineFragmentOrigin , attributes: [NSFontAttributeName: self.label.font], context: nil).size.width
            }
            else {
                self.labelWidth = 0.0
            }
            
            self.resetContentFrame()
        }
    }
    
    // Segment Image
    var onSelectionImage: UIImage? {
        didSet {
            if self.onSelectionImage != nil {
                self.resetContentFrame()
            }
            if self.isSelected == true {
                self.imageView.image = self.onSelectionImage
            }
        }
    }
    var offSelectionImage: UIImage? {
        didSet {
            if self.offSelectionImage != nil {
                self.resetContentFrame()
            }
            if self.isSelected == false {
                self.imageView.image = self.offSelectionImage
            }
        }
    }
    
    // UI Elements
    override var frame: CGRect {
        didSet {
            self.resetContentFrame()
        }
    }
    private var imageView: UIImageView = UIImageView()
    private var label: UILabel = UILabel()
    private var labelWidth: CGFloat = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(separatorWidth: CGFloat, verticalMargin: CGFloat, onSelectionColour: UIColor, offSelectionColour: UIColor, onSelectionTextColour: UIColor, offSelectionTextColour: UIColor, titleFont: UIFont) {
        
        self.separatorWidth = separatorWidth
        self.verticalMargin = verticalMargin
        self.onSelectionColour = onSelectionColour
        self.offSelectionColour = offSelectionColour
        self.onSelectionTextColour = onSelectionTextColour
        self.offSelectionTextColour = offSelectionTextColour
        self.titleFont = titleFont
        
        super.init(frame: CGRectZero)
        self.setupUIElements()
    }
    
    func setupUIElements() {
        
        self.backgroundColor = self.offSelectionColour
        
        self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(self.imageView)
        
        self.label.textAlignment = NSTextAlignment.Center
        self.label.font = self.titleFont
        self.label.textColor = self.offSelectionTextColour
        self.addSubview(self.label)
    }
    
    // MARK: Selections
    func setSelected(selected: Bool) {
        if selected == true {
            self.isSelected = true
            self.backgroundColor = self.onSelectionColour
            self.label.textColor = self.onSelectionTextColour
            self.imageView.image = self.onSelectionImage
        }
        else {
            self.isSelected = false
            self.backgroundColor = self.offSelectionColour
            self.label.textColor = self.offSelectionTextColour
            self.imageView.image = self.offSelectionImage
        }
    }
    
    // MARK: Update Frame
    private func resetContentFrame() {
        
        var distanceBetween: CGFloat = 0.0
        var imageViewFrame = CGRectMake(0.0, self.verticalMargin, 0.0, self.frame.size.height - self.verticalMargin*2)
        
        if self.onSelectionImage != nil || self.offSelectionImage != nil {
            // Set imageView as a square
            imageViewFrame.size.width = self.frame.size.height - self.verticalMargin*2
            distanceBetween = 5.0
        }
        
        // If there's no text, align imageView centred
        // Else align text centred
        if self.labelWidth == 0.0 {
            imageViewFrame.origin.x = max((self.frame.size.width - imageViewFrame.size.width) / 2.0, 0.0)
        }
        else {
            imageViewFrame.origin.x = max((self.frame.size.width - imageViewFrame.size.width - self.labelWidth) / 2.0 - distanceBetween, 0.0)
        }
        
        self.imageView.frame = imageViewFrame
        
        self.label.frame = CGRectMake(imageViewFrame.origin.x + imageViewFrame.size.width + distanceBetween, self.verticalMargin, self.labelWidth, self.frame.size.height - self.verticalMargin * 2)
    }
    
    // MARK: Handle touch
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        if self.isSelected == false {
            self.shouldResponse = true
            self.backgroundColor = self.willOnSelectionColour
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        self.delegate?.selectSegment(self)
    }
}