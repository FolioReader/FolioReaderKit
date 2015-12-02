//    @file:    TGPDiscreteSlider7.h
//    @project: TGPControls
//
//    @history: Created July 4th, 2014 (Independence Day)
//    @author:  Xavier Schott
//              mailto://xschott@gmail.com
//              http://thegothicparty.com
//              tel://+18089383634
//
//    @license: http://opensource.org/licenses/MIT
//    Copyright (c) 2014, Xavier Schott
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

#import <UIKit/UIKit.h>
#import "TGPControlsTicksProtocol.h"

@interface TGPDiscreteSlider7 :

//  Interface builder hides the IBInspectable for UIControl
#if TARGET_INTERFACE_BUILDER
UIView
#else // !TARGET_INTERFACE_BUILDER
UIControl
#endif // TARGET_INTERFACE_BUILDER

typedef NS_ENUM(int, ComponentStyle) {
    ComponentStyleIOS = 0,
    ComponentStyleRectangular,
    ComponentStyleRounded,
    ComponentStyleInvisible,
    ComponentStyleImage
};

@property (nonatomic, assign) ComponentStyle tickStyle;
@property (nonatomic, assign) CGSize tickSize;
@property (nonatomic, assign) int tickCount;
@property (nonatomic, readonly) CGFloat ticksDistance;
@property (nonatomic, strong) NSString * tickImage;


@property (nonatomic, assign) ComponentStyle trackStyle;
@property (nonatomic, assign) CGFloat trackThickness;
@property (nonatomic, strong) NSString * trackImage;

@property (nonatomic, assign) ComponentStyle thumbStyle;
@property (nonatomic, assign) CGSize thumbSize;
@property (nonatomic, strong) UIColor * thumbColor;
@property (nonatomic, assign) CGFloat thumbShadowRadius;
@property (nonatomic, assign) CGSize thumbShadowOffset;
@property (nonatomic, strong) NSString * thumbImage;

@property (nonatomic, weak) NSObject<TGPControlsTicksProtocol> * ticksListener;

// AKA: UISlider value (as CGFloat for compatibility with UISlider API, but expected to contain integers)
@property (nonatomic, assign) CGFloat minimumValue;
@property (nonatomic, assign) CGFloat value;

@property (nonatomic, assign) int incrementValue;

@end
