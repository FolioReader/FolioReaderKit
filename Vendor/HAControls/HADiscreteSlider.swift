//
//  HADiscreteSlider.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 12/02/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

enum ComponentStyle: Int {
    case ios
    case rectangular
    case rounded
    case invisible
    case image
}

let iOSThumbShadowRadius: CGFloat = 4.0
let iosThumbShadowOffset = CGSize(width: 0, height: 3)

class HADiscreteSlider : UIControl {

    func ticksDistanceChanged(_ ticksDistance: CGFloat, sender: AnyObject) { }
    func valueChanged(_ value: CGFloat) { }
    
    // MARK: properties
    
    var tickStyle: ComponentStyle =  ComponentStyle.rectangular {
        didSet { self.layoutTrack() }
    }
    
    var tickSize: CGSize = CGSize(width: 1.0, height: 4.0) {
        willSet (value) {
            self.tickSize.width = max(0, value.width)
            self.tickSize.height = max(0, value.height)
            self.layoutTrack()
        }
    }
    
    var tickCount: Int = 11 {
        willSet (value) {
            self.tickCount = max(2, value)
            self.layoutTrack()
        }
    }
    
    var ticksDistance: CGFloat {
        get {
            assert(self.tickCount > 1, "2 ticks minimum \(self.tickCount)")
            let segments = CGFloat(max(1, self.tickCount-1))
            return (self.trackRectangle!.size.width/segments)
        }
    }
    
    var tickImage: String? {
        didSet { self.layoutTrack() }
    }
    
    var trackStyle: ComponentStyle = ComponentStyle.ios {
        didSet { self.layoutTrack() }
    }
    
    var trackThickness: CGFloat = 2.0 {
        willSet (value) {
            self.trackThickness = max(0, value)
            self.layoutTrack()
        }
    }
    
    var trackImage: String? {
        didSet { self.layoutTrack() }
    }
    
    var thumbStyle: ComponentStyle = ComponentStyle.ios {
        didSet { self.layoutTrack() }
    }
    
    var thumbSize: CGSize = CGSize(width: 10.0, height: 10.0) {
        willSet (value) {
            self.thumbSize.width = max(1, value.width)
            self.thumbSize.height = max(1, value.height)
            self.layoutTrack()
        }
    }
    
    var thumbShadowRadius: CGFloat = 0.0 {
        didSet { self.layoutTrack() }
    }
    
    var thumbImage: String? {
        willSet (value) {
            self.thumbImage = value
            // Associate image to layer
            if let imageName = value {
                let image: UIImage = UIImage(named: imageName)!
                self.thumbLayer!.contents = image.cgImage
            }
            self.layoutTrack()
        }
    }
    
    // AKA: UISlider value (as CGFloat for compatibility with UISlider API, but expected to contain integers)
    var minimumValue: CGFloat {
        get { return CGFloat(self._intMinimumValue!) } // calculated property, with a float-to-int adapter
        set (value) {
            _intMinimumValue = Int(value);
            self.layoutTrack()
        }
    }
    
    var value: CGFloat {
        get { return CGFloat(self._intValue!) }
        set (value) {
            let rootValue = ((value - self.minimumValue) / self.incrementValue)
            _intValue = Int(self.minimumValue+(rootValue * self.incrementValue))
            self.layoutTrack()
        }
    }
    
    var incrementValue: CGFloat = 1 {
        willSet (value) {
            self.incrementValue = value
            if 0 == incrementValue {
                self.incrementValue = 1 // nonZeroIncrement
            }
            self.layoutTrack()
        }
    }
    
    var thumbColor: UIColor?
    var thumbShadowOffset: CGSize?
    var _intValue: Int?
	var _intMinimumValue: Int?
	var ticksAbscisses = [CGPoint]()
	var thumbAbscisse: CGFloat?
	var thumbLayer: CALayer?
	var colorTrackLayer: CALayer?
	var trackRectangle: CGRect!
	
	// When bounds change, recalculate layout
//    func setBounds(bounds: CGRect) {
//		super.bounds = bounds
//		self.layoutTrack()
//		self.setNeedsDisplay()
//	}
	
