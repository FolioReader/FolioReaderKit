//
//  FolioReaderBottomBar.swift
//  FolioTest
//
//  Created by Ilya Filinovich on 12.09.17.
//  Copyright © 2017 Mobile Up. All rights reserved.
//

import UIKit

open class FolioReaderBottomBar: UIView {

    var slider = UISlider()
    override open var tintColor: UIColor! {
        didSet {
            slider.tintColor = tintColor
        }
    }
    
    var delegate: FolioReaderBottomBarDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setHidden(_ hidden: Bool, animated: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.alpha = hidden ? 0 : 0.8
        }
    }
    
    func setup() {
        
        // Slider
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.tintColor = .green
        slider.addTarget(self, action: #selector(sliderChangedValue(sender:)), for: .touchUpInside)
        
        addSubview(slider)
        
        // Configure contraints
        var constraints = [NSLayoutConstraint]()
        let views = ["slider" : slider] as [String : Any]
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[slider]-20-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[slider]|", options: [], metrics: nil, views: views)
        
        self.addConstraints(constraints)
        
    }
    
    func sliderChangedValue(sender: UISlider) {
        delegate?.folioReaderBottomBar?(self, didSetSliderTo: sender.value)
    }

}

@objc public protocol FolioReaderBottomBarDelegate: class {
    @objc optional func folioReaderBottomBar(_ bar: FolioReaderBottomBar, didSetSliderTo sliderValue: Float)
}
