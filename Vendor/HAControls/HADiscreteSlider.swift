//
//  HADiscreteSlider.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 12/02/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

enum ComponentStyle: Int {
    case IOS
    case Rectangular
    case Rounded
    case Invisible
    case Image
}

let iOSThumbShadowRadius: CGFloat = 4.0
let iosThumbShadowOffset = CGSizeMake(0, 3)

class HADiscreteSlider : UIControl {

    func ticksDistanceChanged(ticksDistance: CGFloat, sender: AnyObject) { }
    func valueChanged(value: CGFloat) { }
    
    // MARK: properties
    
    var tickStyle: ComponentStyle =  ComponentStyle.Rectangular {
        didSet { self.layoutTrack() }
    }
    
    var tickSize: CGSize = CGSizeMake(1.0, 4.0) {
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
    
    var trackStyle: ComponentStyle = ComponentStyle.IOS {
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
    
    var thumbStyle: ComponentStyle = ComponentStyle.IOS {
        didSet { self.layoutTrack() }
    }
    
    var thumbSize: CGSize = CGSizeMake(10.0, 10.0) {
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
                self.thumbLayer!.contents = image.CGImage
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
	
	override func drawRect(rect: CGRect) {
		self.drawTrack()
		self.drawThumb()
	}
	
	func sendActionsForControlEvents() {
        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
	}
	
	// MARK: HADiscreteSlider
    
	func initProperties() {
		self.thumbColor = UIColor.lightGrayColor()
		self.thumbShadowOffset = CGSizeZero
		_intMinimumValue = -5
		_intValue = 0
		self.thumbAbscisse = 0.0
		self.trackRectangle = CGRectZero
		// In case we need a colored track, initialize it now
		// There may be a more elegant way to do this than with a CALayer,
		// but then again CALayer brings free animation and will animate along the thumb
		self.colorTrackLayer = CALayer()
		self.colorTrackLayer!.backgroundColor = UIColor(hue: 211.0/360.0, saturation: 1, brightness: 1, alpha: 1).CGColor
		self.colorTrackLayer!.cornerRadius = 2.0
		self.layer.addSublayer(self.colorTrackLayer!)
		// The thumb is its own CALayer, which brings in free animation
		self.thumbLayer = CALayer()
		self.layer.addSublayer(self.thumbLayer!)
		self.multipleTouchEnabled = false
		self.layoutTrack()
	}
	
	func drawTrack() {
		let ctx = UIGraphicsGetCurrentContext()
		// Track
		switch self.trackStyle {
        case .Rectangular:
            CGContextAddRect(ctx, self.trackRectangle)
        break
        case .Image:
        
            // Draw image if exists
            if let imageName = self.trackImage {
                let image = UIImage(named:imageName)!
                let centered = CGRectMake((self.frame.size.width/2)-(image.size.width/2), (self.frame.size.height/2)-(image.size.height/2), image.size.width, image.size.height)
                    CGContextDrawImage(ctx, centered, image.CGImage)
            }
            break
        
        case .Invisible, .Rounded, .IOS:
            let path: UIBezierPath = UIBezierPath(roundedRect: self.trackRectangle, cornerRadius: self.trackRectangle.size.height/2)
            CGContextAddPath(ctx, path.CGPath)
            break
		}
        
		// Ticks
		if .IOS != self.tickStyle {
            for originValue in self.ticksAbscisses {
                let originPoint = originValue
                let rectangle = CGRectMake(originPoint.x-(self.tickSize.width/2), originPoint.y-(self.tickSize.height/2), self.tickSize.width, self.tickSize.height)
                switch self.tickStyle {
                case .Rounded:
                    let path = UIBezierPath(roundedRect: rectangle, cornerRadius: rectangle.size.height/2)
                    CGContextAddPath(ctx, path.CGPath)
                    break
                case .Rectangular:
                    CGContextAddRect(ctx, rectangle)
                    break
                case .Image:
                    // Draw image if exists
                    
                    if let imageName = self.tickImage {
                        let image = UIImage(named: imageName)!
                        let centered = CGRectMake(rectangle.origin.x+(rectangle.size.width/2)-(image.size.width/2), rectangle.origin.y+(rectangle.size.height/2)-(image.size.height/2), image.size.width, image.size.height)
                            CGContextDrawImage(ctx, centered, image.CGImage)
                    }
                    break
                
                case .Invisible: break
                case .IOS: break
                }
            }
		}
        
		// iOS UISlider aka .IOS does not have ticks
		CGContextSetFillColorWithColor(ctx, self.tintColor.CGColor)
		CGContextFillPath(ctx)
		// For colored track, we overlay a CALayer, which will animate along with the cursor
		if .IOS == self.trackStyle {
			var frame = self.trackRectangle
			frame.size.width = self.thumbAbscisse!-CGRectGetMinX(self.trackRectangle)
			self.colorTrackLayer!.frame = frame
		} else {
			self.colorTrackLayer!.frame = CGRectZero
		}
	}
	
	func drawThumb() {
		if self.value >= self.minimumValue {
			// Feature: hide the thumb when below range
			let thumbSizeForStyle = self.thumbSizeIncludingShadow()
			let thumbWidth = thumbSizeForStyle.width
			let thumbHeight = thumbSizeForStyle.height
			let rectangle = CGRectMake(self.thumbAbscisse!-(thumbWidth/2), (self.frame.size.height-thumbHeight)/2, thumbWidth, thumbHeight)
			let shadowRadius = ((self.thumbStyle == .IOS) ? iOSThumbShadowRadius : self.thumbShadowRadius)
			let shadowOffset = ((self.thumbStyle == .IOS) ? iosThumbShadowOffset : self.thumbShadowOffset)
			// Ignore offset if there is no shadow
			self.thumbLayer!.frame = ((shadowRadius != 0.0) ? CGRectInset(rectangle, shadowRadius+shadowOffset!.width, shadowRadius+shadowOffset!.height) : CGRectInset(rectangle, shadowRadius, shadowRadius))
			switch self.thumbStyle {
            case .Rounded:
                // A rounded thumb is circular
                self.thumbLayer!.backgroundColor = self.thumbColor!.CGColor
                self.thumbLayer!.borderColor = UIColor.clearColor().CGColor
                self.thumbLayer!.borderWidth = 0.0
                self.thumbLayer!.cornerRadius = self.thumbLayer!.frame.size.width/2
                self.thumbLayer!.allowsEdgeAntialiasing = true
                break
				
            case .Image:
                // image is set using layer.contents
                self.thumbLayer!.backgroundColor = UIColor.clearColor().CGColor
                self.thumbLayer!.borderColor = UIColor.clearColor().CGColor
                self.thumbLayer!.borderWidth = 0.0
                self.thumbLayer!.cornerRadius = 0.0
                self.thumbLayer!.allowsEdgeAntialiasing = false
                break
				
            case .Rectangular:
                self.thumbLayer!.backgroundColor = self.thumbColor!.CGColor
				self.thumbLayer!.borderColor = UIColor.clearColor().CGColor
				self.thumbLayer!.borderWidth = 0.0
				self.thumbLayer!.cornerRadius = 0.0
				self.thumbLayer!.allowsEdgeAntialiasing = false
				break
                
            case .Invisible:
				self.thumbLayer!.backgroundColor = UIColor.clearColor().CGColor
				self.thumbLayer!.cornerRadius = 0.0
				break
                
            case .IOS:
                self.thumbLayer!.backgroundColor = UIColor.whiteColor().CGColor
                self.thumbLayer!.borderColor = UIColor(hue: 0, saturation: 0, brightness: 0.8, alpha: 1).CGColor
                self.thumbLayer!.borderWidth = 0.5
                self.thumbLayer!.cornerRadius = self.thumbLayer!.frame.size.width/2
                self.thumbLayer!.allowsEdgeAntialiasing = true
                break
			}
            
            
			// Shadow
			if shadowRadius != 0.0 {
				self.thumbLayer!.shadowOffset = shadowOffset!
				self.thumbLayer!.shadowRadius = shadowRadius
				self.thumbLayer!.shadowColor = UIColor.blackColor().CGColor
				self.thumbLayer!.shadowOpacity = 0.15
			} else {
				self.thumbLayer!.shadowRadius = 0.0
				self.thumbLayer!.shadowOffset = CGSizeZero
				self.thumbLayer!.shadowColor = UIColor.clearColor().CGColor
				self.thumbLayer!.shadowOpacity = 0.0
			}
		}
	}
	
	func layoutTrack() {
		assert(self.tickCount > 1, "2 ticks minimum \(self.tickCount)")
		let segments = max(1, self.tickCount-1)
		let thumbWidth = self.thumbSizeIncludingShadow().width
		
        // Calculate the track ticks positions
		let trackHeight = ((.IOS == self.trackStyle) ? 2.0 : self.trackThickness)
		var trackSize = CGSizeMake(self.frame.size.width-thumbWidth, trackHeight)
		if .Image == self.trackStyle {
			if let imageName = self.trackImage {
				let image = UIImage(named: imageName)!
                trackSize.width = image.size.width-thumbWidth
			}
		}
		self.trackRectangle = CGRectMake((self.frame.size.width-trackSize.width)/2, (self.frame.size.height-trackSize.height)/2, trackSize.width, trackSize.height)
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
        case .Invisible: break
        case .Rectangular: break
        case .Rounded:
            return ((self.thumbShadowRadius != 0.0) ? CGSizeMake(self.thumbSize.width+(self.thumbShadowRadius*2)+(self.thumbShadowOffset!.width*2), self.thumbSize.height+(self.thumbShadowRadius*2)+(self.thumbShadowOffset!.height*2)) : self.thumbSize)
        case .IOS:
            return CGSizeMake(33.0+(iOSThumbShadowRadius*2)+(iosThumbShadowOffset.width*2), 33.0+(iOSThumbShadowRadius*2)+(iosThumbShadowOffset.height*2))
        case .Image:
            if let imageName = self.thumbImage {
                return UIImage(named: imageName)!.size
            }
		}
        return CGSizeMake(33.0, 33.0)
	}
	
	// MARK: Touches
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.touchDown(touches, duration: 0.1)
	}
	
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.touchDown(touches, duration: 0.0)
	}
	
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.touchUp(touches)
	}
	
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        self.touchUp(touches!)
	}
	
	func touchDown(touches: NSSet, duration: NSTimeInterval) {
		let touch = touches.anyObject()
		if nil != touch {
			let location = touch!.locationInView(touch!.view)
			self.moveThumbTo(location.x, duration: duration)
		}
	}
	
	func touchUp(touches: NSSet) {
		let touch = touches.anyObject()
		if nil != touch {
			let location = touch!.locationInView(touch!.view)
			let tick = self.pickTickFromSliderPosition(location.x)
			self.moveThumbToTick(tick)
		}
	}
	
	// MARK: Notifications
    
	func moveThumbToTick(tick: Int) {
		let intValue = Int(self.minimumValue)+(tick * Int(self.incrementValue))
		if intValue != _intValue {
			_intValue = intValue
			self.sendActionsForControlEvents()
		}
		self.layoutThumb()
		self.setNeedsDisplay()
	}
	
	func moveThumbTo(abscisse: CGFloat, duration: CFTimeInterval) {
		let leftMost = CGRectGetMinX(self.trackRectangle)
		let rightMost = CGRectGetMaxX(self.trackRectangle)
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
	
	func pickTickFromSliderPosition(abscisse: CGFloat) -> Int {
		let leftMost = CGRectGetMinX(self.trackRectangle)
		let rightMost = CGRectGetMaxX(self.trackRectangle)
		let clampedAbscisse = max(leftMost, min(abscisse, rightMost))
		let ratio = Double(clampedAbscisse-leftMost) / Double(rightMost-leftMost)
		let segments = Double(max(1, self.tickCount-1))
		return Int(round(segments*ratio))
	}
	
}