	override init(frame: CGRect) {
        super.init(frame: frame)
        self.initProperties()
	}

	required init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func draw(_ rect: CGRect) {
		self.drawTrack()
		self.drawThumb()
	}
	
	func sendActionsForControlEvents() {
        self.sendActions(for: UIControl.Event.valueChanged)
	}
	
	// MARK: HADiscreteSlider
    
	func initProperties() {
		self.thumbColor = UIColor.lightGray
		self.thumbShadowOffset = CGSize.zero
		_intMinimumValue = -5
		_intValue = 0
		self.thumbAbscisse = 0.0
		self.trackRectangle = CGRect.zero
		// In case we need a colored track, initialize it now
		// There may be a more elegant way to do this than with a CALayer,
		// but then again CALayer brings free animation and will animate along the thumb
		self.colorTrackLayer = CALayer()
		self.colorTrackLayer!.backgroundColor = UIColor(hue: 211.0/360.0, saturation: 1, brightness: 1, alpha: 1).cgColor
		self.colorTrackLayer!.cornerRadius = 2.0
		self.layer.addSublayer(self.colorTrackLayer!)
		// The thumb is its own CALayer, which brings in free animation
		self.thumbLayer = CALayer()
		self.layer.addSublayer(self.thumbLayer!)
		self.isMultipleTouchEnabled = false
		self.layoutTrack()
	}
	
	func drawTrack() {
		let ctx = UIGraphicsGetCurrentContext()
		// Track
		switch self.trackStyle {
        case .rectangular:
            ctx!.addRect(self.trackRectangle)
        break
        case .image:
        
            // Draw image if exists
            if let imageName = self.trackImage {
                let image = UIImage(named:imageName)!
                let centered = CGRect(x: (self.frame.size.width/2)-(image.size.width/2), y: (self.frame.size.height/2)-(image.size.height/2), width: image.size.width, height: image.size.height)
                    ctx!.draw(image.cgImage!, in: centered)
            }
            break
        
        case .invisible, .rounded, .ios:
            let path: UIBezierPath = UIBezierPath(roundedRect: self.trackRectangle, cornerRadius: self.trackRectangle.size.height/2)
            ctx!.addPath(path.cgPath)
            break
		}
        
		// Ticks
		if .ios != self.tickStyle {
            for originValue in self.ticksAbscisses {
                let originPoint = originValue
                let rectangle = CGRect(x: originPoint.x-(self.tickSize.width/2), y: originPoint.y-(self.tickSize.height/2), width: self.tickSize.width, height: self.tickSize.height)
                switch self.tickStyle {
                case .rounded:
                    let path = UIBezierPath(roundedRect: rectangle, cornerRadius: rectangle.size.height/2)
                    ctx!.addPath(path.cgPath)
                    break
                case .rectangular:
                    ctx!.addRect(rectangle)
                    break
                case .image:
                    // Draw image if exists
                    
                    if let imageName = self.tickImage {
                        let image = UIImage(named: imageName)!
                        let centered = CGRect(x: rectangle.origin.x+(rectangle.size.width/2)-(image.size.width/2), y: rectangle.origin.y+(rectangle.size.height/2)-(image.size.height/2), width: image.size.width, height: image.size.height)
                            ctx!.draw(image.cgImage!, in: centered)
                    }
                    break
                
                case .invisible: break
                case .ios: break
                }
            }
		}
        
		// iOS UISlider aka .IOS does not have ticks
		ctx!.setFillColor(self.tintColor.cgColor)
		ctx!.fillPath()
		// For colored track, we overlay a CALayer, which will animate along with the cursor
		if .ios == self.trackStyle {
			var frame = self.trackRectangle
			frame?.size.width = self.thumbAbscisse!-self.trackRectangle.minX
			self.colorTrackLayer!.frame = frame!
		} else {
			self.colorTrackLayer!.frame = CGRect.zero
		}
	}
	
