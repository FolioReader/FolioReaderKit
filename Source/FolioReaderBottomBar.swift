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
    var separator = UIView()
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
            self.alpha = hidden ? 0 : 1
        }
    }
    
    func setup() {
        
        // Separator
        separator = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0.5))
        separator.backgroundColor = #colorLiteral(red: 0.8431372549, green: 0.8431372549, blue: 0.8431372549, alpha: 1)
        addSubview(separator)
        
        // Slider
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.tintColor = #colorLiteral(red: 0.2196078431, green: 0.6039215686, blue: 0.3254901961, alpha: 1)
        slider.addTarget(self, action: #selector(sliderChangedValue(sender:)), for: .touchUpInside)
        slider.setThumbImage(UIImage(readerImageNamed: "slider-thumb"), for: .normal)
        
        addSubview(slider)
        
        // Configure contraints
        var constraints = [NSLayoutConstraint]()
        let views = ["slider" : slider, "separator" : separator] as [String : Any]
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[slider]-20-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[separator]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[separator(0.5)]-[slider]-10-|", options: [], metrics: nil, views: views)
        
        self.addConstraints(constraints)
        
    }
    
    func sliderChangedValue(sender: UISlider) {
        delegate?.folioReaderBottomBar?(self, didSetSliderTo: sender.value)
    }

}

@objc public protocol FolioReaderBottomBarDelegate: class {
    @objc optional func folioReaderBottomBar(_ bar: FolioReaderBottomBar, didSetSliderTo sliderValue: Float)
}
