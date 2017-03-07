//
//  QuoteImage.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 8/31/16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit

/**
 Defines a custom Quote image, can be a square `UIImage`, solid `UIColor` or `CAGradientLayer`.
 */
public struct QuoteImage {
    public var image: UIImage!
    public var alpha: CGFloat!
    public var textColor: UIColor!
    public var backgroundColor: UIColor!
    
    /**
     Quote image from `UIImage`
     
     - parameter image:           An `UIImage` to be used as background.
     - parameter alpha:           The image opacity. Defaults to 1.
     - parameter textColor:       The color of quote text and custom logo. Defaults to white.
     - parameter backgroundColor: The filter background color, if the image has a opacity this will appear. Defaults to white.
     
     - returns: A newly initialized `QuoteImage` object.
     */
    public init(withImage image: UIImage, alpha: CGFloat = 1, textColor: UIColor = UIColor.white, backgroundColor: UIColor = UIColor.white) {
        self.image = image
        self.alpha = alpha
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
    
    /**
     Quote image from `CAGradientLayer`
     
     - parameter gradient:        A custom `CAGradientLayer` to make a gradient background.
     - parameter alpha:           The image opacity. Defaults to 1.
     - parameter textColor:       The color of quote text and custom logo. Defaults to white.
     - parameter backgroundColor: The filter background color, if the image has a opacity this will appear. Defaults to white.
     
     - returns: A newly initialized `QuoteImage` object.
     */
    public init(withGradient gradient: CAGradientLayer, alpha: CGFloat = 1, textColor: UIColor = UIColor.white, backgroundColor: UIColor = UIColor.white) {
        let screenBounds = UIScreen.main.bounds
        gradient.frame = CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.width)
        self.image = UIImage.imageWithLayer(gradient)
        self.alpha = alpha
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
    
    /**
     Quote image from `UIColor`
     
     - parameter color:           A custom `UIColor`
     - parameter alpha:           The image opacity. Defaults to 1.
     - parameter textColor:       The color of quote text and custom logo. Defaults to white.
     - parameter backgroundColor: The filter background color, if the image has a opacity this will appear. Defaults to white.
     
     - returns: A newly initialized `QuoteImage` object.
     */
    public init(withColor color: UIColor, alpha: CGFloat = 1, textColor: UIColor = UIColor.white, backgroundColor: UIColor = UIColor.white) {
        self.image = UIImage.imageWithColor(color)
        self.alpha = alpha
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
}