	func drawThumb() {
		if self.value >= self.minimumValue {
			// Feature: hide the thumb when below range
			let thumbSizeForStyle = self.thumbSizeIncludingShadow()
			let thumbWidth = thumbSizeForStyle.width
			let thumbHeight = thumbSizeForStyle.height
			let rectangle = CGRect(x: self.thumbAbscisse!-(thumbWidth/2), y: (self.frame.size.height-thumbHeight)/2, width: thumbWidth, height: thumbHeight)
			let shadowRadius = ((self.thumbStyle == .ios) ? iOSThumbShadowRadius : self.thumbShadowRadius)
			let shadowOffset = ((self.thumbStyle == .ios) ? iosThumbShadowOffset : self.thumbShadowOffset)
			// Ignore offset if there is no shadow
			self.thumbLayer!.frame = ((shadowRadius != 0.0) ? rectangle.insetBy(dx: shadowRadius+shadowOffset!.width, dy: shadowRadius+shadowOffset!.height) : rectangle.insetBy(dx: shadowRadius, dy: shadowRadius))
			switch self.thumbStyle {
            case .rounded:
                // A rounded thumb is circular
                self.thumbLayer!.backgroundColor = self.thumbColor!.cgColor
                self.thumbLayer!.borderColor = UIColor.clear.cgColor
                self.thumbLayer!.borderWidth = 0.0
                self.thumbLayer!.cornerRadius = self.thumbLayer!.frame.size.width/2
                self.thumbLayer!.allowsEdgeAntialiasing = true
                break
				
            case .image:
                // image is set using layer.contents
                self.thumbLayer!.backgroundColor = UIColor.clear.cgColor
                self.thumbLayer!.borderColor = UIColor.clear.cgColor
                self.thumbLayer!.borderWidth = 0.0
                self.thumbLayer!.cornerRadius = 0.0
                self.thumbLayer!.allowsEdgeAntialiasing = false
                break
				
            case .rectangular:
                self.thumbLayer!.backgroundColor = self.thumbColor!.cgColor
				self.thumbLayer!.borderColor = UIColor.clear.cgColor
				self.thumbLayer!.borderWidth = 0.0
				self.thumbLayer!.cornerRadius = 0.0
				self.thumbLayer!.allowsEdgeAntialiasing = false
				break
                
            case .invisible:
				self.thumbLayer!.backgroundColor = UIColor.clear.cgColor
				self.thumbLayer!.cornerRadius = 0.0
				break
                
            case .ios:
                self.thumbLayer!.backgroundColor = UIColor.white.cgColor
                self.thumbLayer!.borderColor = UIColor(hue: 0, saturation: 0, brightness: 0.8, alpha: 1).cgColor
                self.thumbLayer!.borderWidth = 0.5
                self.thumbLayer!.cornerRadius = self.thumbLayer!.frame.size.width/2
                self.thumbLayer!.allowsEdgeAntialiasing = true
                break
			}
            
            
			// Shadow
			if shadowRadius != 0.0 {
				self.thumbLayer!.shadowOffset = shadowOffset!
				self.thumbLayer!.shadowRadius = shadowRadius
				self.thumbLayer!.shadowColor = UIColor.black.cgColor
				self.thumbLayer!.shadowOpacity = 0.15
			} else {
				self.thumbLayer!.shadowRadius = 0.0
				self.thumbLayer!.shadowOffset = CGSize.zero
				self.thumbLayer!.shadowColor = UIColor.clear.cgColor
				self.thumbLayer!.shadowOpacity = 0.0
			}
		}
	}
	
