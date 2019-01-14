//
//  SMSegment.swift
//
//  Created by Si MA on 03/01/2015.
//  Copyright (c) 2015 Si Ma. All rights reserved.
//

import UIKit

protocol SMSegmentDelegate: class {
    func selectSegment(_ segment: SMSegment)
}

class SMSegment: UIView {
    
    weak var delegate: SMSegmentDelegate?
    
    fileprivate(set) var isSelected: Bool = false
    fileprivate var shouldResponse: Bool!
    var index: Int = 0
    var verticalMargin: CGFloat = 5.0 {
        didSet {
            self.resetContentFrame()
        }
    }
    
    var separatorWidth: CGFloat
    
    // Segment Colour
    var onSelectionColour: UIColor = UIColor.darkGray {
        didSet {
            if self.isSelected == true {
                self.backgroundColor = self.onSelectionColour
            }
        }
    }
    var offSelectionColour: UIColor = UIColor.white {
        didSet {
            if self.isSelected == false {
                self.backgroundColor = self.offSelectionColour
            }
        }
    }
    fileprivate var willOnSelectionColour: UIColor! {
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
                self.labelWidth = titleText.boundingRect(with: CGSize(width: self.frame.size.width, height: self.frame.size.height), options:NSStringDrawingOptions.usesLineFragmentOrigin , attributes: [NSAttributedString.Key.font: self.label.font], context: nil).size.width
            }
            else {
                self.labelWidth = 0.0
            }
            
            self.resetContentFrame()
        }
    }
    var onSelectionTextColour: UIColor = UIColor.white {
        didSet {
            if self.isSelected == true {
                self.label.textColor = self.onSelectionTextColour
            }
        }
    }
    var offSelectionTextColour: UIColor = UIColor.darkGray {
        didSet {
            if self.isSelected == false {
                self.label.textColor = self.offSelectionTextColour
            }
        }
    }
    var titleFont: UIFont = UIFont.systemFont(ofSize: 17.0) {
        didSet {
            self.label.font = self.titleFont
            
            if let titleText = self.label.text as NSString? {
                self.labelWidth = titleText.boundingRect(with: CGSize(width: self.frame.size.width + 1.0, height: self.frame.size.height), options:NSStringDrawingOptions.usesLineFragmentOrigin , attributes: [NSAttributedString.Key.font: self.label.font], context: nil).size.width
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
                self.imageView.contentMode = .center
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
                self.imageView.contentMode = .center
            }
        }
    }
    
    // UI Elements
    override var frame: CGRect {
        didSet {
            self.resetContentFrame()
        }
    }
    fileprivate var imageView: UIImageView = UIImageView()
    fileprivate var label: UILabel = UILabel()
    fileprivate var labelWidth: CGFloat = 0.0
    
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
        
        super.init(frame: CGRect.zero)
        self.setupUIElements()
    }
    
    func setupUIElements() {
        
        self.backgroundColor = self.offSelectionColour
        
        self.imageView.contentMode = UIView.ContentMode.scaleAspectFit
        self.addSubview(self.imageView)
        
        self.label.textAlignment = NSTextAlignment.center
        self.label.font = self.titleFont
        self.label.textColor = self.offSelectionTextColour
        self.addSubview(self.label)
    }
    
    // MARK: Selections
    func setSelected(_ selected: Bool) {
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
    fileprivate func resetContentFrame() {
        
        var distanceBetween: CGFloat = 0.0
        var imageViewFrame = CGRect(x: 0.0, y: self.verticalMargin, width: 0.0, height: self.frame.size.height - self.verticalMargin*2)
        
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
        
        self.label.frame = CGRect(x: imageViewFrame.origin.x + imageViewFrame.size.width + distanceBetween, y: self.verticalMargin, width: self.labelWidth, height: self.frame.size.height - self.verticalMargin * 2)
    }
    
    // MARK: Handle touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if self.isSelected == false {
            self.shouldResponse = true
            self.backgroundColor = self.willOnSelectionColour
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.delegate?.selectSegment(self)
    }
}
