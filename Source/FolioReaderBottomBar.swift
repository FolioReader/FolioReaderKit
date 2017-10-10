//
//  FolioReaderBottomBar.swift
//  FolioTest
//
//  Created by Ilya Filinovich on 12.09.17.
//  Copyright © 2017 Mobile Up. All rights reserved.
//

import UIKit

enum ButtonState {
    case play
    case pause
}

open class FolioReaderBottomBar: UIView {

    var playButton = UIButton()
    var playButtonState = ButtonState.play
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

        // Play button
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.addTarget(self, action: #selector(playButtonTouched(sender:)), for: .touchUpInside)
        setPlayButtonState(.play)
        addSubview(playButton)
        
        // Slider
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.tintColor = .green
        slider.addTarget(self, action: #selector(sliderChangedValue(sender:)), for: .touchUpInside)
        
        addSubview(slider)
        
        // Configure contraints
        var constraints = [NSLayoutConstraint]()
        let views = ["button": playButton, "slider" : slider] as [String : Any]
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[slider]-20-[button(40)]-10-|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[button]|", options: [], metrics: nil, views: views)
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|[slider]|", options: [], metrics: nil, views: views)
        
        self.addConstraints(constraints)
        
    }
    
    func playButtonTouched(sender: UIButton) {
        if let delegate = delegate {
            switch playButtonState {
            case .play:
                delegate.folioReaderBottomBarDidPushPlay?(self)
                setPlayButtonState(.pause)
            case .pause:
                delegate.folioReaderBottomBarDidPushStop?(self)
                setPlayButtonState(.play)
            }
        }
    }
    
    func setPlayButtonState(_ state: ButtonState) {
        playButtonState = state
        switch state {
        case .play:
            playButton.setImage(#imageLiteral(resourceName: "play-icon"), for: .normal)
        case .pause:
            playButton.setImage(#imageLiteral(resourceName: "pause-icon"), for: .normal)
        }
    }
    
    func sliderChangedValue(sender: UISlider) {
        delegate?.folioReaderBottomBar?(self, didSetSliderTo: sender.value)
    }

}

@objc public protocol FolioReaderBottomBarDelegate: class {
    @objc optional func folioReaderBottomBarDidPushPlay(_ bar: FolioReaderBottomBar)
    @objc optional func folioReaderBottomBarDidPushStop(_ bar: FolioReaderBottomBar)
    @objc optional func folioReaderBottomBar(_ bar: FolioReaderBottomBar, didSetSliderTo sliderValue: Float)
}