	func layoutTrack() {
		assert(self.tickCount > 1, "2 ticks minimum \(self.tickCount)")
		let segments = max(1, self.tickCount-1)
		let thumbWidth = self.thumbSizeIncludingShadow().width
		
        // Calculate the track ticks positions
		let trackHeight = ((.ios == self.trackStyle) ? 2.0 : self.trackThickness)
		var trackSize = CGSize(width: self.frame.size.width-thumbWidth, height: trackHeight)
		if .image == self.trackStyle {
			if let imageName = self.trackImage {
				let image = UIImage(named: imageName)!
                trackSize.width = image.size.width-thumbWidth
			}
		}
		self.trackRectangle = CGRect(x: (self.frame.size.width-trackSize.width)/2, y: (self.frame.size.height-trackSize.height)/2, width: trackSize.width, height: trackSize.height)
		let trackY = self.frame.size.height/2
		
        self.ticksAbscisses.removeAll()
		
        for i in 0...segments {
            let ratio = Double(i) / Double(segments)
            let originX = self.trackRectangle.origin.x+(trackSize.width * CGFloat(ratio))
            let point = CGPoint(x:originX, y:trackY)
            self.ticksAbscisses.append(point)
        }
        
		self.layoutThumb()
	}
	
	func layoutThumb() {
		assert(self.tickCount > 1, "2 ticks minimum \(self.tickCount)")
		let segments = max(1, self.tickCount-1)
		// Calculate the thumb position
		var thumbRatio = (self.value-self.minimumValue) / CGFloat(segments) * self.incrementValue
		thumbRatio = max(0.0, min(thumbRatio, 1.0))
		// Normalized
		self.thumbAbscisse = self.trackRectangle.origin.x+(self.trackRectangle.size.width*thumbRatio)
	}
	
	func thumbSizeIncludingShadow() -> CGSize {
		switch self.thumbStyle {
        case .invisible: break
        case .rectangular: break
        case .rounded:
            return ((self.thumbShadowRadius != 0.0) ? CGSize(width: self.thumbSize.width+(self.thumbShadowRadius*2)+(self.thumbShadowOffset!.width*2), height: self.thumbSize.height+(self.thumbShadowRadius*2)+(self.thumbShadowOffset!.height*2)) : self.thumbSize)
        case .ios:
            return CGSize(width: 33.0+(iOSThumbShadowRadius*2)+(iosThumbShadowOffset.width*2), height: 33.0+(iOSThumbShadowRadius*2)+(iosThumbShadowOffset.height*2))
        case .image:
            if let imageName = self.thumbImage {
                return UIImage(named: imageName)!.size
            }
		}
        return CGSize(width: 33.0, height: 33.0)
	}
	
	// MARK: Touches
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.touchDown(touches, duration: 0.1)
	}
	
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.touchDown(touches, duration: 0.0)
	}
	
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchUp(touches)
	}
	
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchUp(touches)
	}
	
	func touchDown(_ touches: Set<UITouch>, duration: TimeInterval) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: touch.view)
        self.moveThumbTo(location.x, duration: duration)
	}
	
	func touchUp(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: touch.view)
        let tick = self.pickTickFromSliderPosition(location.x)
        self.moveThumbToTick(tick)
	}
	
	// MARK: Notifications
    
	func moveThumbToTick(_ tick: Int) {
		let intValue = Int(self.minimumValue)+(tick * Int(self.incrementValue))
		if intValue != _intValue {
			_intValue = intValue
			self.sendActionsForControlEvents()
		}
		self.layoutThumb()
		self.setNeedsDisplay()
	}
	
	func moveThumbTo(_ abscisse: CGFloat, duration: CFTimeInterval) {
		let leftMost = self.trackRectangle.minX
		let rightMost = self.trackRectangle.maxX
		self.thumbAbscisse = max(leftMost, min(abscisse, rightMost))
		CATransaction.setAnimationDuration(duration)
		let tick = self.pickTickFromSliderPosition(self.thumbAbscisse!)
		let intValue = Int(self.minimumValue)+(tick * Int(self.incrementValue))
		if intValue != _intValue {
			_intValue = intValue
			self.sendActionsForControlEvents()
		}
		self.setNeedsDisplay()
	}
	
	func pickTickFromSliderPosition(_ abscisse: CGFloat) -> Int {
		let leftMost = self.trackRectangle.minX
		let rightMost = self.trackRectangle.maxX
		let clampedAbscisse = max(leftMost, min(abscisse, rightMost))
		let ratio = Double(clampedAbscisse-leftMost) / Double(rightMost-leftMost)
		let segments = Double(max(1, self.tickCount-1))
		return Int(round(segments*ratio))
	}
	
}

